# HomeWallet F-01 Data Schema & Persistence — Plan Brief

> Full plan: `context/changes/data-schema-and-persistence/plan.md`

## What & Why

Implementujemy fundament persistence dla HomeWallet: pełny model danych, migracje i polityki RLS dla portfela ownera, template’ów, budżetów miesięcznych i wydatków. To odblokowuje wszystkie kolejne slice’y (S-01..S-04) i zabezpiecza dwa kluczowe wymagania PRD: trwałość danych i poprawność obliczeń finansowych.

## Starting Point

Projekt ma działające Astro SSR + Supabase auth, ale brak tabel domenowych i brak migracji dla logiki budżetowej. F-01 startuje praktycznie od zera po stronie schematu, przy zachowaniu istniejącego wzorca tożsamości użytkownika z middleware.

## Desired End State

Po wdrożeniu istnieje wersjonowany schemat SQL obejmujący wallet, template, monthly budget, kategorię, recurring expense, savings goal i expense. Dane są izolowane owner-only przez RLS, a historia miesiąca i wydatków pozostaje stabilna dzięki snapshotom (template→month i category-at-expense).

## Key Decisions Made

| Decision | Choice | Why (1 sentence) |
| --- | --- | --- |
| Zakres F-01 | Schema + migrations + RLS + minimal typed contracts | To minimalny komplet, który jest jednocześnie bezpieczny i wystarczający do startu S-01. |
| Model własności | Jeden owner = jeden wallet (1:1 z auth user) | Upraszcza RLS i redukuje ryzyko błędów izolacji w MVP. |
| Template→monthly | Snapshot przy tworzeniu monthly budget | Chroni historię miesiąca przed późniejszymi zmianami template. |
| Kategoria a historia wydatków | Snapshot nazwy/typu kategorii w expense | Raporty historyczne pozostają poprawne po rename/delete kategorii. |
| Reprezentacja kwot | Integer w najmniejszej jednostce waluty | Eliminuje błędy zaokrągleń i stabilizuje sumowania finansowe. |
| Strategia migracji | Forward-only, kompatybilna wstecz, bez destructive zmian | Zmniejsza ryzyko deployu i ułatwia bezpieczny rollback kodu. |
| Security baseline | RLS na wszystkich tabelach domenowych, deny-by-default | Zapewnia izolację ownera od pierwszej wersji. |
| Walidacja okresu wydatku | Tylko dla istniejącego monthly budget okresu | Zapobiega osieroconym danym i niespójnym podsumowaniom. |
| Wydajność MVP | Indeksy pod wallet/period/category/date | Daje sensowną responsywność bez overengineeringu. |

## Scope

**In scope:** migracje SQL dla pełnego modelu F-01, constraints i klucze, RLS owner-only, snapshot rules, period guards, indeksy MVP, seed/config hygiene, minimal typed contracts.

**Out of scope:** guest access, import bankowy, pełne CRUD/API dla wszystkich encji, zaawansowane analityki/partycjonowanie.

## Architecture / Approach

Podejście jest sekwencyjne i bezpieczne: najpierw schema + invariants, następnie izolacja RLS, potem reguły cyklu budżetu i snapshoty historyczne, a na końcu indeksy i workflow weryfikacyjny. Całość opiera się na Supabase migrations jako jedynym źródle zmian DB oraz na istniejącym wzorcu identity (`auth.uid()` + ownership przez wallet).

## Phases at a Glance

| Phase | What it delivers | Key risk |
| --- | --- | --- |
| 1. Schema foundations & invariants | Komplet tabel, relacji i finansowych constraints | Błędny model relacji utrudni wszystkie kolejne slice’y |
| 2. Ownership isolation & RLS | Owner-only polityki dostępu na całej domenie | Luki w policy mogą dopuścić cross-owner access |
| 3. Budget lifecycle modeling | Snapshoty miesięczne i kategoryjne + period guards | Niespójna semantyka historii wydatków |
| 4. Performance baseline & verification workflow | Indeksy MVP i powtarzalna walidacja lokalna | Niedoszacowanie query paths dla summary/list |

**Prerequisites:** działający lokalny Supabase, uprawnienia do migracji, obecny setup env (`SUPABASE_URL`, `SUPABASE_KEY`).
**Estimated effort:** ~2–3 sesje implementacyjne w 4 fazach.

## Open Risks & Assumptions

- Zakładamy single-wallet model ownera w MVP; zmiana na multi-wallet będzie wymagała rozszerzenia polityk i kluczy.
- Zakładamy małą skalę danych (PRD: small), więc indeksy MVP wystarczą do pierwszego releasu.
- Błędy w pierwszych migracjach mogą opóźnić S-01, dlatego plan wymaga SQL smoke checks po każdej fazie.

## Success Criteria (Summary)

- F-01 schema jest wdrażalny od zera (`db reset`) i odzwierciedla wszystkie encje wymagane przez roadmap/PRD.
- RLS skutecznie izoluje dane per owner, a próby cross-owner access są blokowane.
- Snapshoty i period guards utrzymują poprawność historycznych danych finansowych i przygotowują grunt pod S-01.
