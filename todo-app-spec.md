# React Native Todo App — Spec

> Test project for validating the agentic harness workflow.

## Overview

Minimal, elegant todo list app for iOS/Android. Focus on clean code, proper architecture, and full test coverage.

## Goals

1. Validate harness workflow end-to-end
2. Test sub-agent orchestration with dependencies
3. Ensure polish phase catches quality issues

---

## Requirements

### Functional

| Feature | Description |
|---------|-------------|
| Add todo | User types title, presses add |
| Toggle complete | Tap todo to mark done/undone |
| Delete todo | Swipe or long-press to delete |
| Filter | View all / active / completed |
| Persist | Data survives app restart |
| Clear completed | Button to remove all done items |

### Non-Functional

| Requirement | Target |
|-------------|--------|
| Performance | List scrolls at 60fps with 100+ items |
| Accessibility | VoiceOver/TalkBack compatible |
| Offline | Works fully offline (local storage) |

---

## Design

### Visual Style

- **Minimalist** — white background, clean typography
- **Touch-friendly** — large tap targets (48px min)
- **Subtle feedback** — animations on add/delete/toggle

### Colors

```
Background: #FFFFFF
Text: #1A1A1A
Completed text: #9CA3AF (gray)
Primary: #3B82F6 (blue)
Danger: #EF4444 (red, delete)
```

### Layout

```
┌─────────────────────────┐
│  📝 Todos               │  ← Header
├─────────────────────────┤
│ [________________] [+]  │  ← Input
├─────────────────────────┤
│  All | Active | Done    │  ← Filter tabs
├─────────────────────────┤
│ ○ Buy groceries         │  ← Todo item
│ ● Walk the dog     ──── │  ← Completed (strikethrough)
│ ○ Read a book           │
│ ○ ...                   │
├─────────────────────────┤
│ 3 items left | Clear ✓  │  ← Footer
└─────────────────────────┘
```

---

## Technical

### Stack

- React Native (Expo or bare)
- TypeScript strict
- AsyncStorage for persistence
- Vitest for unit tests
- React Native Testing Library for component tests

### Architecture

```
src/
├── types/
│   └── index.ts          # Todo, Filter types
├── services/
│   └── storage.ts        # AsyncStorage wrapper
├── hooks/
│   └── useTodos.ts       # State management
├── components/
│   ├── TodoItem.tsx
│   ├── TodoInput.tsx
│   └── FilterBar.tsx
├── screens/
│   └── MainScreen.tsx
└── utils/
    └── logger.ts         # Logging utility
```

### Data Model

```typescript
interface Todo {
  id: string;           // UUID
  title: string;        // User input, trimmed
  completed: boolean;   // Toggle state
  createdAt: number;    // Timestamp
}

type Filter = 'all' | 'active' | 'completed';
```

---

## Test Plan

### Unit Tests

| Module | Tests |
|--------|-------|
| storage.ts | save/load empty, save/load with data, handle errors |
| useTodos.ts | add, toggle, delete, filter, clear completed |

### Component Tests

| Component | Tests |
|-----------|-------|
| TodoItem | renders, tap toggles, shows completed style |
| TodoInput | types text, submits on button, clears after add |
| FilterBar | shows all tabs, tap changes filter |

### Integration Tests

| Flow | Steps |
|------|-------|
| Add flow | Open app → type "Test" → tap add → see in list |
| Complete flow | Add todo → tap it → shows completed → tap again → uncompleted |
| Persist flow | Add todos → kill app → reopen → todos still there |
| Filter flow | Add 3 todos → complete 1 → filter active → see 2 |

---

## Acceptance Criteria

### Must Have (MVP)
- [ ] Add, toggle, delete todos
- [ ] Filter by all/active/completed
- [ ] Persist to local storage
- [ ] TypeScript strict, no `any`
- [ ] Tests pass, coverage > 80%
- [ ] Lint passes

### Nice to Have
- [ ] Animations on add/delete
- [ ] Haptic feedback on toggle
- [ ] Swipe to delete gesture
- [ ] Keyboard dismiss on scroll

---

## Out of Scope

- User accounts / auth
- Cloud sync
- Multiple lists
- Due dates / reminders
- Push notifications

---

## Success Metrics

For harness validation:
1. **Tasks complete autonomously** — minimal human intervention
2. **Dependencies respected** — tasks run in correct order
3. **Quality gate works** — polish phase catches issues
4. **PRs merge cleanly** — no conflicts

---

*Spec version: 1.0 — 2026-02-19*
