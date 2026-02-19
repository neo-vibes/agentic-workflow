# Odyssey Project Spec

> Spec for Claude Code to rebuild/refactor the Odyssey (agentic-wallet) project.

---

## 1. Overview

**Project Name:** Odyssey

**One-liner:** Time-boxed spending sessions for AI agents on Solana.

**Why it matters:** AI agents need to spend money (swaps, payments, subscriptions) but users don't want to give full wallet access. Odyssey lets users approve limited, time-boxed sessions where agents can spend up to a defined limit.

---

## 2. Requirements

### Core Features
- [ ] **Wallet creation via passkey** — User creates wallet using WebAuthn (Face ID, fingerprint)
- [ ] **Session requests** — Agent requests a spending session (amount, duration)
- [ ] **User approval** — User approves/rejects via Telegram bot + passkey signature
- [ ] **Session execution** — Agent can spend within limits during session
- [ ] **SOL transfers** — Agent can send SOL to any address
- [ ] **SPL token transfers** — Agent can send tokens
- [ ] **Generic transaction signing** — Agent can submit arbitrary transactions (for Jupiter, DFlow, etc.)

### User Stories
```
As a user, I want to approve spending limits for my AI agent so that it can trade on my behalf without full wallet access.

As an AI agent, I want to request a spending session so that I can execute transactions within approved limits.

As a user, I want to see what my agent is spending so that I maintain oversight.
```

### Non-Functional Requirements
- **Performance:** Transaction submission < 2s
- **Security:** Passkey-based auth, on-chain session verification, spending limits enforced on-chain
- **Scalability:** Support 1000+ concurrent sessions

---

## 3. Constraints

### Technical Constraints
- **Language:** TypeScript (API, bot), Rust (Solana program)
- **Framework:** Fastify (API), Grammy (Telegram bot)
- **Database:** JSON files for MVP (upgrade to PostgreSQL later)
- **Blockchain:** Solana (devnet for testing, mainnet for production)
- **Deployment:** VPS with systemd services

### Business Constraints
- **Timeline:** MVP exists, needs cleanup and proper structure
- **Team size:** 2 people (Yann + Neo reviewing)
- **Budget:** Minimize RPC costs, use devnet for testing

### Dependencies
- Solana RPC (Helius for production)
- Telegram Bot API
- Lazorkit program (forked, custom)

---

## 4. Architecture Preferences

### Patterns to Follow
- [ ] Parse at boundaries — Validate all API inputs with Zod
- [ ] Explicit types — No `any`, strict TypeScript
- [ ] Separation of concerns — Routes are thin, services have logic
- [ ] On-chain source of truth — Server state is cache, chain is truth

### Patterns to Avoid
- [ ] No ORM — Direct Solana RPC calls
- [ ] No global state — Pass dependencies explicitly
- [ ] No 3000-line files — Split by domain

### Directory Structure
```
packages/
├── api/
│   ├── src/
│   │   ├── types/          # Zod schemas, TypeScript types
│   │   ├── config/         # Environment, constants
│   │   ├── services/       # Business logic
│   │   │   ├── wallet.ts
│   │   │   ├── session.ts
│   │   │   ├── transfer.ts
│   │   │   └── solana.ts
│   │   ├── routes/         # Fastify route handlers
│   │   │   ├── pairing.ts
│   │   │   ├── session.ts
│   │   │   └── transfer.ts
│   │   ├── pages/          # HTML templates
│   │   └── index.ts        # App setup only
│   └── tests/
├── bot/
│   ├── src/
│   │   ├── commands/       # Bot command handlers
│   │   ├── callbacks/      # Inline button handlers
│   │   └── index.ts
│   └── tests/
└── shared/
    └── src/
        └── types/          # Shared types between packages
```

---

## 5. Quality Standards

### Testing Requirements
- [ ] Unit tests for services (wallet, session, transfer)
- [ ] Integration tests for API routes
- [ ] E2E test: create wallet → request session → approve → transfer
- **Coverage target:** 80% for services

### Code Quality
- [ ] ESLint strict config
- [ ] TypeScript strict mode
- [ ] Biome for formatting
- [ ] No `console.log` in production (use proper logger)

### Documentation
- [ ] README with setup instructions
- [ ] API documentation (endpoint list with examples)
- [ ] Architecture doc explaining the flow

---

## 6. Success Criteria

**Refactor is done when:**
- [ ] No file exceeds 500 lines
- [ ] All API inputs validated with Zod
- [ ] 80% test coverage on services
- [ ] Can run full flow: wallet create → session → transfer
- [ ] ESLint passes with zero warnings
- [ ] TypeScript strict mode with no `any`

**How we'll verify:**
- [ ] All tests pass
- [ ] Manual test of complete flow
- [ ] Neo reviews PR against this spec

---

## 7. Out of Scope

**NOT building in this phase:**
- Mobile app (Telegram only for now)
- Multi-chain support (Solana only)
- Database migration (keep JSON files for now)
- Mainnet deployment (devnet only)
- Jupiter/DFlow integration (generic sign-and-send is enough)

---

## 8. References

- Current repo: `github.com/polarislabxyz/agentic-wallet`
- Lazorkit (upstream): `github.com/phasewalk1/Lazor-Kit`
- Solana Web3.js docs
- Grammy (Telegram) docs

---

*Spec version: 1.0 — 2026-02-19*
