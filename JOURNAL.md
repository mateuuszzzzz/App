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
