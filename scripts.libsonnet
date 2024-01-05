local check_status_tpl = |||
  if [ $? -ne 0 ]; then
    echo "FAILURE: certbot-%(kind)s for %(certName)s (%(domains)s)" >> /usr/share/nginx/html/certbot_status.txt
  else
    echo "SUCCESS: certbot-%(kind)s for %(certName)s (%(domains)s)" >> /usr/share/nginx/html/certbot_status.txt
  fi
|||;

local cloudflare_tpl = |||
  echo "******************************************************************************"
  echo "* Running certbot-cloudflare for %(certName)s"
  echo "* Domains list: %(domains)s"
  echo "******************************************************************************"
  certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /run/secrets/cloudflare/cloudflare_api_token.ini \
    --noninteractive \
    --agree-tos \
    --email webmaster@eclipse-foundation.org \
    --preferred-challenges dns-01 \
    --cert-name %(certName)s \
    --domains %(domains)s
|||;

local webroot_tpl = |||
  echo "******************************************************************************"
  echo "* Running certbot-webroot for %(certName)s"
  echo "* Domains list: %(domains)s"
  echo "******************************************************************************"
  certbot certonly \
  --webroot \
  --noninteractive \
  --agree-tos \
  --email webmaster@eclipse-foundation.org \
  --webroot-path /usr/share/nginx/html \
  --cert-name %(certName)s \
  --domains %(domains)s
|||;

local webroot_trap = |||
  trap "rm -f /usr/share/nginx/html/init" EXIT
|||;

local heartbeat = |||
  if ! grep -Eq "^FAILURE" /usr/share/nginx/html/certbot_status.txt; then
    wget --spider -q $(head -n 1 /run/secrets/betteruptime/url)
  else
    echo ">>>>>>>>>>> Some certificats failed to renew, not calling BetterUptime's heartbeat <<<<<<<<<<<"
    grep -E "^FAILURE" /usr/share/nginx/html/certbot_status.txt
  fi
|||;

local expand_tpl(tpl, kind, certs) = [
  tpl % { 
    kind: kind,
    certName: certName, 
    domains: std.join(",", certs[certName]) 
  } for certName in std.objectFields(certs) 
];

local join_certs_tpl(tpls = [], kind, certs) = "%s" % std.join("\n", 
  expand_tpl(
    std.join("\n", tpls), 
    kind, 
    certs,
  )
);

local cloudflare_script(certs) = std.join("\n", [
  "#!/usr/bin/env sh\n",
  join_certs_tpl([cloudflare_tpl, check_status_tpl, ], "cloudflare", certs),
]);

local webroot_script(certs) = std.join("\n", [
  "#!/usr/bin/env sh\n",
  webroot_trap, 
  join_certs_tpl([webroot_tpl, check_status_tpl, ], "webroot", certs),
  heartbeat,
]);

{
  cloudflare:: cloudflare_script,
  webroot:: webroot_script,
}