{
  // This file is a object with 1 sub-object per certificate to generate
  // certname: [
  //    domain1,
  //    domain2
  //  ],
  // certname will be the certificate Common Name while and domain1, domain2 will be
  // SAN for the cert

  "adoptium.org": [
    "adoptium.org",
    "adoptium.io",
    "adoptium.com",
    "adoptium.dev",
  ],

  "eclipseprojects.io": [
    "eclipseprojects.io",
  ],

  "eclipsecontent.org": [
    # eclipsecontent.org does not have DNS
    "bugzillaattachments.eclipsecontent.org",
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

}
