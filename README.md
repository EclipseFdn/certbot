# Cerbot on OKD

## How to add a domain?

Edit the script `gen-domain.sh` and add it to the list. Note that the given domain must have a proxy pass configured for port `80` as follow:

```nginx
location /.well-known/acme-challenge {
  proxy_pass  http://okd-ingress-insecure$request_uri;
}
```

Also, ensure that the `Host` header is set via a `proxy_set_header` directive (may already be the case via inclusion of some proxy cache configuration file).

## How to check the generated resources?

```
./gen-domains.sh
```

## How to deploy changes to configuration?

```
./gen-domains.sh | kubectl apply -f -
```