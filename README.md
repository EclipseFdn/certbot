# Certbot on OKD

## How to add a domain?

Edit the file `certs.jsonnet` and add yours to the list.

It is assumed the domain DNS is operational, hostname(s) points to the nginx LB, and that a proxy pass configured for port `80` as follows is already in place and functional:

```nginx
location /.well-known/acme-challenge {
  proxy_pass  http://okd-ingress-insecure$request_uri;
}
```

Finally, ensure that the `Host` header is set via a `proxy_set_header` directive (it may already be the case via inclusion of some proxy cache configuration file).

## How to add a wildcard domain?

Edit the file `certs.jsonnet` and add yours to the list of CloudFlare certificates.

Make CloudFlare the primary DNS for the domain and create an **A**ddress DNS record for the given domain

```
  A    *    <nginx IP>
```

Edit the `Edit zone DNS` token at [CloudFlare](https://dash.cloudflare.com/profile/api-tokens) and add a zone resource for given domain to the list.

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

## nginx
Once the OKD job has run and certs have been created, update the nginx config file for the domain and apache/manifests/letsencrypt.pp. The next time puppet runs it should put the certs in the right place and off we go.  Infra 3966 (EF internal) has more background.

## CloudFlare DNS API Token (initial setup only)

A Kubernetes secret must exist to be able to use CloudFlare API. The DNS API Token must be retrieved from the CloudFlare dashboard (roll it if it already exists) and put in a text file, e.g. `cloudflare_api_token.ini`

```
dns_cloudflare_api_token=abcdefghijklmnopqrstuvwxyz0123456789
```

```
kubectl create secret generic cloudflare-api-token --from-file=cloudflare_api_token.ini=cloudflare_api_token.ini
```