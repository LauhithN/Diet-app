AGENT BEHAVIOR RULES

This repository supports multi-agent execution.

Agents may spawn specialized sub-agents to complete tasks efficiently.

Preferred workflow is parallel execution with coordinated file changes.

-----------------------------------------------------

TASK ORCHESTRATION

When a complex request is given (such as UI redesign), agents should split work across multiple sub-agents.

Recommended agent roles:

1. Design System Agent
2. Screen Redesign Agent
3. Animation Agent
4. Accessibility Agent
5. Widget UI Agent
6. Build Verification Agent

Each agent should focus on its specific responsibility.

Agents should avoid modifying the same file simultaneously.

-----------------------------------------------------

PARALLELIZATION STRATEGY

Agents may run in parallel when working on separate files.

Example:

Agent A → Theme.swift  
Agent B → HomeView.swift  
Agent C → MealCardView.swift  
Agent D → Accessibility audit  

Agents must coordinate through the design system to maintain consistency.

-----------------------------------------------------

FILE OWNERSHIP

Design System Agent owns:

Theme.swift

Screen Redesign Agent owns:

HomeView.swift  
DailyMealPlanView.swift  
MealCardView.swift  
GroceryListView.swift  
ExercisePlanView.swift  
AIMealSuggestionView.swift  
ProgressView.swift  
SettingsView.swift  

Accessibility Agent audits all UI files.

Build Agent verifies the entire project compiles.

-----------------------------------------------------

DESIGN PRIORITIES

Agents must prioritize:

1. Design system consistency
2. Readability and accessibility
3. Clean SwiftUI architecture
4. Smooth micro-interactions
5. Elegant and romantic UI tone

-----------------------------------------------------

FAILSAFE RULES

If UI changes break the build:

• revert problematic edits
• repair syntax issues
• maintain Theme.swift integrity

The app must always remain buildable.

-----------------------------------------------------

FINAL GOAL

Produce a polished SwiftUI iOS app that feels like a premium wellness product built personally for Bubu.

-----------------------------------------------------
