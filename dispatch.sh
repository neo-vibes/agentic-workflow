#!/bin/bash
# dispatch.sh - Orchestrate sub-agents from tasks.json
# Usage: ./dispatch.sh tasks.json [--dry-run]

set -e

TASKS_FILE="${1:-tasks.json}"
DRY_RUN="${2:-}"
WORK_DIR="../worktrees"
STATE_FILE="task-state.json"
MAX_PARALLEL=3
POLL_INTERVAL=30

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[dispatch]${NC} $1"; }
warn() { echo -e "${YELLOW}[dispatch]${NC} $1"; }
error() { echo -e "${RED}[dispatch]${NC} $1"; }

# Parse tasks.json
init_state() {
  log "Initializing from $TASKS_FILE"
  
  # Create initial state
  jq '{
    project: .project,
    tasks: [.tasks[] | {
      id: .id,
      name: .name,
      deps: .deps,
      status: "pending",
      branch: ("feat/" + .id),
      worktree: null,
      pid: null,
      startedAt: null,
      completedAt: null
    }],
    mergeOrder: .mergeOrder
  }' "$TASKS_FILE" > "$STATE_FILE"
  
  log "Created $STATE_FILE with $(jq '.tasks | length' $STATE_FILE) tasks"
}

# Get tasks ready to run (deps satisfied, not running/done)
get_runnable() {
  jq -r '
    .tasks as $all |
    .tasks[] |
    select(.status == "pending") |
    select(
      (.deps | length == 0) or
      (reduce .deps[] as $dep (true; . and ($all[] | select(.id == $dep) | .status == "done")))
    ) |
    .id
  ' "$STATE_FILE"
}

# Get count of running tasks
running_count() {
  jq '[.tasks[] | select(.status == "running")] | length' "$STATE_FILE"
}

# Create worktree and prompt for a task
setup_task() {
  local task_id="$1"
  local branch="feat/$task_id"
  local worktree="$WORK_DIR/$task_id"
  
  log "Setting up task: $task_id"
  
  # Get task details
  local task_json=$(jq ".tasks[] | select(.id == \"$task_id\")" "$TASKS_FILE")
  local prompt=$(echo "$task_json" | jq -r '.prompt')
  local acceptance=$(echo "$task_json" | jq -r '.acceptance | map("- " + .) | join("\n")')
  local max_iter=$(echo "$task_json" | jq -r '.estimatedIterations // 20')
  
  # Create worktree
  if [ -d "$worktree" ]; then
    warn "Worktree exists, removing: $worktree"
    git worktree remove "$worktree" --force 2>/dev/null || rm -rf "$worktree"
  fi
  
  git worktree add "$worktree" -b "$branch" 2>/dev/null || \
    git worktree add "$worktree" "$branch"
  
  # Create task-logs directory
  mkdir -p "$worktree/task-logs"
  
  # Write PROMPT-build.md
  cat > "$worktree/PROMPT-build.md" << EOF
# Task: $(echo "$task_json" | jq -r '.name')

## What to Build
$prompt

## Acceptance Criteria
$acceptance

## Rules
Read AGENTS.md for coding standards.

## Context (read first)
- task-logs/notes.md — your notes from previous iterations
- task-logs/test-output.log — last test results
- git status / git diff — current state

## Instructions
1. Read context files above
2. Implement the requirements
3. Write tests
4. Run: pnpm test 2>&1 | tee task-logs/test-output.log
5. Update task-logs/notes.md with progress/blockers
6. If all acceptance criteria met and tests pass:
   Output <promise>BUILD_DONE</promise>

## Loop Detection
If same error 3+ times, try a different approach.
If stuck after 10 iterations, document blockers in notes.md.
EOF

  # Write PROMPT-polish.md
  cat > "$worktree/PROMPT-polish.md" << EOF
# Polish: $(echo "$task_json" | jq -r '.name')

The feature is working. Now clean it up.

## Checklist
- [ ] pnpm lint passes
- [ ] pnpm build passes (no type errors)
- [ ] Remove verbose debug logs (keep meaningful ones)
- [ ] Improve variable/function naming if needed
- [ ] No TODOs left in code
- [ ] Coverage > 80%

## Context
- Read task-logs/notes.md for what was built
- Run pnpm lint, pnpm build to check status

When all checks pass: <promise>POLISH_DONE</promise>
EOF

  # Initialize notes.md
  cat > "$worktree/task-logs/notes.md" << EOF
# Task Notes: $task_id

## Iteration Log
<!-- Agent updates this each iteration -->

## Blockers
<!-- Document any blockers here -->

## Decisions Made
<!-- Document key decisions -->
EOF

  # Update state
  jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {
    worktree: \"$worktree\",
    status: \"ready\"
  }" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
  
  log "Task $task_id ready at $worktree"
}

# Run Ralph loops for a task
run_task() {
  local task_id="$1"
  local worktree="$WORK_DIR/$task_id"
  local max_iter=$(jq -r ".tasks[] | select(.id == \"$task_id\") | .estimatedIterations // 20" "$TASKS_FILE")
  
  log "Starting task: $task_id"
  
  # Update state to running
  jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {
    status: \"running\",
    startedAt: \"$(date -Iseconds)\"
  }" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
  
  # Run in background
  (
    cd "$worktree"
    
    # Phase 1: Build
    log "[$task_id] Phase 1: Build"
    
    # Check if claude is available
    if ! command -v claude &> /dev/null; then
      error "Claude Code CLI not found. Install with: npm install -g @anthropic-ai/claude-code"
      touch task-logs/BUILD_FAILED
      exit 1
    fi
    
    cat PROMPT-build.md | claude --max-turns $((max_iter * 2)) 2>&1 | tee task-logs/build.log
    
    if grep -q "BUILD_DONE" task-logs/build.log; then
      # Phase 2: Polish
      log "[$task_id] Phase 2: Polish"
      cat PROMPT-polish.md | claude --max-turns 20 2>&1 | tee task-logs/polish.log
      
      if grep -q "POLISH_DONE" task-logs/polish.log; then
        # Success - create PR
        git add -A
        git commit -m "feat($task_id): implementation complete"
        git push -u origin "feat/$task_id"
        gh pr create --title "feat($task_id): $(jq -r ".tasks[] | select(.id == \"$task_id\") | .name" "$TASKS_FILE")" \
                     --body "Auto-generated by dispatch.sh"
        touch task-logs/SUCCESS
      else
        touch task-logs/POLISH_FAILED
      fi
    else
      touch task-logs/BUILD_FAILED
    fi
  ) &
  
  local pid=$!
  
  # Record PID
  jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {pid: $pid}" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
  
  log "Task $task_id running with PID $pid"
}

# Check task completion
check_task() {
  local task_id="$1"
  local worktree="$WORK_DIR/$task_id"
  
  if [ -f "$worktree/task-logs/SUCCESS" ]; then
    jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {
      status: \"done\",
      completedAt: \"$(date -Iseconds)\"
    }" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
    log "Task $task_id: DONE ✓"
    return 0
  elif [ -f "$worktree/task-logs/BUILD_FAILED" ]; then
    jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {status: \"failed\"}" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
    error "Task $task_id: BUILD FAILED"
    return 1
  elif [ -f "$worktree/task-logs/POLISH_FAILED" ]; then
    jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {status: \"failed\"}" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
    error "Task $task_id: POLISH FAILED"
    return 1
  fi
  
  # Still running
  return 2
}

# Main orchestration loop
orchestrate() {
  log "Starting orchestration"
  
  while true; do
    # Check running tasks
    for task_id in $(jq -r '.tasks[] | select(.status == "running") | .id' "$STATE_FILE"); do
      check_task "$task_id" || true
    done
    
    # Check if all done
    local pending=$(jq '[.tasks[] | select(.status == "pending" or .status == "ready" or .status == "running")] | length' "$STATE_FILE")
    if [ "$pending" -eq 0 ]; then
      log "All tasks complete!"
      break
    fi
    
    # Check for failures
    local failed=$(jq '[.tasks[] | select(.status == "failed")] | length' "$STATE_FILE")
    if [ "$failed" -gt 0 ]; then
      error "Some tasks failed. Check task-state.json"
      jq '.tasks[] | select(.status == "failed") | .id' "$STATE_FILE"
      break
    fi
    
    # Launch runnable tasks (up to MAX_PARALLEL)
    local running=$(running_count)
    for task_id in $(get_runnable); do
      if [ "$running" -ge "$MAX_PARALLEL" ]; then
        break
      fi
      
      setup_task "$task_id"
      
      if [ -z "$DRY_RUN" ]; then
        run_task "$task_id"
      else
        log "[dry-run] Would run: $task_id"
        jq "(.tasks[] | select(.id == \"$task_id\")) |= . + {status: \"done\"}" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
      fi
      
      running=$((running + 1))
    done
    
    # Wait before next poll
    if [ -z "$DRY_RUN" ]; then
      sleep "$POLL_INTERVAL"
    fi
  done
}

# Merge PRs in order
merge_prs() {
  log "Merging PRs in order"
  
  for task_id in $(jq -r '.mergeOrder[]' "$STATE_FILE"); do
    local status=$(jq -r ".tasks[] | select(.id == \"$task_id\") | .status" "$STATE_FILE")
    if [ "$status" == "done" ]; then
      log "Merging: feat/$task_id"
      gh pr merge "feat/$task_id" --squash --delete-branch || warn "Could not merge feat/$task_id"
    fi
  done
}

# Cleanup worktrees
cleanup() {
  log "Cleaning up worktrees"
  for worktree in "$WORK_DIR"/*; do
    if [ -d "$worktree" ]; then
      git worktree remove "$worktree" --force 2>/dev/null || true
    fi
  done
}

# Main
main() {
  if [ ! -f "$TASKS_FILE" ]; then
    error "Tasks file not found: $TASKS_FILE"
    exit 1
  fi
  
  init_state
  orchestrate
  
  if [ -z "$DRY_RUN" ]; then
    merge_prs
    cleanup
  fi
  
  log "Done!"
  jq '.tasks[] | {id, status}' "$STATE_FILE"
}

main
