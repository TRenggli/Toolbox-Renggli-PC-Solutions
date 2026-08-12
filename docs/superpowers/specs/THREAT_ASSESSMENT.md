# Enterprise Toolbox V15 — Threat Assessment

**Version:** 1.0.0  
**Date:** 2026-08-12  
**Classification:** Internal — Confidential  

## Threat Model Overview

| Asset | Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Clinical records DB | Unauthorized access from operational API | Medium | Critical | Separate DB, network, credentials; MFA; audit |
| Clinical records DB | Data exfiltration via agent telemetry | Medium | Critical | Agent blocked from clinical network; signed scope validation |
| Clinical records DB | Insider access without justification | Medium | High | Mandatory reason, time-limited access, full audit |
| Agent enrollment token | Token theft/replay | Low | High | Single-use, short TTL, bound to source IP |
| Module manifests | Tampered module execution | Medium | Critical | Code signing, hash validation, version pinning |
| Audit logs | Log tampering/deletion | Low | High | Append-only, chained hashes, tamper alerts |
| Backups | Ransomware encryption of backups | Low | Critical | Immutable weekly copies, separate destination, restore tests |
| Server API | Unauthenticated API access | Low | Critical | mTLS, MFA, role-based access control |
| Server API | Replay attacks on signed jobs | Medium | High | Nonce, expiry, recipient binding |
| Server API | Privilege escalation | Low | Critical | Role validation per endpoint, audit |
| Docker host | Container breakout | Low | Critical | Non-root containers, read-only rootfs, seccomp/AppArmor |
| Legacy bridge | Parameter injection | Low | Medium | Strict input validation, deprecation timeline |
| MAS distribution | Licensing/legal exposure | Low | High | Complete removal from repo and distribution |
| Artec Invent | Firmware/geometry corruption | Low | Critical | Read-only tool opening, never write to device |
| Artec Invent | hyperDENT without validated profile | Medium | High | Production blocked, explicit operator override required |
| Artec Invent | Unauthorized clinical record access via production | Medium | Critical | Role separation, MFA, isolated service |
| Remote repair | Unauthorized remote execution | Medium | Critical | Only W-R modules, re-auth, explicit scope, individual approval, rollback tested |
| Remote repair | Rollback failure on remote repair | Medium | High | Automated rollback required, integration tests mandatory |
| Software supply chain | Dependency compromise | Low | High | SBOM, dependency scanning, signed packages |
| Secrets | Credential leakage in code/repo | Low | Critical | Secret scanning, no hardcoded credentials |

## STRIDE Analysis by Component

### CLI Client

| Threat | STRIDE | Mitigation |
|---|---|---|
| Spoofed CLI binary | Spoofing | Authenticode/code signing |
| Parameter tampering | Tampering | Input validation, schema enforcement |
| Repudiation of actions | Repudiation | Local audit log with hash |
| Information disclosure (secrets in output) | Information Disclosure | Output sanitization |
| Denial of service (timeout abuse) | DoS | Module timeout enforcement |
| Elevation of privilege | EoP | Run-as verification, no SUID abuse |

### Server API (.NET)

| Threat | STRIDE | Mitigation |
|---|---|---|
| Spoofed client certificate | Spoofing | CA validation, CRL/OCSP |
| Tampered job payload | Tampering | Signature verification |
| Repudiation of job execution | Repudiation | Chained audit hashes |
| Information disclosure (API error messages) | Information Disclosure | Generic error responses |
| Denial of service (queue flooding) | DoS | Rate limiting, queue depth limits |
| Elevation of privilege (role bypass) | EoP | Server-side role enforcement |

### Agent

| Threat | STRIDE | Mitigation |
|---|---|---|
| Spoofed agent identity | Spoofing | Client certificate, enrollment token |
| Tampered agent binary | Tampering | Code signing, hash validation |
| Repudiation of agent actions | Repudiation | Server-audited actions |
| Information disclosure (telemetry) | Information Disclosure | Scope-limited telemetry, no clinical data |
| Denial of service (agent overload) | DoS | Resource limits, heartbeat monitoring |
| Elevation of privilege (agent as root) | EoP | Least privilege, capability dropping |

### Artec Invent / Clinical Service

| Threat | STRIDE | Mitigation |
|---|---|---|
| Spoofed clinical user | Spoofing | MFA mandatory |
| Tampered clinical record | Tampering | Hash versioning, immutable audit |
| Repudiation of access | Repudiation | Reason + timestamp + identity audit |
| Information disclosure (records in operational logs) | Information Disclosure | Network separation |
| Denial of service (clinical DB overload) | DoS | Connection pooling, read replicas |
| Elevation of privilege (operational→clinical) | EoP | Separate credentials, no shared sessions |

## Compliance

- **Argentina Law 25.326** (Personal Data Protection): Clinical data isolation, access control, audit trail, patient consent framework
- **Argentina Law 26.529** (Patient Rights): Clinical history integrity, authenticity, restricted access, retention policy
- **GDPR-readiness:** Data minimization, right to access/erasure, breach notification capability

## Residual Risks

1. **Zero-day in .NET runtime or Docker:** Mitigated by ring-based staged rollouts and rollback capability
2. **Physical access to server:** Mitigated by disk encryption and immutable offsite backups
3. **Compromised signing key:** Mitigated by key rotation policy and certificate transparency
4. **hyperDENT profile gaps:** Not yet validated — blocked until confirmed

## Review Status

- [ ] Architecture review
- [ ] Legal review (clinical data compliance)
- [ ] Security review (penetration testing scope)
- [ ] Third-party dependency audit
