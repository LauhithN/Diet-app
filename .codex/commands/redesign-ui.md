COMMAND NAME
redesign-ui

PURPOSE
Perform a full UI modernization of the SwiftUI application using the repository agent system.

Agents must use:

AGENTS.md
.codex/ui-guidelines.md
.codex/design-system.md
.codex/project-map.md
.codex/screen-intent.md
.codex/agent-behavior.md
.codex/ui-components.swift

--------------------------------------------------

EXECUTION PLAN

Spawn specialized agents to complete the UI redesign.

Agent 1
Design System Architect

Tasks
- refactor Theme.swift
- define color palette
- define typography system
- define spacing tokens
- define reusable card styles
- define button styles
- define gradient system

--------------------------------------------------

Agent 2
Screen Redesign Specialist

Tasks
- redesign all SwiftUI screens
- convert layouts to card-based architecture
- apply design system tokens
- modernize navigation bars
- modernize tab bar
- apply elegant section headers

Target files

HomeView.swift
DailyMealPlanView.swift
MealCardView.swift
GroceryListView.swift
ExercisePlanView.swift
AIMealSuggestionView.swift
ProgressView.swift
SettingsView.swift

--------------------------------------------------

Agent 3
Animation Designer

Tasks
- add subtle card animations
- add button feedback
- animate progress rings
- add smooth tab transitions
- keep animations minimal and elegant

--------------------------------------------------

Agent 4
Accessibility Auditor

Tasks
- detect low contrast text
- remove white text on light surfaces
- enforce readable typography
- verify dark mode support
- ensure proper tap targets

--------------------------------------------------

Agent 5
Widget Designer

Tasks
Create iOS widgets:

- calorie progress widget
- daily meal reminder widget
- weight progress widget
- romantic motivational widget

Use WidgetKit.

--------------------------------------------------

Agent 6
Build Engineer

Tasks

- run Swift compile checks
- fix syntax errors
- verify navigation works
- verify widgets build
- ensure the project compiles successfully

--------------------------------------------------

DESIGN GOAL

The final product must feel like a premium iOS wellness application built personally for Bubu.

The UI should be:

- romantic
- elegant
- modern
- minimal
- consistent

--------------------------------------------------

OUTPUT

1. show modified files
2. explain major UI improvements
3. confirm successful build
