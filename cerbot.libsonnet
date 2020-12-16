local newCerbotDeployment(domains = [],) = [
  {
    apiVersion: "batch/v1beta1",
    kind: "CronJob",
    metadata: {
      namespace: "foundation-internal-infra-cerbot",
      name: "cerbot",
    },
    spec: {
      schedule: "5 4 * * 3",
      concurrencyPolicy: "Forbid",
      jobTemplate: {
        spec: {
          template: {
            metadata: {
              labels: {
                job: "certbot",
              },
            },
            spec: {
              restartPolicy: "Never",
              initContainers: [
                {
                  name: "init0",
                  image: "alpine",
                  imagePullPolicy: "Always",
                  command: [ "/bin/sh", ],
                  args: [
                    "-c",
                    # The file will be served until certbot completes
                    # it will then be removed, that will make the nginx
                    # liveness probe fail
                    "echo 1 > /usr/share/nginx/html/init",
                  ],
                  volumeMounts: [
                    {
                      mountPath: "/usr/share/nginx/html",
                      name: "webroot",
                    },
                  ],
                  resources: {
                    requests: {
                      memory: "64Mi",
                      cpu: "50m"
                    },
                    limits: {
                      memory: "64Mi",
                      cpu: "100m"
                    }
                  },
                },
              ],
              containers: [
                {
                  name: "certbot",
                  image: "certbot/certbot",
                  imagePullPolicy: "Always",
                  command: [ "/bin/sh", ],
                  script:: |||
                    certbot certonly \
                    --webroot \
                    --noninteractive \
                    --agree-tos \
                    --email webmaster@eclipse-foundation.org \
                    --webroot-path /usr/share/nginx/html \
                    %s \
                    && rm -f /usr/share/nginx/html/init \
                    || rm -f /usr/share/nginx/html/init
                  ||| % std.join(" \\\n", std.flatMap(function(x) ["-d %s" % x], domains)),
                  args: [
                    "-c",
                    self.script,
                  ],
                  volumeMounts: [
                    {
                      mountPath: "/usr/share/nginx/html",
                      name: "webroot",
                    },
                    {
                      mountPath: "/var/log/letsencrypt",
                      name: "letsencrypt",
                      subPath: "log",
                    },
                    {
                      mountPath: "/etc/letsencrypt",
                      name: "letsencrypt",
                      subPath: "etc",
                    },
                    {
                      mountPath: "/var/lib/letsencrypt",
                      name: "letsencrypt",
                      subPath: "lib",
                    },
                  ],
                  resources: {
                    requests: {
                      memory: "1Gi",
                      cpu: "500m"
                    },
                    limits: {
                      memory: "1Gi",
                      cpu: "2000m"
                    }
                  },
                },
                {
                  name: "nginx",
                  image: "eclipsefdn/nginx:stable-alpine",
                  imagePullPolicy: "Always",
                  volumeMounts: [
                    {
                      mountPath: "/usr/share/nginx/html",
                      name: "webroot",
                    },
                  ],
                  ports: [
                    {
                      name: "http",
                      containerPort: 8080,
                    },
                  ],
                  resources: {
                    requests: {
                      memory: "256Mi",
                      cpu: "50m"
                    },
                    limits: {
                      memory: "256Mi",
                      cpu: "200m"
                    }
                  },
                  livenessProbe: {
                    initialDelaySeconds: 5,
                    periodSeconds: 3,
                    httpGet: {
                      path: "/init",
                      port: 8080,
                    },
                  },
                },
              ],
              volumes: [
                {
                  name: "webroot",
                  emptyDir: {},
                },
                {
                  name: "letsencrypt",
                  persistentVolumeClaim: {
                    claimName: "letsencrypt",
                  },
                },
              ],
            },
          },
        },
      },
    },
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      namespace: "foundation-internal-infra-cerbot",
      name: "cerbot",
    },
    spec: {
      selector: {
        job: "certbot",
      },
      ports: [
        {
          name: "http",
          port: 80,
          protocol: "TCP",
          targetPort: 8080,
        },
      ],
    },
  }
] + [ 
  {
    apiVersion: "route.openshift.io/v1",
    kind: "Route",
    metadata: {
      namespace: "foundation-internal-infra-cerbot",
      name: "acme-challenge-%s" % std.strReplace(domain, ".", "-"),
    },
    spec: {
      host: domain,
      path: "/.well-known/acme-challenge",
      port: {
        targetPort: "http",
      },
      to: {
        kind: "Service",
        name: "cerbot",
        weight: 100
      }
    }
  } for domain in domains 
];

{
  newCerbotDeployment:: newCerbotDeployment,
}