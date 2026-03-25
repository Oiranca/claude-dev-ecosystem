---
name: Worktree cleanup after every session
description: Always delete local worktree-agent-* branches and prune worktrees at the end of every session, across all repos
type: feedback
---

At the end of every session that used agents with `isolation: "worktree"`, always run:

```bash
git worktree prune
rm -rf .claude/worktrees/
git branch | grep 'worktree-agent' | xargs git branch -D
```

**Why:** Worktree branches accumulate locally across sessions. They should never be pushed to remote and must be cleaned up locally when the session ends.

**How to apply:** Run this cleanup at the end of any session that spawned implementation agents in any repo, not just when explicitly asked.
