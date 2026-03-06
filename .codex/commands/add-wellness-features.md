COMMAND NAME
add-wellness-features

PURPOSE

Extend the SwiftUI wellness app with modern health-tracking features.

The features must integrate with the existing design system and UI components.

Agents should follow AGENTS.md and use components from .codex/ui-components.swift.

--------------------------------------------------

AGENT 1
Progress Dashboard Engineer

Mission

Build a progress tracking dashboard using Swift Charts.

Features

• weight history chart
• calorie intake chart
• weekly trend chart
• progress ring for daily calories

Files to create

ProgressChartsView.swift
WeightChartView.swift
CalorieTrendChartView.swift

Use Swift Charts framework.

--------------------------------------------------

AGENT 2
AI Meal Suggestion Engineer

Mission

Improve the AI meal suggestion interface.

Features

• generate meals based on calorie target
• show calories per meal
• display meal cards
• add “regenerate meal” button
• integrate with AIMealSuggestionView.swift

Optional API integration

Kimi API
OpenAI API
local prompt generator

--------------------------------------------------

AGENT 3
Notification System Engineer

Mission

Add daily notifications for reminders.

Features

• meal reminder notifications
• water intake reminders
• motivational messages for Bubu

Use

UserNotifications framework

Files to create

NotificationManager.swift

--------------------------------------------------

AGENT 4
WidgetKit Engineer

Mission

Create iPhone home screen widgets.

Widgets

Daily calorie progress widget  
Weight progress widget  
Meal reminder widget  
Motivational message widget  

Use WidgetKit.

Files to create

BubuDietWidget.swift
ProgressWidget.swift

--------------------------------------------------

AGENT 5
Romantic Message Generator

Mission

Create motivational messages for Bubu.

Examples

“You’re doing amazing today Bubu 💖”
“Every step brings you closer to your goal.”
“Your future self will thank you.”

Messages should feel supportive and romantic.

--------------------------------------------------

AGENT 6
Build Verification Engineer

Mission

Ensure the project compiles successfully.

Tasks

• verify Swift Charts imports
• verify WidgetKit builds
• verify notifications permission flow
• verify the app launches successfully

--------------------------------------------------

OUTPUT

1. show new files created
2. explain feature additions
3. confirm successful build
