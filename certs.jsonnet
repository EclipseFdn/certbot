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
      "www.adoptium.org",
      "www.adoptium.io",
      "www.adoptium.com",
      "www.adoptium.dev",
    ],

    "automotive-oss.org": [
      "automotive-oss.org",
      "www.automotive-oss.org",
    ],
    
    "eclipse.dev": [
      "eclipse.dev",
    ],
    
    "eclipse.foundation": [
      "eclipse.foundation",
    ],
    
    "eclipseide.org": [
      "eclipseide.org",
      "www.eclipseide.org",
    ],

    "eclipseprojects.io": [
      "eclipseprojects.io",
      "websites.eclipseprojects.io",
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

    "eclipse-pass.org": [
      "demo.eclipse-pass.org",
      "nightly.eclipse-pass.org",
    ],

    "eclipsepass.org": [
      "demo.eclipsepass.org",
      "nightly.eclipsepass.org",
    ],

    "entrepreneurialopensource.org": [
      "entrepreneurialopensource.org",
      "www.entrepreneurialopensource.org",
    ],

    "entrepreneurialopensource.com": [
      "entrepreneurialopensource.com",
      "www.entrepreneurialopensource.com",
    ],

    "entrepreneurialopensource.net": [
      "entrepreneurialopensource.net",
      "www.entrepreneurialopensource.net",
    ],
    
    "eclip.se": [
      "eclip.se",
      "www.eclip.se",
    ],

  },

  // This is for domains whose primary DNS is cloudflare. It can be wildcard.
  cloudflare: {
    "eclipsecontent.org": [
      "*.eclipsecontent.org",
    ],
  },
}
