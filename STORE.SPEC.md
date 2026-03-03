///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.063 // WORKBOOK :: STORE.SPEC.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[COMPLETE] modified:[26.03.03] auth:[ZEN.PRO]
/// 3OX.Store marketplace product specification
```

# 3OX.Store — Product Specification

## 1) Purpose

Define the product requirements for 3OX.Store, the marketplace layer in the 3OX ecosystem, aligned to the business vision:

- Free (self-host) adoption path
- Paid marketplace for pre-built agents
- Session-based rentals for pay-per-use access
- Enterprise distribution for teams and organizations

This document specifies requirements for product, engineering, and operations implementation.

## 2) Scope

### In Scope
- Agent discovery and listing for 3OX-compatible agents
- Buyer purchase flow (one-time purchase)
- Renter flow (pay-per-session)
- Wallet/credits system with refill support
- Personality pack marketplace (`.arc`, `.spark`)
- Community submission and review pipeline
- Trust & safety controls (reviews, ratings, usage limits, policy enforcement)

### Out of Scope (v1)
- Cross-marketplace federation
- On-chain settlement requirements
- Custom enterprise legal contracting workflow implementation details

## 3) User Personas

| Persona | Primary Goal | Core Actions | Success Criteria |
|---|---|---|---|
| Builder | Create and monetize agents | Publish listing, update versions, track revenue | Agent passes review, reaches installs/rentals, receives payouts |
| Buyer | Acquire pre-built capability quickly | Evaluate listings, purchase once, self-host or run managed | Time-to-value under 30 minutes, predictable ownership cost |
| Renter | Access premium capability without full purchase | Start session, spend credits, end session | Low-friction entry, transparent session cost, reliable outcomes |

## 4) Agent Categories

3OX.Store must support these first-party categories:

1. Finance
2. Legal
3. Research
4. Creative
5. Ops
6. Personal

### Category Requirements
- A listing can have one primary category and up to two secondary categories.
- Search/filter UX must support category filtering.
- Ranking must be category-aware to avoid dominance by a single vertical.

## 5) Pricing Tiers and Monetization

| Tier | Price Model | Price Band | Access Pattern |
|---|---|---|---|
| Free | Self-host only | $0 | Builder runs own infra; no managed session billing |
| Purchase | One-time listing purchase | $20–200 | Buyer owns licensed package/version |
| Rental | Pay-per-session | $5–50 per session | Renter consumes managed runtime with credit debit |
| Enterprise | Contract pricing | Custom | Team controls, policy packs, SLA options |

### Pricing Rules
- Purchase and Rental may both be enabled on the same listing.
- Builder sets price inside allowed tier range; store validates range at publish time.
- Enterprise option is request-based and not self-checkout.

## 6) Wallet / Credits System

### 6.1 Wallet Model
- Each account has a wallet balance denominated in platform credits.
- Credits are consumed for rental sessions and premium managed inference.
- Balance must never go negative.

### 6.2 Refill Model
- Refill methods: card and supported payment rails (implementation-specific).
- Refill presets (example): $25, $50, $100, $250.
- Optional auto-refill threshold + refill amount settings.

### 6.3 Session Billing Lifecycle
1. Session start places a credit hold based on listing minimum session price.
2. Runtime usage accrues metered cost.
3. Session end settles final debit and releases unused hold.
4. Failed runtime before meaningful use triggers automatic refund.

### 6.4 User Controls
- Real-time session spend indicator.
- Hard per-session spend cap.
- Monthly spend cap.
- Low-balance alerts and pre-session insufficiency checks.

## 7) Personality Pack Marketplace (`.arc` / `.spark`)

3OX.Store must support separate listing and sale of personality packs:

- `.arc`: archetype/personality definition packs
- `.spark`: spark presets and behavior bundles

### Pack Requirements
- Pack listings must declare compatible agent versions and dependencies.
- Pack listings must declare whether they are standalone or require a base agent.
- Buyers can attach purchased packs to compatible agents post-purchase.
- Pack licensing is separate from agent licensing.

## 8) Community Contribution Model

### Submission Pipeline
1. **Submit**: Builder uploads package + manifest + metadata.
2. **Review**: Automated validation + human policy and quality review.
3. **Publish**: Approved listings become searchable/purchasable/rentable.
4. **Revenue Share**: Earnings split between creator and platform.

### Revenue Share (Default Policy)
- Creator: 70%
- Platform: 30%

### Review Gates
- Structural validity
- Policy compliance
- Safety and abuse checks
- Basic functionality verification
- Accurate pricing/category metadata

## 9) Technical Listing Requirements

A listing is publishable only if package validation passes all required checks.

### 9.1 Required `.3ox/` Structure (6 Faces)

Package must contain a valid `.3ox/` with six faces:

1. `(1)Spark` — identity/config surface
2. `(2)Brains` — persona/brain config
3. `(3)Rules` — policy and limits
4. `(4)Toolkit` — declared tool capabilities
5. `(5)Links` — routes/integration mapping
6. `(6)Pulse` — runtime entry + receipts/lifecycle surface

### 9.2 Elixir Frontmatter Requirement
- Required source docs in listing package must include valid elixir frontmatter metadata block.
- Frontmatter validity checks include required status/version/date/auth fields.
- Files that use the imprint system must include the imprint banner format.

### 9.3 Required Publish-Time Validation
- Schema validation for listing metadata.
- Package integrity/hash validation.
- Category and pricing tier validation.
- Dependency/compatibility validation (including `.arc`/`.spark` packs).
- Malware/security scanning and restricted operation checks.

## 10) Trust and Safety Requirements

### 10.1 Reviews and Ratings
- 1–5 star ratings with written review option.
- Verified-purchase and verified-rental badges.
- Anti-manipulation checks (duplicate account and spam review detection).

### 10.2 Usage Limits
- Per-session request limits by tier.
- Daily/monthly usage throttles for abusive behavior.
- Automatic cooldown and escalation on repeated violations.

### 10.3 Content Policy
- Listings must not include malicious payloads, fraud tooling, or prohibited harmful content.
- Category-specific compliance checks (e.g., finance/legal disclaimers).
- Report flow for users with triage SLA and enforcement outcomes:
  - warning
  - listing suspension
  - account suspension

## 11) Example Listings (v1)

| Listing | Type | Category | Pricing Modes | Notes |
|---|---|---|---|---|
| Tax Agent | Full Agent | Finance | Purchase + Rental | Tax prep workflow support, compliance disclaimers required |
| Research Agent | Full Agent | Research | Purchase + Rental | Multi-source summarization and citation-oriented workflows |
| Budget Agent (Money.Bagz) | Full Agent | Finance / Personal | Free (self-host) + Purchase + Rental | Existing ecosystem-aligned budgeting assistant profile |
| VSO Agent | Full Agent | Ops / Personal | Purchase + Rental + Enterprise | Veteran claims support workflow specialization |

## 12) Functional Requirements Matrix

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Support Builder, Buyer, and Renter personas with dedicated flows | P0 |
| FR-02 | Support six required agent categories | P0 |
| FR-03 | Enforce tier pricing bands (free, purchase, rental, enterprise) | P0 |
| FR-04 | Provide wallet credits with refill and session settlement | P0 |
| FR-05 | Support separate `.arc` and `.spark` marketplace listings | P0 |
| FR-06 | Implement submit → review → publish → revenue share pipeline | P0 |
| FR-07 | Reject listings without valid `.3ox/` six-face structure | P0 |
| FR-08 | Enforce elixir frontmatter + imprint policy for required files | P1 |
| FR-09 | Provide ratings/reviews, usage limits, and policy enforcement | P0 |
| FR-10 | Launch with four seed example listings in catalog | P1 |

## 13) Launch Acceptance Criteria (Spec Complete)

- All required personas and category model are defined.
- Pricing tiers are defined with exact required ranges.
- Wallet/credits and refill mechanics are defined with session settlement flow.
- Personality pack marketplace behavior for `.arc` and `.spark` is specified.
- Community contribution workflow with review + revenue share is specified.
- Technical listing gate explicitly requires valid `.3ox/` six-face structure and elixir frontmatter compliance.
- Trust and safety controls include reviews, ratings, usage limits, and content policy.
- Example listings include Tax Agent, Research Agent, Budget Agent (Money.Bagz), and VSO Agent.

:: ∎
