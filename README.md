# Cerbot on OKD

## How to add a domain?

Edit the script `gen-domain.sh` and add it to the list.

## How to check the generated resources?

```
./gen-domains.sh
```

## How to deploy changes to configuration?

```
./gen-domains.sh | kubectl apply -f -
```