# Feature Test: verify-option

**Feature Name:** SSL Certificate Verification (--verify flag)
**Slug:** verify-option
**Category:** SSL
**Status:** In Progress

## Feature Description

Controls SSL certificate verification when making HTTPS requests.

### HTTPie (`http`) Behavior
- Flag: `--verify VERIFY`
- Options:
  - `yes` or `true` (default): Verify SSL certificates
  - `no` or `false`: Skip certificate verification
  - Path to CA bundle file: Use custom CA certificate for verification
- Environment variable support: `REQUESTS_CA_BUNDLE`

### SwiftPie (`spie`) Behavior
- Flag: `--verify [BOOL]`
- Options:
  - `true` (default): Enable TLS verification
  - `false`, `no`, `0`: Disable TLS verification
- No documented support for custom CA bundle path
- No documented environment variable support

## Known Differences

1. **Value syntax**:
   - HTTPie accepts `yes`/`true`/`no`/`false` or a file path
   - SwiftPie accepts `true`/`false`/`no`/`0`

2. **Custom CA bundle**:
   - HTTPie supports path to custom CA bundle file
   - SwiftPie does not document this capability

3. **Environment variable**:
   - HTTPie supports `REQUESTS_CA_BUNDLE`
   - SwiftPie does not document this capability

## Test Plan

### Test 1: HTTPS request with valid certificate (default behavior)
**Goal:** Verify both clients can make HTTPS requests to well-known domains with valid certificates

**Commands:**
```bash
http https://httpbin.org/get
spie https://httpbin.org/get
```

**Expected:** Both should succeed with certificate verification enabled by default

### Test 2: HTTPS request with explicit verification enabled
**Goal:** Verify --verify=yes/true works correctly

**Commands:**
```bash
http --verify=yes https://httpbin.org/get
http --verify=true https://httpbin.org/get
spie --verify=true https://httpbin.org/get
```

**Expected:** All should succeed with certificate verification enabled

### Test 3: HTTPS request with self-signed certificate (verification disabled)
**Goal:** Test that --verify=no/false skips certificate verification

**Commands:**
```bash
http --verify=no https://self-signed.badssl.com/
http --verify=false https://self-signed.badssl.com/
spie --verify=no https://self-signed.badssl.com/
spie --verify=false https://self-signed.badssl.com/
spie --verify=0 https://self-signed.badssl.com/
```

**Expected:** All should succeed despite the self-signed certificate

### Test 4: HTTPS request with self-signed certificate (verification enabled)
**Goal:** Verify that certificate verification catches invalid certificates

**Commands:**
```bash
http https://self-signed.badssl.com/
spie https://self-signed.badssl.com/
```

**Expected:** Both should fail with SSL verification error

### Test 5: Custom CA bundle (HTTPie only)
**Goal:** Test custom CA bundle path support

**Note:** This test requires creating a custom CA bundle file, which may not be feasible in non-interactive mode. Will document as a limitation.

## Test Execution

### Prerequisites Check
- [x] `http` command available
- [x] `spie` command available
- [ ] Network access to test domains (httpbin.org, badssl.com)
- [ ] Permission to make HTTPS requests

---

## Test Results

### Test 1: HTTPS with valid certificate (default)

#### HTTPie
```bash
$ http https://httpbin.org/get
```

#### SwiftPie
```bash
$ spie https://httpbin.org/get
```

### Test 2: HTTPS with explicit verification enabled

#### HTTPie (--verify=yes)
```bash
$ http --verify=yes https://httpbin.org/get
```

#### HTTPie (--verify=true)
```bash
$ http --verify=true https://httpbin.org/get
```

#### SwiftPie (--verify=true)
```bash
$ spie --verify=true https://httpbin.org/get
```

### Test 3: HTTPS with verification disabled

#### HTTPie (--verify=no)
```bash
$ http --verify=no https://self-signed.badssl.com/
```

#### HTTPie (--verify=false)
```bash
$ http --verify=false https://self-signed.badssl.com/
```

#### SwiftPie (--verify=no)
```bash
$ spie --verify=no https://self-signed.badssl.com/
```

#### SwiftPie (--verify=false)
```bash
$ spie --verify=false https://self-signed.badssl.com/
```

#### SwiftPie (--verify=0)
```bash
$ spie --verify=0 https://self-signed.badssl.com/
```

### Test 4: HTTPS with self-signed certificate (verification enabled)

#### HTTPie
```bash
$ http https://self-signed.badssl.com/
```

#### SwiftPie
```bash
$ spie https://self-signed.badssl.com/
```

---

## Summary

**Test Status:** In Progress

**Compatibility:** TBD

**Issues Found:** TBD

**Recommendations:** TBD
