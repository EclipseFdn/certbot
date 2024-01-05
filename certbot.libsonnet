local scripts = import "scripts.libsonnet";

# certs is an array of array
local newCertbotDeployment(certs = {},) = [
  {
    apiVersion: "batch/v1",
    kind: "CronJob",
    metadata: {
      namespace: "foundation-internal-infra-certbot",
      name: "certbot",
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
                {
                  name: "certbot-cloudflare",
                  image: "certbot/dns-cloudflare:latest",
                  imagePullPolicy: "Always",
                  command: [ "/var/lib/certbot-scripts/cloudflare.sh", ],
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
                    {
                      name: "certbot-scripts",
                      mountPath: "/var/lib/certbot-scripts",
                    },
                    {
                      mountPath: "/run/secrets/cloudflare",
                      name: "cloudflare-api-token",
                    },
                  ],
                  resources: {
                    requests: {
                      memory: "256Mi",
                      cpu: "500m"
                    },
                    limits: {
                      memory: "1Gi",
                      cpu: "2000m"
                    }
                  },
                },
              ],
              containers: [
                {
                  name: "certbot-webroot",
                  image: "certbot/certbot:latest",
                  imagePullPolicy: "Always",
                  command: [ "/var/lib/certbot-scripts/webroot.sh", ],
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
                    {
                      name: "certbot-scripts",
                      mountPath: "/var/lib/certbot-scripts",
                    },
                    {
                      mountPath: "/run/secrets/betteruptime",
                      name: "betteruptime-heartbeat",
                    },
                  ],
                  resources: {
                    requests: {
                      memory: "256Mi",
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
                {
                  name: "certbot-scripts",
                  configMap: {
                    name: "certbot-scripts",
                    defaultMode: std.parseOctal("0500"),
                    items: [
                      {
                        key: "webroot.sh",
                        path: "webroot.sh",
                      },
                      {
                        key: "cloudflare.sh",
                        path: "cloudflare.sh",
                      },
                    ],
                  },
                },
                {
                  name: "cloudflare-api-token",
                  secret: {
                    secretName: "cloudflare-api-token"
                  },
                },
                {
                  name: "betteruptime-heartbeat",
                  secret: {
                    secretName: "betteruptime-heartbeat"
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
      namespace: "foundation-internal-infra-certbot",
      name: "certbot",
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
      namespace: "foundation-internal-infra-certbot",
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
        name: "certbot",
        weight: 100
      },
    },
  } for certName in std.objectFields(certs.webroot) for domain in std.set([certName] + certs.webroot[certName])
] + [
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      namespace: "foundation-internal-infra-certbot",
      name: "certbot-scripts",
    },
    data: {
      "webroot.sh": scripts.webroot(certs.webroot),
      "cloudflare.sh": scripts.cloudflare(certs.cloudflare),
    },
  },
];

{
  newCertbotDeployment:: newCertbotDeployment,
}
