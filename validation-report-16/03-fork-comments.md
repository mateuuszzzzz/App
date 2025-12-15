# Review from Fork (New Rules)
Repo: mateuuszzzzz/App#16

## PR Comments


## Inline Review Comments

### github-actions[bot] at 2025-12-15T12:38:49Z
File: src/pages/TeachersUnite/useSaveTheWorldSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const useSaveTheWorldSectionIllustration: UseSaveTheWorldSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['SaveTheWorldScale'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.SaveTheWorldScale,
            illustrationStyle: styles.saveTheWorldStaticIllustration,
        }),
        [illustrations.SaveTheWorldScale, styles.saveTheWorldStaticIllustration],
    );
};
```

### github-actions[bot] at 2025-12-15T12:38:51Z
File: src/pages/settings/AboutPage/useAboutSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const useAboutSectionIllustration: UseAboutSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['TiltedCoinExpensify'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.TiltedCoinExpensify,
            illustrationStyle: styles.aboutStaticIllustration,
        }),
        [illustrations.TiltedCoinExpensify, styles.aboutStaticIllustration],
    );
};
```

### github-actions[bot] at 2025-12-15T12:38:53Z
File: src/pages/settings/Preferences/usePreferencesSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const usePreferencesSectionIllustration: UsePreferencesSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['DjBoothReferenceHands'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.DjBoothReferenceHands,
            illustrationStyle: styles.preferencesStaticIllustration,
        }),
        [illustrations.DjBoothReferenceHands, styles.preferencesStaticIllustration],
    );
};
```

### github-actions[bot] at 2025-12-15T12:38:54Z
File: src/pages/settings/Security/useSecuritySettingsSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const useSecuritySettingsSectionIllustration: UseSecuritySettingsSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['Safe'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.Safe,
            illustrationStyle: styles.securitySettingsStaticIllustration,
        }),
        [illustrations.Safe, styles.securitySettingsStaticIllustration],
    );
};
```

### github-actions[bot] at 2025-12-15T12:38:56Z
File: src/pages/settings/Troubleshoot/useTroubleshootSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const useTroubleshootSectionIllustration: UseTroubleshootSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['WorkspaceScene'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.WorkspaceScene,
            illustrationStyle: styles.troubleshootStaticIllustration,
        }),
        [illustrations.WorkspaceScene, styles.troubleshootStaticIllustration],
    );
};
```

### github-actions[bot] at 2025-12-15T12:38:58Z
File: src/pages/settings/Wallet/WalletPage/useWalletSectionIllustration/index.ts:9

### ❌ PERF-4 [(docs)](https://github.com/Expensify/App/blob/main/.claude/agents/code-inline-reviewer.md#perf-4-memoize-objects-and-functions-passed-as-props)

The object returned from this hook creates a new object instance on every render, which breaks memoization of the `Section` component (optimized by React Compiler) when used in non-optimized parent components.

**Fix**: Wrap the return value with `useMemo`:

```typescript
import {useMemo} from 'react';

const useWalletSectionIllustration: UseWalletSectionIllustration = () => {
    const illustrations = useMemoizedLazyIllustrations(['BigVault'] as const);
    const styles = useThemeStyles();

    return useMemo(
        () => ({
            illustration: illustrations.BigVault,
            illustrationStyle: styles.walletStaticIllustration,
        }),
        [illustrations.BigVault, styles.walletStaticIllustration],
    );
};
```

