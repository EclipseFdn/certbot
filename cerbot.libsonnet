local newCerbotDeployment(domains = [],) = [
  {
    apiVersion: "batch/v1beta1",
    kind: "CronJob",
    metadata: {
      namespace: "foundation-internal-infra-cerbot",
      name: "cerbot",
    },
    spec: {
      schedule: "25 4 5 * *",
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
              restartPolicy: "OnFailure",
              containers: [
                {
                  name: "certbot",
                  image: "certbot/certbot",
                  imagePullPolicy: "Always",
                  command: [ "certbot", ],
                  args: [
                    "certonly",
                    "--webroot",
                    "--noninteractive",
                    "--agree-tos",
                    "--email", "webmaster@eclipse-foundation.org",
                    "--webroot-path", "/usr/share/nginx/html",
                  ] + std.flatMap(function(x) ["-d", x], domains),
                  volumeMounts: [
                    {
                      mountPath: "/usr/share/nginx/html",
                      name: "webroot",
                    },
                    {
                      mountPath: "/var/log/letsencrypt",
                      name: "logsdir",
                    },
                    {
                      mountPath: "/etc/letsencrypt",
                      name: "configdir",
                    },
                    {
                      mountPath: "/var/lib/letsencrypt",
                      name: "workdir",
                    },
                  ],
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
                      memory: "1Gi",
                      cpu: "500m"
                    },
                    limits: {
                      memory: "1Gi",
                      cpu: "2000m"
                    }
                  },
                },
              ],
              volumes: [
                {
                  name: "webroot",
                  emptyDir: {},
                },
                {
                  name: "workdir",
                  emptyDir: {},
                },
                {
                  name: "logsdir",
                  emptyDir: {},
                },
                {
                  name: "configdir",
                  emptyDir: {},
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
      name: "cerbot-%s" % std.strReplace(domain, ".", "-"),
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