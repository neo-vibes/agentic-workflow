# Project Spec Template

> This template defines how we specify projects for Claude Code to build.
> Fill this out, then hand it to Claude Code with: "Build this project according to the spec."

---

## 1. Overview

**Project Name:** [name]

**One-liner:** [What does this project do in one sentence?]

**Why it matters:** [Business value, user problem solved]

---

## 2. Requirements

### Core Features
- [ ] Feature 1: [description]
- [ ] Feature 2: [description]
- [ ] Feature 3: [description]

### User Stories
```
As a [user type], I want to [action] so that [benefit].
```

### Non-Functional Requirements
- **Performance:** [latency, throughput targets]
- **Security:** [auth, data protection needs]
- **Scalability:** [expected load, growth]

---

## 3. Constraints

### Technical Constraints
- **Language:** [TypeScript, Rust, etc.]
- **Framework:** [Next.js, Fastify, etc.]
- **Database:** [PostgreSQL, SQLite, none]
- **Deployment:** [Vercel, VPS, Docker]

### Business Constraints
- **Timeline:** [when needed]
- **Budget:** [cost limits]
- **Team size:** [who will maintain this]

### Dependencies
- External APIs: [list]
- Internal services: [list]

---

## 4. Architecture Preferences

### Patterns to Follow
- [ ] [e.g., "Parse at boundaries, not in business logic"]
- [ ] [e.g., "Repository pattern for data access"]
- [ ] [e.g., "Strict TypeScript, no `any`"]

### Patterns to Avoid
- [ ] [e.g., "No ORM magic, explicit queries only"]
- [ ] [e.g., "No global state"]

### Directory Structure (if specific)
```
src/
├── types/       # Shared types
├── config/      # Configuration
├── services/    # Business logic
├── routes/      # API endpoints
└── utils/       # Helpers
```

---

## 5. Quality Standards

### Testing Requirements
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] E2E tests for critical flows (optional)
- **Coverage target:** [e.g., 80%]

### Code Quality
- [ ] ESLint with strict config
- [ ] TypeScript strict mode
- [ ] Prettier/Biome for formatting
- [ ] No `console.log` in production code

### Documentation
- [ ] README with setup instructions
- [ ] API documentation (OpenAPI/comments)
- [ ] Architecture decisions documented

---

## 6. Success Criteria

**MVP is done when:**
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

**How we'll verify:**
- [ ] All tests pass
- [ ] Manual QA of [specific flows]
- [ ] [Any other verification]

---

## 7. Out of Scope

**NOT building in this phase:**
- [Feature explicitly excluded]
- [Feature explicitly excluded]

---

## 8. References

- Design docs: [links]
- Prior art: [links]
- Related projects: [links]

---

*Template version: 1.0 — 2026-02-19*
