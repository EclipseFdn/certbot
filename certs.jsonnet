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

   "archive.automotive-oss.org": [
      "archive.automotive-oss.org",
    ], 
   
    "eclipse.foundation": [
      "eclipse.foundation",
    ],
    
    "eclipsecon.org": [
      "eclipsecon.org",
      "www.eclipsecon.org",
    ],

    "eclipseide.org": [
      "eclipseide.org",
      "www.eclipseide.org",
    ],

    "eclipseprojects.io": [
      "eclipseprojects.io",
      "websites.eclipseprojects.io",
    ],

    "jakartablogs.ee": [
      "jakartablogs.ee",
      "www.jakartablogs.ee",
    ],

    "opencode-x.org": [
      "opencode-x.org",
      "www.opencode-x.org",
    ],

    "planeteclipse.org": [
      "planeteclipse.org",
      "www.planeteclipse.org",
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

    "store.adoptium.net": [
      "store.adoptium.net",
    ],

    "theiacon.org": [
      "theiacon.org",
      "www.theiacon.org",
      "theiacon.io",
      "www.theiacon.io",
    ],

    "threadx.io": [
      "threadx.io",
      "www.threadx.io",
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
    "matrix.eclipsecontent.org": [
      "*.matrix.eclipsecontent.org",
    ],
    "chat.eclipsecontent.org": [
      "*.chat.eclipsecontent.org",
    ],
    "wildcard.matrix-media-repo.eclipsecontent.org": [
      "*.matrix-media-repo.eclipsecontent.org",
    ],
    "matrix-media-repo.eclipsecontent.org": [
      "matrix-media-repo.eclipsecontent.org",
      "matrix-media-repo-staging.eclipsecontent.org",
    ],
    "orcwg.io": [
      "orcwg.io",
      "www.orcwg.io",
    ],
    "orcwg.org": [
      "orcwg.org",
      "www.orcwg.org",
    ],
  },
}
