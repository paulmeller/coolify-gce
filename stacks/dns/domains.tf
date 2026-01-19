# agentstep.com
resource "godaddy_domain_record" "agentstep_com" {
  domain = "agentstep.com"

  record {
    name = "api"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "beta"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns41.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns42.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "api"
    type = "TXT"
    data = "replit-verify=cd0278db-2dec-45bd-bf7a-8c2d36b2d0ac"
    ttl  = 3600
  }

  record {
    name = "beta"
    type = "TXT"
    data = "replit-verify=4d9c4d67-d2fb-4155-927a-e2c8b7445310"
    ttl  = 3600
  }

}

# atsaway.com
resource "godaddy_domain_record" "atsaway_com" {
  domain = "atsaway.com"

  record {
    name = "@"
    type = "A"
    data = "199.36.158.100"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "199.36.158.100"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns31.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns32.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 604800
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 604800
    priority = 20
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 604800
    priority = 30
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx2.googlemail.com"
    ttl  = 604800
    priority = 40
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx3.googlemail.com"
    ttl  = 604800
    priority = 50
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=LsSuBogvHVfpE0XaM30LB2JDAzH30mf0qw-b423ysv4"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=pXp5xdYv8ktoeU5x2KUNFs_pBGr9zdyn3na333hqTko"
    ttl  = 3600
  }

}

# borderproof.com
resource "godaddy_domain_record" "borderproof_com" {
  domain = "borderproof.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.142.173"
    ttl  = 600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.152.147"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "beta"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns29.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns30.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 3600
    priority = 1
  }

  record {
    name = "@"
    type = "MX"
    data = "alt4.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt3.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=Ye0naHY5n1hvrGw-qZ3UFqNV4WaHSCCvpAtJ5u7v2KU"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "replit-verify=6d9b1908-6f89-47d5-9dc5-6ea4f0b3ce7e"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=c4028d4e-1d34-4b4d-ad2d-6755b7fe59b9"
    ttl  = 3600
  }

  record {
    name = "beta"
    type = "TXT"
    data = "replit-verify=e4b86981-7c47-48d4-82b9-3c3ed5a010e7"
    ttl  = 3600
  }

}

# buildmyapi.com
resource "godaddy_domain_record" "buildmyapi_com" {
  domain = "buildmyapi.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.225.128"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.251.168"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns45.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns46.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=a105d886-6d2f-457f-a99d-e6a2f5c679c2"
    ttl  = 3600
  }

}

# contextpipeline.com
resource "godaddy_domain_record" "contextpipeline_com" {
  domain = "contextpipeline.com"

  record {
    name = "@"
    type = "NS"
    data = "ns03.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns04.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# contextprompt.com
resource "godaddy_domain_record" "contextprompt_com" {
  domain = "contextprompt.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.142.173"
    ttl  = 600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.152.147"
    ttl  = 600
  }

  record {
    name = "agents"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "api"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "api1"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "authentik"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "chat"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "coolify"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "fizzy"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "n8n"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "panel"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "router"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns15.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns16.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "developer"
    type = "CNAME"
    data = "ssl.readmessl.com"
    ttl  = 1800
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 3600
    priority = 1
  }

  record {
    name = "@"
    type = "MX"
    data = "alt3.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt4.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "send"
    type = "MX"
    data = "feedback-smtp.us-east-1.amazonses.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=R_h5UyH-INKG8TDcKqFMj55yT2ScQuPvnX6Q828Jx0Q"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "replit-verify=fd07c0e0-492d-4df6-b73e-636cd7bcf39e"
    ttl  = 3600
  }

  record {
    name = "agents"
    type = "TXT"
    data = "replit-verify=dc354c77-7d65-40d2-b5db-cf389e4aa6c6"
    ttl  = 3600
  }

  record {
    name = "api1"
    type = "TXT"
    data = "replit-verify=3314f10d-91bb-40e2-90d0-b1e1d2455eb5"
    ttl  = 3600
  }

  record {
    name = "resend._domainkey"
    type = "TXT"
    data = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDWEh3vNcizto5kZOrWLZ+XwLYJwJgFvigdL7QLGW46V96BWp/jHEKGP1LMljFqI8gj053m6IOqH23mD2XCE3Ugby0gAWWEQ5ndp7gvXqKKSZWSAQOj2kyhuQ2/9lLVHNiLqgWBamp5dLE5wCTKUpWT7+BOMOHEL1aP+eRYEP9COQIDAQAB"
    ttl  = 3600
  }

  record {
    name = "router"
    type = "TXT"
    data = "replit-verify=27080eb1-98fc-4a0b-9f75-d4403884f2f9"
    ttl  = 3600
  }

  record {
    name = "send"
    type = "TXT"
    data = "v=spf1 include:amazonses.com ~all"
    ttl  = 3600
  }

}

# contextsignal.com
resource "godaddy_domain_record" "contextsignal_com" {
  domain = "contextsignal.com"

  record {
    name = "@"
    type = "NS"
    data = "ns59.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns60.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# convertally.com
resource "godaddy_domain_record" "convertally_com" {
  domain = "convertally.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.142.173"
    ttl  = 600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.152.147"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns01.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns02.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=a3e64773-f255-4717-98e9-a30759724e8c"
    ttl  = 3600
  }

}

# cuddlelog.com
resource "godaddy_domain_record" "cuddlelog_com" {
  domain = "cuddlelog.com"

  record {
    name = "@"
    type = "NS"
    data = "ns07.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns08.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

}

# docbranch.com
resource "godaddy_domain_record" "docbranch_com" {
  domain = "docbranch.com"

  record {
    name = "@"
    type = "NS"
    data = "ns25.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns26.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "email"
    type = "CNAME"
    data = "mailgun.org"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "mxa.mailgun.org"
    ttl  = 3600
    priority = 60
  }

  record {
    name = "@"
    type = "MX"
    data = "mxb.mailgun.org"
    ttl  = 3600
    priority = 60
  }

  record {
    name = "@"
    type = "TXT"
    data = "v=spf1 include:mailgun.org ~all"
    ttl  = 3600
  }

  record {
    name = "krs._domainkey"
    type = "TXT"
    data = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC96AO/ZgeXTzfBU2LafvKfhHJe79JGZCEomtQuOrxGXblJnIKZRCeR9u5UsIJVJvygM4gjJSejrVoAVeMks2i3hZvaECG6Oca7Kn7zZbiXIA2HlHS46Qpa7mCrnvYUFbcnl+Nr87UCd98zDG3xbZI6bSCzgFg9qrvC2dqRJm3U8wIDAQAB"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# docpipeline.com
resource "godaddy_domain_record" "docpipeline_com" {
  domain = "docpipeline.com"

  record {
    name = "@"
    type = "NS"
    data = "ns71.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns72.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# fewshotprompt.com
resource "godaddy_domain_record" "fewshotprompt_com" {
  domain = "fewshotprompt.com"

  record {
    name = "@"
    type = "NS"
    data = "ns15.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns16.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

}

# generationapi.com
resource "godaddy_domain_record" "generationapi_com" {
  domain = "generationapi.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.225.128"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.251.168"
    ttl  = 3600
  }

  record {
    name = "api"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns73.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns74.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "api"
    type = "TXT"
    data = "replit-verify=6b4a7a8d-7761-4917-985a-05c6f613b4be"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=a105d886-6d2f-457f-a99d-e6a2f5c679c2"
    ttl  = 3600
  }

}

# mcplit.com
resource "godaddy_domain_record" "mcplit_com" {
  domain = "mcplit.com"

  record {
    name = "@"
    type = "NS"
    data = "ns63.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns64.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=reject; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# mcpstreamable.com
resource "godaddy_domain_record" "mcpstreamable_com" {
  domain = "mcpstreamable.com"

  record {
    name = "@"
    type = "NS"
    data = "ns07.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns08.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=reject; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# meller.au
resource "godaddy_domain_record" "meller_au" {
  domain = "meller.au"

  record {
    name = "@"
    type = "NS"
    data = "ns49.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns50.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

}

# meller.com.au
resource "godaddy_domain_record" "meller_com_au" {
  domain = "meller.com.au"

  record {
    name = "@"
    type = "NS"
    data = "ns49.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns50.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 3600
    priority = 1
  }

  record {
    name = "@"
    type = "MX"
    data = "alt4.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt3.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=WdohXi_4J96u-60vmpxkASQcLLzERvcw9LO-mRPZ3Ds"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "v=spf1 include:dc-aa8e722993._spfm.meller.com.au ~all"
    ttl  = 3600
  }

  record {
    name = "dc-aa8e722993._spfm"
    type = "TXT"
    data = "v=spf1 include:_spf.google.com ~all"
    ttl  = 3600
  }

}

# miameller.com
resource "godaddy_domain_record" "miameller_com" {
  domain = "miameller.com"

  record {
    name = "@"
    type = "NS"
    data = "ns11.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns12.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 604800
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 604800
    priority = 20
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 604800
    priority = 30
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx2.googlemail.com"
    ttl  = 604800
    priority = 40
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx3.googlemail.com"
    ttl  = 604800
    priority = 50
  }

}

# modeltext.com
resource "godaddy_domain_record" "modeltext_com" {
  domain = "modeltext.com"

  record {
    name = "@"
    type = "NS"
    data = "ns63.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns64.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=reject; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# olivermeller.com
resource "godaddy_domain_record" "olivermeller_com" {
  domain = "olivermeller.com"

  record {
    name = "@"
    type = "NS"
    data = "ns75.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns76.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# opencompletions.com
resource "godaddy_domain_record" "opencompletions_com" {
  domain = "opencompletions.com"

  record {
    name = "@"
    type = "NS"
    data = "ns25.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns26.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=reject; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# paulmeller.com
resource "godaddy_domain_record" "paulmeller_com" {
  domain = "paulmeller.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.225.128"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.251.168"
    ttl  = 3600
  }

  record {
    name = "blog"
    type = "A"
    data = "66.6.44.4"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns37.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns38.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "ftp"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "googleffffffffc1f9d7e6"
    type = "CNAME"
    data = "google.com"
    ttl  = 3600
  }

  record {
    name = "mail"
    type = "CNAME"
    data = "ghs.google.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 604800
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 604800
    priority = 20
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 604800
    priority = 30
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx2.googlemail.com"
    ttl  = 604800
    priority = 40
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx3.googlemail.com"
    ttl  = 604800
    priority = 50
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=dPYaTM7jpa8-Z1j3tNNI-MimOcvpCGOtFnl-jhVYbCI"
    ttl  = 3600
  }

}

# pocurio.com
resource "godaddy_domain_record" "pocurio_com" {
  domain = "pocurio.com"

  record {
    name = "@"
    type = "A"
    data = "199.36.158.100"
    ttl  = 604800
  }

  record {
    name = "www"
    type = "A"
    data = "199.36.158.100"
    ttl  = 604800
  }

  record {
    name = "@"
    type = "NS"
    data = "ns71.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns72.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 604800
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 604800
    priority = 20
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 604800
    priority = 30
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx2.googlemail.com"
    ttl  = 604800
    priority = 40
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx3.googlemail.com"
    ttl  = 604800
    priority = 50
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=H3sb8ETIySZdzTgIZMj61paqsxUamk0Z-sY3ziedl9Y"
    ttl  = 3600
  }

  record {
    name = "_acme-challenge"
    type = "TXT"
    data = "c9I28RnDeh8DoWHd0GUmVbGdVHgXHmn4q7iaSciL43Q"
    ttl  = 3600
  }

}

# riverpart.com
resource "godaddy_domain_record" "riverpart_com" {
  domain = "riverpart.com"

  record {
    name = "@"
    type = "NS"
    data = "ns55.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns56.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

}

# sendby.email
resource "godaddy_domain_record" "sendby_email" {
  domain = "sendby.email"

  record {
    name = "@"
    type = "A"
    data = "34.111.254.92"
    ttl  = 600
  }

  record {
    name = "api"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns41.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns42.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "email.mg"
    type = "CNAME"
    data = "mailgun.org"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "mg"
    type = "MX"
    data = "mxa.mailgun.org"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "mg"
    type = "MX"
    data = "mxb.mailgun.org"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "TXT"
    data = "replit-verify=4bdd52b9-d3bb-4758-bdab-c32d40651c27"
    ttl  = 3600
  }

  record {
    name = "mailo._domainkey.mg"
    type = "TXT"
    data = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDxxiWwcUjnw492Nl4urdIlobnybylyQlOW2Y/vyKyLqDClXoPlxe62rYD8vWfnySAQ7cB7ph2bEDgq/5LjKqtAkpVfIoBsjWc5/CE5QFn3gNUK+svxeyvQJ5wKOsp5Dytft7W7xvxGm2HsLH/1PqPMJ/xFnxyrdIAP5mZnAWCneQIDAQAB"
    ttl  = 3600
  }

  record {
    name = "mg"
    type = "TXT"
    data = "v=spf1 include:mailgun.org ~all"
    ttl  = 3600
  }

}

# severalmedia.com
resource "godaddy_domain_record" "severalmedia_com" {
  domain = "severalmedia.com"

  record {
    name = "@"
    type = "A"
    data = "8.17.82.194"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns37.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns38.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "e"
    type = "CNAME"
    data = "email.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "email"
    type = "CNAME"
    data = "email.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "ftp"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "imap"
    type = "CNAME"
    data = "imap.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "mail"
    type = "CNAME"
    data = "pop.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "mobilemail"
    type = "CNAME"
    data = "mobilemail-v01.prod.mesa1.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "pda"
    type = "CNAME"
    data = "mobilemail-v01.prod.mesa1.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "pop"
    type = "CNAME"
    data = "pop.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "smtp"
    type = "CNAME"
    data = "smtp.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "webmail"
    type = "CNAME"
    data = "webmail.secureserver.net"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 604800
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 604800
    priority = 20
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 604800
    priority = 30
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx2.googlemail.com"
    ttl  = 604800
    priority = 40
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx3.googlemail.com"
    ttl  = 604800
    priority = 50
  }

}

# shipobserve.com
resource "godaddy_domain_record" "shipobserve_com" {
  domain = "shipobserve.com"

  record {
    name = "@"
    type = "NS"
    data = "ns51.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns52.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# shipobserverefine.com
resource "godaddy_domain_record" "shipobserverefine_com" {
  domain = "shipobserverefine.com"

  record {
    name = "@"
    type = "NS"
    data = "ns51.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns52.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "pay"
    type = "CNAME"
    data = "paylinks.commerce.godaddy.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_dmarc"
    type = "TXT"
    data = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
    ttl  = 3600
  }

}

# thenewborntimes.com
resource "godaddy_domain_record" "thenewborntimes_com" {
  domain = "thenewborntimes.com"

  record {
    name = "@"
    type = "A"
    data = "15.197.142.173"
    ttl  = 600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.152.147"
    ttl  = 600
  }

  record {
    name = "api"
    type = "A"
    data = "35.184.84.184"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns29.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns30.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=6f920ebc-521c-48ad-aba4-4c1221f69bb2"
    ttl  = 3600
  }

}

# workwireless.com.au
resource "godaddy_domain_record" "workwireless_com_au" {
  domain = "workwireless.com.au"

  record {
    name = "@"
    type = "A"
    data = "34.111.179.208"
    ttl  = 600
  }

  record {
    name = "www"
    type = "A"
    data = "34.111.179.208"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns27.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns28.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "aspmx.l.google.com"
    ttl  = 3600
    priority = 1
  }

  record {
    name = "@"
    type = "MX"
    data = "alt4.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt3.aspmx.l.google.com"
    ttl  = 3600
    priority = 10
  }

  record {
    name = "@"
    type = "MX"
    data = "alt2.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "MX"
    data = "alt1.aspmx.l.google.com"
    ttl  = 3600
    priority = 5
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=T3YIQa4_VZGOhBUpLtBdESTnV7UCPkaMSq0YemelzNk"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "replit-verify=75e6b628-8402-4c93-808d-cad12b915961"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "TXT"
    data = "replit-verify=75e6b628-8402-4c93-808d-cad12b915961"
    ttl  = 3600
  }

  record {
    name = "_acme-challenge.www.workwireless.io"
    type = "TXT"
    data = "26Y2ctCB17Oi4OTtqQ-ABxmJyr3L7ke1zXeSTOYipOI"
    ttl  = 3600
  }

}

# workwireless.net
resource "godaddy_domain_record" "workwireless_net" {
  domain = "workwireless.net"

  record {
    name = "@"
    type = "A"
    data = "151.101.1.195"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "A"
    data = "151.101.65.195"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns67.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns68.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "ftp"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "google-site-verification=gINduOjCV5RswaXuIFAzCQ74y0kkXt98kpoRqv_gHek"
    ttl  = 3600
  }

}

# zeroshotventures.com
resource "godaddy_domain_record" "zeroshotventures_com" {
  domain = "zeroshotventures.com"

  record {
    name = "@"
    type = "NS"
    data = "ns21.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "@"
    type = "NS"
    data = "ns22.domaincontrol.com"
    ttl  = 3600
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl  = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl  = 3600
  }

}

