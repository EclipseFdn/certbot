// This file is a object with 1 sub-object per certificate to generate
// "certname": [
//    "domain1",
//    "domain2"
//  ],
{
  // The certificates below will use the webroot challenge from cerbot. It cannot be wildcard.
  webroot: {
    // certname will be the certificate Common Name while and domain1, domain2 will be
    // SAN for the cert

    "adoptium.org": [
      "adoptium.org",
      "adoptium.io",
      "adoptium.com",
      "adoptium.dev",
    ],

    "eclipse.foundation": [
      "eclipse.foundation",
    ],

    "eclipseprojects.io": [
      "eclipseprojects.io",
      "che.eclipseprojects.io",
    ],

    "polarsys.org": [
      "polarsys.org",
      "www.polarsys.org",
      "wiki.polarsys.org",
      "bugs.polarsys.org",
      "ci.polarsys.org",
      "hudson.polarsys.org",
      "download.polarsys.org",
      "archive.polarsys.org",
    ],

    "theiacon.org": [
      "theiacon.org",
      "theiacon.io",
    ],

    "tracecompass.org": [
      "tracecompass.org",
    ],

  },

  // This is for domains whose primary DNS is cloudflare. It can be wildcard.
  cloudflare: {
    "eclipsecontent.org": [
      "*.eclipsecontent.org",
    ],
  },
}
