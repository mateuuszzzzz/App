# AI Reviewer Development Journal

Dziennik przypadków testowych i wniosków z pracy nad AI reviewerem.

---

## Case #1: PR #76336 - Replace Lottie animations with static images

**Data:** 2025-12-15

**Test PR:** mateuuszzzzz/App#14

**Branch z regułami:** `add-react-compiler-context-to-ai-reviewer`

### Kontekst

PR dodaje hooki `use*SectionIllustration` które zwracają obiekty bez memoizacji:
```tsx
const useSaveTheWorldSectionIllustration = () => {
    return {
        illustration: LottieAnimations.SaveTheWorld,
    };
};
```

### Oryginalny review (stare reguły)

- Claude flagował **12 razy PERF-4** na wszystkich hookach
- Sugerował dodanie `useMemo`

### Reakcja człowieka

@fabioh8010 odrzucił wszystkie komentarze:
> "Since I'm just spreading the object props into Section component, we don't need to memoize anything. Even if I decide to not spread I would use each prop as direct assign e.g. `illustration={saveTheWorldIllustration.illustration}`, so we still wouldn't need memoization."

**Wniosek:** Oryginalne PERF-4 były **fałszywymi pozytywami**.

### Nowy review (nowe reguły)

- Claude **nie flagował** PERF-4
- Dał 👍 i zakończył

### Analiza - co poszło dobrze

- Brak fałszywych pozytywów (poprawny wynik)

### Analiza - co poszło źle

1. **`checkReactCompilerOptimization.sh` nie został użyty**
   - Reviewer powinien sprawdzić kontekst React Compiler przed decyzją o PERF-4
   - Nigdy nie wywołał tego narzędzia

2. **Reviewer nie przeczytał nowych plików**
   - Grepował za wzorcami `useMemo|useCallback|React.memo|memo(`
   - Nowe hooki nie zawierają tych wzorców (bo właśnie ich brakuje!)
   - Więc reviewer ich "nie zauważył"

3. **Poprawny wynik, ale z niewłaściwego powodu**
   - Reviewer przypadkowo nie flagował
   - Nie wykonał decision flow z instrukcji PERF-4

### Root cause

**Search patterns są źle zdefiniowane.**

Reguła szuka plików które JUŻ używają memoizacji, zamiast szukać sytuacji gdzie memoizacja MOGŁABY być potrzebna (obiekty/funkcje przekazywane jako props do memoizowanych dzieci).

### Propozycje naprawy

1. **Zmienić search patterns dla PERF-4**
   - Zamiast szukać `useMemo|useCallback`
   - Szukać wzorców typu: `return {`, `return ()`, przekazywanie obiektów jako props

2. **Dodać instrukcję "przeczytaj nowe pliki"**
   - Nowe pliki nie będą pasować do grepów na istniejące wzorce
   - Trzeba je przeczytać żeby znaleźć brakujące wzorce

3. **Wymusić użycie `checkReactCompilerOptimization.sh`**
   - Dodać jako MANDATORY FIRST STEP w PERF-4
   - Bez tego nie można podjąć decyzji o flagowaniu

---

## Case #2: PR #76277 - Add Concierge to Side Panel

**Data:** 2025-12-15

**Test PR:** mateuuszzzzz/App#18

**Branch z regułami:** `add-react-compiler-context-to-ai-reviewer`

### Kontekst

Duży PR (1000+ linii) dodający Concierge chat do Side Panel. Oryginalny review flagował 4 PERF-4 violations.

### Oryginalny review (stare reguły)

Flagowano 4 pliki:
1. `SidePanelButtonBase.tsx:27` - inline style array
2. `SidePanelOverlay.tsx:27` - inline style array
3. `HeaderView.tsx:275` - inline style array
4. `AttachmentPickerWithMenuItems.tsx:523` - inline object `{horizontal: 0, vertical: 0}`

### Reakcja człowieka

Wszystkie 4 komentarze zostały **odrzucone** (nie widać bezpośredniej odpowiedzi, ale brak reakcji = ignorowane jako false positives w kontekście React Compiler).

### Nowy review (nowe reguły)

**Claude flagował tylko 1 PERF-4:**
- `AttachmentPickerWithMenuItems.tsx:523` - inline object `{horizontal: 0, vertical: 0}`

### Analiza - co poszło dobrze

1. **Script `checkReactCompilerOptimization.sh` został użyty!**
   ```json
   {
     "that (this file)": {"optimized": false},
     "PopoverMenu": {"optimized": true}
   }
   ```

2. **Poprawna analiza:**
   - Parent (`AttachmentPickerWithMenuItems`) = NOT optimized
   - Child (`PopoverMenu`) = optimized by React Compiler
   - Decision: Flag PERF-4 (parent not compiled, child is memoized)

3. **Zredukowano z 4 false positives do 1 potential issue**
   - 3 inne violations (SidePanelButtonBase, SidePanelOverlay, HeaderView) nie zostały flagowane

### Analiza - czy ta 1 flaga jest correct?

**Pytanie:** Czy `AttachmentPickerWithMenuItems.tsx:523` to prawdziwy issue?

**Kod (z PR diff):**
```tsx
// OLD:
anchorPosition={styles.createMenuPositionReportActionCompose(shouldUseNarrowLayout, windowHeight, windowWidth)}

// NEW:
anchorPosition={popoverAnchorPosition ?? {horizontal: 0, vertical: 0}}
```

**Kontekst:**
- `popoverAnchorPosition` to state (`useState`) ustawiany w `useEffect` gdy menu się pokazuje
- Fallback `{horizontal: 0, vertical: 0}` używany jest tylko gdy state jest `null`:
  - Początkowo przed pokazaniem menu
  - Przez chwilę podczas async kalkulacji pozycji

**Fakty:**
- Parent `AttachmentPickerWithMenuItems` = NOT optimized by React Compiler
- Child `PopoverMenu` = optimized (ma `memo()`)
- Inline object tworzy nową referencję przy każdym renderze

**Czy to hot path?**
- `AttachmentPickerWithMenuItems` jest w `ReportActionCompose` = renderuje się na każdym report screen
- ALE inline object wpływa tylko gdy `popoverAnchorPosition` jest null
- Popover pokazuje się tylko gdy user kliknie przycisk attachment (user-triggered)

**Werdykt:** **VALID PERF-4, ale LOW IMPACT**
- Technicznie poprawne - nowa referencja może spowodować niepotrzebny re-render
- W praktyce - minimalny wpływ bo fallback używany tylko przez chwilę
- Fix jest trywialny: `const DEFAULT_ANCHOR = {horizontal: 0, vertical: 0}`

### Dlaczego ludzie dali thumbdown na wszystkie 4?

Sprawdziłem reactions przez GitHub API - wszystkie 4 PERF-4 dostały `-1`:
```json
SidePanelButtonBase.tsx:27 → -1
SidePanelOverlay.tsx:27 → -1
HeaderView.tsx:275 → -1
AttachmentPickerWithMenuItems.tsx:523 → -1
```

**Prawdopodobny powód:** Blanket rejection
- "Mamy React Compiler, nie potrzebujemy ręcznej memoizacji"
- Nie chcieli dodawać boilerplate'u
- Nie sprawdzili które pliki są faktycznie compiled

**Ocena reakcji:**
- 3 thumbdowns **POPRAWNE** (React Compiler obsługuje te pliki)
- 1 thumbdown **DYSKUSYJNA** (AttachmentPickerWithMenuItems NIE jest compiled, ale issue jest low-impact)

### Wynik Case #2

| Metryka | Wartość |
|---------|---------|
| Original false positives | 4 |
| New false positives | 0 |
| New true positives | 1 (low-impact) |
| Script used | YES |

**Sukces!** Nowe reguły:
1. Używają `checkReactCompilerOptimization.sh`
2. Poprawnie eliminują false positives dla compiled components
3. Wykrywają prawdziwe issues dla non-compiled components

**Obszar do poprawy:** Czy powinniśmy flagować low-impact issues?
- Może dodać heurystykę "czy to hot path"?
- Może dodać severity level do komentarzy?

---
