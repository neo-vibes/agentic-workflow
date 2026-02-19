# Iteration Log

## 2026-02-18 — Project Started

### Context
- Yann and Neo co-designing agentic development workflow
- Goal: Claude Code writes 100% of code, humans steer
- Based on LangChain + OpenAI harness engineering articles

### Key Insights from Research
1. AGENTS.md should be map (~100 lines), not encyclopedia
2. Repository is system of record — if it's not in repo, it doesn't exist
3. Self-verification loop is critical (Plan → Build → Test → Fix)
4. Middleware/hooks for guardrails (loop detection, time budgets, pre-completion checklist)
5. Reasoning sandwich: heavy at start/end, light in middle
6. Agent-to-agent review, minimal human blocking gates
7. Mechanical enforcement via linters (agent-generated)

### Additional Context from Yann

**Tools to research:**
- [Ralph Loop](https://github.com/snarktank/ralph) — continuous agentic loops (maybe built into Claude Code already?)
- [SonarQube MCP](https://github.com/SonarSource/sonarqube-mcp-server) — code quality (might be overkill)
- Chrome DevTools MCP — mentioned in OpenAI article for UI testing

**Design constraint:**
> "We are only 2, so let's try to have an elegant and minimalist system that produces good results!"

**What MCPs/skills might be useful?**
- File system (read/write/edit) ✓ built-in
- Git operations ✓ built-in
- Shell/terminal ✓ built-in
- Browser automation? (for testing UIs)
- Linting/formatting? (or just CLI tools)
- Test runners? (or just CLI)

**Principle:** Prefer CLI tools over heavy MCPs. Keep it simple.

### Tonight's Work Plan
- [x] Draft spec-template.md ✓
- [x] Draft principles.md ✓
- [x] Draft agents-md-template.md ✓
- [x] Write odyssey-spec.md ✓
- [ ] Review and iterate
- [ ] Research: What does Claude Code have built-in vs what needs MCPs?

---

## 2026-02-19 Morning — Documents Created

**Note:** Overnight cron jobs failed (wrong model name `claude-sonnet-4` instead of `claude-sonnet-4-5`). Created documents manually in morning session.

### Documents Created

1. **spec-template.md** — Template for defining projects for Claude Code
   - Sections: Overview, Requirements, Constraints, Architecture, Quality, Success Criteria
   - Designed to be filled out and handed to Claude Code

2. **principles.md** — Engineering principles and quality standards
   - Build-verify loop (the key pattern)
   - Context engineering (onboard the agent)
   - Architecture standards (layer structure)
   - Quality gates (TypeScript, linting, testing)
   - Guardrails (loop detection, time budgeting)
   - PR workflow
   - Minimalist tooling approach

3. **agents-md-template.md** — Template for AGENTS.md files
   - ~100 lines, map not encyclopedia
   - Quick start, structure, principles, common tasks, checklist
   - Progressive disclosure to docs/

4. **odyssey-spec.md** — Spec for Odyssey project refactor
   - Full spec following the template
   - Ready to hand to Claude Code

### Next Steps
- [ ] Review documents with Yann
- [ ] Refine based on feedback
- [ ] Test with small example or real project
- [ ] Research Claude Code built-in capabilities

---
