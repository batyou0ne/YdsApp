# Architecture, Pedagogy & Cross-Platform Parity Guidelines (SwiftUI <-> Jetpack Compose)

## 1. Core Architecture (Clean Architecture + MVVM + UDF)
- Strictly separate `UI`, `Presentation` (ViewModel + Contract), `Domain` (UseCases + Entities + Repository Protocols), and `Data` (Repositories + DTOs + Seed/Network DataSources).
- Business logic, score calculation, spaced repetition, and freemium gating MUST NOT reside inside SwiftUI Views or Compose UI functions. Views only observe immutable `state` and dispatch user intents via `viewModel.onEvent(...)`.
- Every screen feature MUST define a `<Feature>Contract` containing an immutable `<Feature>ViewState` (`Equatable, Sendable`) and a `<Feature>UiEvent` enum (`Sendable`), mirroring Jetpack Compose MVI/UDF state management 1:1.

## 2. Portability & Dependency Isolation (iOS <-> Android 1:1 Parity)
- **Pure Domain Layer:** Domain entities, repository protocols, and UseCases must be written in pure Swift (or pure Kotlin) without importing `SwiftUI`, `Combine`, `UIKit`, or platform-specific persistence frameworks.
- **Zero Tight Coupling:** Local persistence (UserDefaults, File/SQLite/SwiftData) must be strictly hidden behind Domain Repository protocols (`UserStudyRepository`, `VocabularyRepository`, `SentenceXRayRepository`, `SprintQuestionRepository`, `MistakeVaultRepository`).
- **DTOs & Seed Content:** Use standard `Codable` structs matching JSON specifications 1:1 so all exam questions, 3D vocabulary cards, and Sentence X-Ray tokens can be shared across iOS, Android, and backend APIs without transformation.

## 3. Domain-Specific Product & Pedagogical Rules (YDS / e-YDS / YÖKDİL)
1. **No Raw Translation-Only Feedback:** When a user answers a question incorrectly, NEVER show only the correct option letter and Turkish translation. Every option in `SprintQuestion` MUST carry a structured `DistractorExplanation` (`praiseTextTr`, `trapReasonTr`, `winningRuleTr`, `grammarRuleTag`).
2. **3D Vocabulary Mastery Rule:** A `Vocab3DCard` is NEVER marked as learned (`isFullyLearned == true`) unless all three dimensions (`isMeaningMastered`, `isPrepositionMastered`, `isSynonymMastered`) are independently answered correctly across spaced quiz modes.
3. **Sentence X-Ray Jargon Ban:** `examLogicTipTr` strings inside `SentenceSegment` must explain clauses using practical exam shortcuts (e.g., how to connect or eliminate options) rather than heavy linguistic jargon.
4. **Score-Driven Progress Only:** All user progress, streak rewards, and category diagnostics must be expressed in **Estimated Exam Score (`0.00 - 100.00`, e.g., `53.75 -> 62.50` or `+0.40 puan`)**, never just raw XP or word counts.
5. **Freemium Gating Enforcement:** Freemium limits (50% of Daily Prescription, 1 Sentence X-Ray per day, blurred `trapReasonTr` / `winningRuleTr` in Distractor Coach) must be evaluated deterministically in Domain UseCases and reflected via explicit flags in `ViewState`.

## 4. Git & Branching Workflow Rules
1. **Feature Branching:** For every new feature or task, always create and switch to a new, descriptively named branch branched off `main` (e.g., `feature/sentence-xray-engine`). Never work directly on `main`.
2. **Commit & Push:** Commit your changes with clear, descriptive commit messages to this feature branch and push them to the remote repository as you progress.
3. **Completion & Merge:** Once the feature is fully completed and tested:
   - Switch back to the `main` branch.
   - Pull the latest changes on `main`.
   - Merge the feature branch into `main`.
   - Push the updated `main` branch to the remote repository and clean up the merged feature branch.