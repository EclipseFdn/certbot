# Certbot on OKD

## How to add a domain?

Edit the file `certs.jsonnet` and add yours to the list. 

Note that the every domain must have a proxy pass configured for port `80` as follow:

```nginx
location /.well-known/acme-challenge {
  proxy_pass  http://okd-ingress-insecure$request_uri;
}
```

Finally, ensure that the `Host` header is set via a `proxy_set_header` directive (it may already be the case via inclusion of some proxy cache configuration file).

## How to check the generated resources?

```
./gen-certbot-deploy.sh certs.jsonnet
```

## How to deploy changes to configuration?

```
./gen-certbot-deploy.sh certs.jsonnet | kubectl apply -f -
```

## How to manually trigger issue/renewal of managed certificates?

```
JOB_NAME="certbot-manual-${USERNAME}-01"
kubectl create job -n foundation-internal-infra-certbot --from=cronjob/certbot ${JOB_NAME}
kubectl wait --for=condition=complete -n foundation-internal-infra-certbot job/${JOB_NAME}
```

Optionnaly, check on the logs:

```
kubectl logs -n foundation-internal-infra-certbot -l "job-name=${JOB_NAME}" -c certbot
```

Cleanup:

```
kubectl delete -n foundation-internal-infra-certbot job/${JOB_NAME}
```