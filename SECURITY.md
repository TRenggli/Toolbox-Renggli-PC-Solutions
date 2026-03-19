# SECURITY POLICY

## Supported Scope
This repository contains operational scripts for Windows, Linux, and macOS.
Security reports are accepted for:
- `Windows/*.bat` and `Windows/*.cmd`
- `Linux/*.sh`
- `Mac/*.sh`
- CI workflows under `.github/workflows/`
- Documentation that could cause unsafe operational behavior

## Reporting a Vulnerability
Please report vulnerabilities privately to:
- `tomasrenggli@gmail.com`

Include:
- Affected file and line reference
- Impact and attack/abuse scenario
- Reproduction steps
- Suggested mitigation (if available)

## Response Targets
- Initial acknowledgment: within 3 business days
- Triage decision: within 7 business days
- Fix plan or mitigation guidance: as soon as validated

## Safe Disclosure Rules
- Do not publish exploit details before a fix or mitigation is available.
- Do not run destructive tests against production systems.
- Prefer proof-of-concept in isolated test environments.

## Security Baseline for Contributions
Changes must preserve these controls:
- No global destructive cleanup of non-Toolbox tasks
- System-disk protections for destructive operations
- No regression in no-log/no-report exit routing
- No bypass of privilege checks
- CI workflows must remain passing on PRs
