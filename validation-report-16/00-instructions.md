# Validation Report Instructions

## Your Task
Analyze this report to validate if the AI reviewer changes in `add-react-compiler-context-to-ai-reviewer` branch work correctly.

## Key Things to Check

### 1. Did Claude use `checkReactCompilerOptimization.sh`?
- Search in `04-fork-report.json` for: `checkReactCompilerOptimization`
- If NOT found - this is a BUG. Claude should check React Compiler context before flagging PERF-4

### 2. PERF-4 Decision Flow - Was it followed correctly?
The correct flow is:
1. Is child memoized? (check `"optimized": true` or `memo(`)
   - If NO → Skip PERF-4 (memoizing props won't help)
2. Is parent optimized by React Compiler?
   - If YES (`"optimized": true`) → Skip PERF-4 (compiler auto-memoizes)
   - If NO → Flag PERF-4 (programmer must memoize manually)

### 3. Compare with Original Review
- Look at `05-original-comments.md` for original Claude comments
- Did original Claude incorrectly flag PERF-4?
- Did humans reject those comments? Look for responses like:
  - "React Compiler handles this"
  - "not needed"
  - "compiler optimizes this"
  - "unnecessary"
- Did the new version (in `03-fork-comments.md`) fix this problem?

### 4. False Positives / False Negatives
- **False Positive**: Claude flagged something that shouldn't be flagged
- **False Negative**: Claude missed something that should be flagged

## Report Files
- `01-rule-changes.diff` - Changes to .claude/ folder (the rules being tested)
- `02-pr-diff.diff` - The PR code being reviewed
- `03-fork-comments.md` - Review output from YOUR fork (new rules)
- `04-fork-report.json` - Full Claude execution report (check tool usage!)
- `05-original-comments.md` - Review from ORIGINAL PR (old rules + human responses)

## Expected Outcome
After your changes, Claude should:
1. Always call `checkReactCompilerOptimization.sh` before PERF-4 analysis
2. NOT flag PERF-4 when parent is optimized by React Compiler
3. Only flag PERF-4 when parent is NOT compiled AND child IS memoized
