# Review from Fork (New Rules)
Repo: mateuuszzzzz/App#18

## PR Comments


## Inline Review Comments

### github-actions[bot] at 2025-12-15T13:28:17Z
File: src/pages/home/report/ReportActionCompose/AttachmentPickerWithMenuItems.tsx:523

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The inline object literal `{horizontal: 0, vertical: 0}` creates a new object reference on every render, which breaks the memoization of the `PopoverMenu` component.

**Suggested fix:**
```tsx
// At the top of the component with other useMemo declarations
const defaultAnchorPosition = useMemo(() => ({horizontal: 0, vertical: 0}), []);

// Then use it in the JSX
anchorPosition={popoverAnchorPosition ?? defaultAnchorPosition}
```

This ensures that when `popoverAnchorPosition` is undefined, a stable reference is passed to the memoized child component, preventing unnecessary re-renders.

