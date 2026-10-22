# Kivora Open Architectural & Product Decisions

| Decision Topic | PRD Context | Impact | Current Working Default | Status |
|---|---|---|---|---|
| **Branch Creation Access** | Open vs. Reviewed | Affects spam prevention and tenant onboarding. | Any verified user with role `branch_manager` may initiate branch creation; initial state is active. | Provisional |
| **Document Retention Schedule** | Privacy & legal compliance | Affects storage requirements and GDPR/NDPR compliance. | Retain identity documents for 180 days post-review, then securely archive reference. | Provisional |
| **Branch Transfer Approval Authority** | Source vs. Destination vs. Dual approval | Determines which manager approves the move. | Destination branch manager reviews and approves the transfer request. | Provisional |
| **Platform Super-Admin Scope** | Organization-wide vs. cross-tenant | Security and data isolation. | Excluded from release 1.0. Administration is strictly branch and organization-scoped. | Confirmed by PRD |
| **Network Verification Fallback** | Dynamic IPs vs. CGNAT limitations | Affects attendance check-in reliability. | When network check fails or is unavailable, check-in proceeds with `needs_review` if biometric and GPS pass. | Provisional |
