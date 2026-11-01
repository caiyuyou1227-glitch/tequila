<div align="center">

# T E Q U I L A

### A Native macOS Productivity Workspace

A unified workspace for planning, time management, communication, and personal organization.

<br>

[![Platform](https://img.shields.io/badge/Platform-macOS-111111?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Language](https://img.shields.io/badge/Language-Swift-F05138?style=flat-square&logo=swift&logoColor=white)](https://www.swift.org/)
[![Framework](https://img.shields.io/badge/Framework-SwiftUI-007AFF?style=flat-square)](https://developer.apple.com/xcode/swiftui/)
[![Version](https://img.shields.io/badge/Version-v1.6-8A7AFF?style=flat-square)](https://github.com/caiyuyou1227-glitch/tequila/releases)
[![GitHub Stars](https://img.shields.io/github/stars/caiyuyou1227-glitch/tequila?style=flat-square)](https://github.com/caiyuyou1227-glitch/tequila/stargazers)

<br>

[Overview](#01-overview) ·
[Architecture](#02-product-architecture) ·
[Modules](#03-core-modules) ·
[Design](#04-design-system) ·
[Technology](#05-technology-stack) ·
[Structure](#06-project-structure) ·
[Development](#07-development) ·
[Releases](#08-release-history) ·
[Demo](#09-product-demo) ·
[Community](#10-community)

</div>

---

## 01 / Overview

**Tequila** is a native macOS productivity application built with Swift, SwiftUI, and AppKit.

It brings essential productivity workflows into one integrated workspace, combining task management, time tracking, calendar planning, email, and personal organization.

Rather than treating productivity as a collection of disconnected tools, Tequila approaches it as a unified system — where daily planning, execution, and review can happen within the same environment.

### Product Principles

| Principle | Direction |
|---|---|
| Functionality | Integrate essential productivity workflows into one workspace. |
| Visual Clarity | Reduce unnecessary interface elements and establish clear hierarchy. |
| Flexibility | Allow users to configure their workspace and organize tasks around their routines. |
| Consistency | Keep interactions predictable across different modules. |
| Iteration | Improve usability through daily use, observation, and user feedback. |

---

## 02 / Product Architecture

Tequila is organized around six interconnected modules.

```mermaid
flowchart TD
    A["TEQUILA<br/>macOS Productivity Workspace"]

    A --> B["Focus"]
    A --> C["Timer"]
    A --> D["Calendar"]
    A --> E["Mail"]
    A --> F["Settings"]
    A --> G["Logs"]

    B --> H["Task Management"]
    C --> I["Time Tracking"]
    D --> J["Schedule Planning"]
    E --> K["Email Communication"]
    F --> L["Workspace Configuration"]
    G --> M["Activity Records"]
```

Each module addresses a distinct part of the productivity workflow while contributing to a consistent overall experience.

---

## 03 / Core Modules

### 01 — Focus

Task management and daily execution.

- Create and organize tasks.
- Manage fixed and scheduled tasks.
- Set task priorities and visibility.
- Track task completion status.
- Configure recurring weekday schedules.
- Support count-up and countdown day tracking.
- Hide selected tasks without deleting them.

### 02 — Timer

Time management and task duration tracking.

- Track elapsed time.
- Set countdown timers.
- Support time-based productivity workflows.
- Integrate timing into daily task management.

### 03 — Calendar

Calendar-based planning and scheduling.

- View and organize scheduled events.
- Coordinate tasks with calendar dates.
- Maintain a clearer overview of daily plans.

### 04 — Mail

Email communication in one workspace.

- Connect multiple email accounts.
- Access email workflows within Tequila.
- Reduce the need to switch between separate applications.

### 05 — Settings

Personalized workspace configuration.

- Configure interface appearance.
- Customize workspace preferences.
- Adjust the region displayed in the upper-right corner.
- Reposition the displayed region using the mouse.
- Manage available visual settings.

### 06 — Logs

A record of productivity activity.

- Review recorded activity.
- Maintain visibility into previous work.
- Support reflection and progress review.

---

## 04 / Design System

Tequila's interface is designed around clarity, consistency, and functional minimalism.

### Visual Direction

- **Minimal Interface** — Avoid unnecessary decoration and visual noise.
- **Clear Hierarchy** — Make important information easier to identify.
- **Consistent Interaction** — Maintain predictable controls and behaviors.
- **User Configuration** — Allow the workspace to adapt to individual preferences.

### Design Philosophy

The interface should support the work rather than compete with it.

Every visual element should have a purpose. Every interaction should communicate its function clearly.

---

## 05 / Technology Stack

| Technology | Application |
|---|---|
| Swift | Primary programming language |
| SwiftUI | Declarative user interface development |
| AppKit | Native macOS integration |
| Xcode | Development and build environment |
| Git | Version control |
| GitHub | Source code hosting and release distribution |

### Platform

- Native macOS application
- Designed for desktop workflows
- Built with Apple's development frameworks

---

## 06 / Project Structure

The following structure reflects the current repository organization.

```text
tequila/
│
├── tequila/
│   ├── Assets.xcassets/
│   │   └── Contents.json
│   │
│   ├── tequilaApp.swift
│   └── ContentView.swift
│
├── tequilaTests/
│   └── tequilaTests.swift
│
├── tequilaUITests/
│   ├── tequilaUITests.swift
│   └── tequilaUITestsLaunchTests.swift
│
├── screenshots/
│   ├── focus.png
│   ├── timer.png
│   ├── calendar.png
│   ├── mail.png
│   ├── settings.png
│   ├── logs.png
│   ├── install-1-download.png
│   ├── install-2-drag.png
│   ├── install-3-warning.png
│   └── install-4-open-anyway.png
│
├── tequila.xcodeproj/
│   ├── project.pbxproj
│   └── project.xcworkspace/
│       └── contents.xcworkspacedata
│
├── README.md
└── .gitignore
```

### Directory Reference

| Directory / File | Description |
|---|---|
| `tequila/` | Main application source directory |
| `Assets.xcassets/` | Application asset catalog |
| `tequilaApp.swift` | Application entry point |
| `ContentView.swift` | Main content view |
| `tequilaTests/` | Unit test target |
| `tequilaUITests/` | UI test target |
| `screenshots/` | Product screenshots and installation guides |
| `tequila.xcodeproj/` | Xcode project configuration |
| `README.md` | Project documentation |
| `.gitignore` | Git exclusion rules |

---

## 07 / Development

### Requirements

- macOS
- Xcode
- Swift toolchain compatible with the project configuration

### Run Locally

1. Clone the repository:

```bash
git clone https://github.com/caiyuyou1227-glitch/tequila.git
```

2. Open the project:

```bash
cd tequila
open tequila.xcodeproj
```

3. Select the `tequila` scheme and `My Mac` as the run destination.

4. Build and run the application in Xcode.

### Build

The application can also be built from Terminal:

```bash
cd tequila

xcodebuild \
  -project tequila.xcodeproj \
  -scheme tequila \
  -configuration Release \
  -destination 'platform=macOS' \
  build
```

---

## 08 / Release History

Tequila is developed through continuous iteration. Each release focuses on improving usability, task organization, and the overall productivity experience.

### v1.6 — More Precise Task Control

**All-Day Fixed Tasks**

- Added an `All Day` option to Fix, allowing a task to be scheduled for the entire day.
- Expanded scheduling flexibility for different daily routines.

**Date-Specific Completion Status**

- Updated completed and incomplete task indicators to apply only to the currently selected date.
- Checking Fix on one date no longer automatically checks the same task across every other date on which it is scheduled.
- Task status changes and Fix operations are limited to the date selected by the user.

**Hide Tasks**

- Added the ability to hide selected tasks after creation.
- Hidden tasks remain available without being permanently deleted.
- Helps keep the workspace focused on tasks that require immediate attention.

**Design Direction**

More precise date-based task management, clearer task status, and greater control over daily organization.

---

### v1.5 — Weekly Planning

- Added weekday selection for fixed tasks.
- Improved recurring task scheduling.
- Distinguished between removing an individual weekday and clearing all fixed-day settings.
- Improved control over weekly routines.

### v1.4 — Task Status Refinement

- Improved the visual distinction between completed and incomplete tasks.
- Refined task status indicators.
- Updated the delete button styling for clearer interaction feedback.

### v1.3 — Task Date Tracking

- Introduced count-up and countdown day tracking for tasks.
- Improved visibility into time-related task information.

### v1.2 — Date Tracking

- Expanded date-based task tracking.
- Added count-up and countdown functionality.

### v1.1 — Interface Refinement

- Simplified the interface.
- Removed unnecessary text and visual elements.
- Refined visual hierarchy based on feedback.
- Improved the balance between aesthetics and practical usability.

### v1.0 — Initial Release

- Introduced the core Tequila workspace.
- Established the six-module structure.
- Released the initial macOS application.

---

## 09 / Product Demo

<div align="center">

### Explore Tequila

[![Tequila Product Demo](https://img.youtube.com/vi/Plah28XUPFI/maxresdefault.jpg)](https://www.youtube.com/watch?v=Plah28XUPFI)

**Watch the full product demonstration**

[YouTube — Tequila Demo](https://www.youtube.com/watch?v=Plah28XUPFI)

</div>

---

## 10 / Screenshots

### Focus

Task management and daily planning.

![Focus](screenshots/focus.png)

### Timer

Time tracking and countdown workflows.

![Timer](screenshots/timer.png)

### Calendar

Calendar-based organization.

![Calendar](screenshots/calendar.png)

### Mail

Integrated email workspace.

![Mail](screenshots/mail.png)

### Settings

Workspace configuration and personalization.

![Settings](screenshots/settings.png)

### Logs

Productivity activity records.

![Logs](screenshots/logs.png)

---

## 11 / Installation

Download the latest release from GitHub.

[**Download Tequila**](https://github.com/caiyuyou1227-glitch/tequila/releases)

### Installation Steps

1. Download the latest `.dmg` file from Releases.
2. Open the downloaded disk image.
3. Drag Tequila into the Applications folder.
4. If macOS displays a security warning, follow the installation instructions provided in the release documentation.

---

## 12 / Community & Feedback

Tequila continues to evolve through personal use and external feedback.

Feedback helps identify usability issues, evaluate design decisions, and guide future improvements.

### GitHub

Source code, issue reports, feature requests, and release updates.

- [Repository](https://github.com/caiyuyou1227-glitch/tequila)
- [Releases](https://github.com/caiyuyou1227-glitch/tequila/releases)
- [Issues](https://github.com/caiyuyou1227-glitch/tequila/issues)
- [Discussions](https://github.com/caiyuyou1227-glitch/tequila/discussions)

### Community Feedback

- [Xiaohongshu](https://www.xiaohongshu.com/discovery/item/6aba2e980000000002013350?source=webshare&xhsshare=pc_web&xsec_token=AB1ofPMD2UY6B3QkhKaT0Fb_gjfxCuPxq-BM8BlBuhLOw=&xsec_source=pc_share)
- Reddit — Community feedback and discussion.

---

## 13 / Behind the Project

Tequila began with a simple observation: productivity tools often require users to choose between extensive functionality and a well-considered interface.

I wanted to explore whether these two qualities could coexist in one native macOS application.

The project has evolved through independent development, daily use, and feedback-driven iteration. Instead of treating each release as a finished product, I use every version as an opportunity to reconsider existing interactions and improve the overall experience.

The goal is not simply to add more features, but to make the existing ones work better together.

<br>

<div align="center">

**TEQUILA**

*Plan with clarity. Work with focus.*

[GitHub Repository](https://github.com/caiyuyou1227-glitch/tequila)

</div>
