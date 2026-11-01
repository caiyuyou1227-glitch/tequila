 
<div align="center">

# T E Q U I L A

### A WORKSPACE, DESIGNED AROUND YOU.

**Plan with intention. Track with clarity. Work your way.**

A native macOS productivity workspace built with Swift, SwiftUI, and AppKit.

[Download Latest Release](https://github.com/caiyuyou1227-glitch/tequila/releases/latest) · [Explore Source Code](https://github.com/caiyuyou1227-glitch/tequila) · [Request a Feature](https://github.com/caiyuyou1227-glitch/tequila/discussions)

<br/>

![Release](https://img.shields.io/github/v/release/caiyuyou1227-glitch/tequila?style=flat-square&color=8AFFC1&label=LATEST%20RELEASE)
![Stars](https://img.shields.io/github/stars/caiyuyou1227-glitch/tequila?style=flat-square&color=8AFFC1&label=STARS)
![Forks](https://img.shields.io/github/forks/caiyuyou1227-glitch/tequila?style=flat-square&color=8AFFC1&label=FORKS)
![Issues](https://img.shields.io/github/issues/caiyuyou1227-glitch/tequila?style=flat-square&color=8AFFC1&label=ISSUES)
![Platform](https://img.shields.io/badge/PLATFORM-macOS-8AFFC1?style=flat-square)
![Language](https://img.shields.io/badge/LANGUAGE-Swift-8AFFC1?style=flat-square)

</div>

---

## 00 / THE IDEA

> **Your workflow is personal. Your tools should be, too.**

Tequila began with a question: why should people adapt their working habits to the limitations of their software?

Many productivity tools prioritize functionality at the expense of visual coherence, while others offer polished interfaces without bringing everyday workflows together. I wanted to explore a different approach: a workspace where practical utility, visual design, and personalization are treated as parts of the same system.

Built as an independent project, Tequila brings six everyday workflows into one native macOS application.

The goal is not to build the application with the most features. It is to build a workspace in which the features, interface, and user's working habits make sense together.

**DESIGN PRINCIPLE / Function and form should work together.**

---

## 01 / THE SYSTEM

### Six modules. One workspace.

```mermaid
flowchart TD
    A["TEQUILA<br/>Personal Workspace"]

    A --> B["FOCUS<br/>Planning"]
    A --> C["TIMER<br/>Time Tracking"]
    A --> D["CALENDAR<br/>Scheduling"]
    A --> E["MAIL<br/>Communication"]
    A --> F["SETTINGS<br/>Personalization"]
    A --> G["LOGS<br/>Knowledge"]

    B -. "Plan" .-> C
    C -. "Track" .-> G
    D -. "Schedule" .-> B
    F -. "Customize" .-> A

    classDef core fill:#000000,stroke:#FFFFFF,color:#FFFFFF,stroke-width:2px
    classDef module fill:#171717,stroke:#777777,color:#FFFFFF,stroke-width:1px

    class A core
    class B,C,D,E,F,G module

    linkStyle default stroke:#777777,stroke-width:1.2px
```

Each module serves a distinct purpose while sharing the same application and visual environment.

| Module | Core Function | Design Intent |
|:--|:--|:--|
| **Focus** | Task and date planning | Make priorities and progress visible |
| **Timer** | Count-up and countdown timing | Make time measurable |
| **Calendar** | Schedule visualization | Make time easier to interpret |
| **Mail** | Multi-account email | Bring communication together |
| **Settings** | Interface customization | Give users control over their environment |
| **Logs** | Notes and research | Give information a structure |

---

## 02 / THE MODULES

### 01 — FOCUS

**Your day, structured around what matters.**

More than a to-do list, Focus is a flexible planning space that brings tasks, priorities, and time-based goals into one clear view. Organize each day, build recurring routines, and stay in control of your progress without losing sight of the bigger picture.

- **Intuitive Task Management** — Create, organize, and prioritize tasks in a streamlined daily workspace.
- **Independent Daily Progress** — Mark tasks as complete or incomplete for each selected date, keeping progress accurate and separate across days.
- **Smart Date Tracking** — Track days elapsed and days remaining for important deadlines, milestones, and personal goals.
- **Flexible Weekly Planning** — Assign fixed tasks to selected weekdays, with precise controls to manage recurring schedules.
- **Precise Schedule Control** — Modify individual weekdays or clear an entire fixed-day schedule without affecting other dates.
- **Flexible Task Visibility** — Hide tasks when they are not immediately relevant, without permanently deleting them.
- **Daily Task Export** — Export task lists for convenient reference and a clearer record of your plans.

**Plan with purpose. Track your progress. Make every day count.**

![Focus Interface](screenshots/focus.png)

### 02 — TIMER

**Turn time into something you can understand.**

A workspace for tracking sessions and organizing time across projects.

- Use count-up and countdown timers.
- Organize projects with custom folders.
- Track time spent on different activities.

Time is limited. At least now you can see where it went.

![Timer Interface](screenshots/timer.png)

---

### 03 — CALENDAR

**Make schedules visual, not just informational.**

A customizable calendar designed around visual hierarchy and personal preference.

- Adjust colors, typography, and highlights.
- Customize the appearance of schedules.
- Export personalized monthly calendar views.

![Calendar Interface](screenshots/calendar.png)

---

### 04 — MAIL

**Multiple inboxes. One place to work.**

Bring supported email accounts into a unified workspace.

Supported services:

- Gmail
- Outlook
- iCloud Mail
- Proton Mail
- Yahoo Mail
- 163 Mail
- QQ Mail

![Mail Interface](screenshots/mail.png)

---

### 05 — SETTINGS

**The interface is part of the experience.**

Customization is not an afterthought. It is part of how Tequila is designed to be used.

- Customize backgrounds and colors.
- Adjust typography and interface preferences.
- Shape the visual environment around individual working habits.
- Configure the region displayed in the upper-right corner of the workspace; the display updates to reflect the selected setting.

The upper-right region is more than a label: it responds to your settings and can be repositioned with the mouse.

Your workspace, your rules. Even the corner gets a little flexibility.

![Settings Interface](screenshots/settings.png)

---

### 06 — LOGS

**Capture ideas. Organize what matters.**

Logs provides a place for notes, research, and project materials.

- Record ideas and working notes.
- Organize information into folders.
- Combine text with images and tables.

![Logs Interface](screenshots/logs.png)

---

## 03 / DESIGN SYSTEM

### Form follows use. Personalization follows the person.

Tequila treats visual design as part of product functionality.

An interface does more than display information. It determines what attracts attention, how information is organized, and how comfortably people interact with a tool over time.

Four principles guide the project:

#### 01 — Visual hierarchy

Information should be organized so users can distinguish priorities, navigate functions, and understand the interface without unnecessary visual noise.

The important things should stand out. Everything else should know its place.

#### 02 — Customization

People have different working habits and visual preferences. Adjustable colors, backgrounds, and typography give users greater control over their workspace.

A useful interface should accommodate different preferences rather than assume everyone sees the world in the same palette.

#### 03 — Functional coherence

The six modules should feel like parts of one product, rather than unrelated utilities placed inside the same window.

The challenge is to balance individual functionality with a consistent overall experience.

#### 04 — Feedback-driven refinement

A design decision is a hypothesis, not a permanent law.

Tequila evolves through use, feedback, and targeted revisions. The aim is to make the interface clearer and the product more useful—not to add features simply to make a release number go up.

---

## 04 / ENGINEERING

### From visual concept to native application.

Tequila is built specifically for macOS using Swift and Apple's interface frameworks.

| Layer | Technology | Role |
|:--|:--|:--|
| Language | Swift | Application implementation |
| Interface | SwiftUI | Declarative interface development |
| Native framework | AppKit | macOS interface capabilities |
| Platform | macOS | Desktop environment |
| Distribution | GitHub Releases | Public builds and version history |

The project brings interface decisions and implementation into the same development process. Design choices must work not only as visual concepts, but also as parts of a functioning application.

**BUILD PRINCIPLE / A good interface must work, not just look like it does.**

### Project Structure

The repository is organized around the application source, interface resources, testing targets, and project configuration.

```text
tequila/
│
├── tequila/
│   │
│   ├── tequilaApp.swift
│   │   └── Application entry point
│   │
│   ├── ContentView.swift
│   │   └── Main application interface and workspace views
│   │
│   ├── Assets.xcassets/
│   │   └── App icons and image assets
│   │
│   └── tequila.entitlements
│       └── Application capabilities and permissions
│
├── tequilaTests/
│   └── tequilaTests.swift
│       └── Unit test target
│
├── tequilaUITests/
│   ├── tequilaUITests.swift
│   │   └── UI test target
│   │
│   └── tequilaUITestsLaunchTests.swift
│       └── Application launch tests
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

### Application Architecture

```mermaid
flowchart TD
    A["TEQUILA<br/>macOS Application"]

    A --> B["Application Layer"]
    A --> C["Presentation Layer"]
    A --> D["Resource Layer"]
    A --> E["Quality Layer"]
    A --> F["Project Configuration"]

    B --> B1["tequilaApp.swift"]
    C --> C1["ContentView.swift"]
    D --> D1["Assets.xcassets"]
    E --> E1["tequilaTests"]
    E --> E2["tequilaUITests"]
    F --> F1["tequila.xcodeproj"]
    F --> F2["tequila.entitlements"]

    classDef root fill:#000000,stroke:#FFFFFF,color:#FFFFFF,stroke-width:2px
    classDef layer fill:#151515,stroke:#777777,color:#FFFFFF,stroke-width:1px
    classDef file fill:#252525,stroke:#999999,color:#FFFFFF,stroke-width:1px

    class A root
    class B,C,D,E,F layer
    class B1,C1,D1,E1,E2,F1,F2 file

    linkStyle default stroke:#777777,stroke-width:1.2px
```

| Directory / File | Responsibility |
|:--|:--|
| `tequila/` | Main application source and resources |
| `tequilaApp.swift` | Application entry point |
| `ContentView.swift` | Main interface and workspace presentation |
| `Assets.xcassets/` | Application image and icon assets |
| `tequila.entitlements` | Application capabilities and permissions |
| `tequilaTests/` | Unit testing |
| `tequilaUITests/` | Interface and launch testing |
| `screenshots/` | Product screenshots and installation guide images |
| `tequila.xcodeproj/` | Xcode project and workspace configuration |
| `README.md` | Project documentation |
| `.gitignore` | Git exclusion rules |

---

## 05 / ITERATION

### A release is not the end of the process.

Tequila is developed through an ongoing cycle of observation, implementation, release, feedback, and revision.

```mermaid
flowchart LR
    A["01<br/>Observe"] --> B["02<br/>Design"]
    B --> C["03<br/>Build"]
    C --> D["04<br/>Release"]
    D --> E["05<br/>Gather Feedback"]
    E --> F["06<br/>Refine"]
    F --> B

    classDef stage fill:#111713,stroke:#8AFFC1,color:#FFFFFF
    class A,B,C,D,E,F stage
```

### Release history

| Version | Focus | Changes |
|:--|:--|:--|
| **v1.0** | Initial release | Introduced the core workspace and six modules |
| **v1.1** | Interface refinement | Simplified the interface and removed unnecessary text |
| **v1.2** | Focus updates | Added count-up and countdown day counters; corrected wording inconsistencies |
| **v1.3** | Task timing | Refined count-up and countdown functionality in Tasks |
| **v1.4** | Task clarity | Added clearer completed and incomplete task indicators; made the delete button red for better visibility |
| **v1.5** | Weekly planning | Added weekday selection for fixed tasks, with separate controls for removing one selected day and clearing all fixed-day settings |

### v1.5 / A better fit for your week.

This update focuses on recurring task planning. Instead of treating every week as a blank slate, users can choose the weekdays on which a task should be fixed.

- **Weekly Scheduling:** Select the specific weekdays for a fixed task.
- **Precise Removal:** The red × removes only the selected weekday.
- **Complete Reset:** The trash button removes all fixed-day settings for that task.

Separating these actions makes schedule management more predictable: removing one day does not mean clearing the entire weekly setup.

A small distinction in the interface can make a meaningful difference in how confidently people use it.

**v1.5 PRINCIPLE / Recurring tasks should be easy to configure—and hard to misunderstand.**

**[Explore All Releases →](https://github.com/caiyuyou1227-glitch/tequila/releases)**

---

## 06 / PRODUCT DEMONSTRATION

### See the workspace in action.

Explore the interface, core modules, and product experience in the walkthrough below.

<div align="center">

[![Tequila Product Demo](https://img.youtube.com/vi/Plah28XUPFI/maxresdefault.jpg)](https://www.youtube.com/watch?v=Plah28XUPFI)

**[Watch the Full Demo on YouTube →](https://www.youtube.com/watch?v=Plah28XUPFI)**

</div>

---

## 07 / GET STARTED

### Download

1. Open [GitHub Releases](https://github.com/caiyuyou1227-glitch/tequila/releases/latest).
2. Download the latest Tequila `.dmg` file.
3. Open the disk image and drag the application into your Applications folder.
4. Launch Tequila and personalize the workspace in Settings.

If macOS displays a security warning, verify the source and understand the implications before proceeding. Do not bypass security protections unless you trust the application.

### Build from source

Clone the public repository:

```bash
git clone https://github.com/caiyuyou1227-glitch/tequila.git
```

Open the Xcode project in a compatible macOS development environment and build the application.

---

## 08 / COMMUNITY

### Built independently. Open to ideas.

Tequila is publicly available for people to explore, test, and discuss.

Feedback is an important part of product development. A suggestion can reveal an unclear interaction, a usability issue, or an assumption worth reconsidering.

- **Feature requests:** [GitHub Discussions](https://github.com/caiyuyou1227-glitch/tequila/discussions)
- **Bug reports:** [GitHub Issues](https://github.com/caiyuyou1227-glitch/tequila/issues)
- **Source code:** [Browse the repository](https://github.com/caiyuyou1227-glitch/tequila)
- **Product demonstration:** [YouTube](https://www.youtube.com/watch?v=Plah28XUPFI)

### Project showcase

Tequila has also been shared on Xiaohongshu as part of its public presentation and feedback process.

[View the Tequila showcase on Xiaohongshu](https://www.xiaohongshu.com/discovery/item/6aba2e980000000002013350?source=webshare&xhsshare=pc_web&xsec_token=AB1ofPMD2UY6B3QkhKaT0Fb_gjfxCuPxq-BM8BlBuhLOw=&xsec_source=pc_share)

Previously recorded post engagement:

| Metric | Count |
|:--|--:|
| Likes | 60 |
| Saves | 28 |
| Comments | 13 |
| Shares | 4 |

These figures represent engagement with the showcase post, not verified downloads or active users.

---

## 09 / BEHIND THE PROJECT

### Design thinking meets software engineering.

My background spans fashion design, fashion management, and 2D/3D creative production.

These experiences shaped my attention to visual structure, composition, hierarchy, and the relationship between form and function. Learning software development gave me a way to move beyond visual concepts and turn those ideas into interactive products.

Tequila brings these interests together through a practical process:

- **Observe** how people interact with tools.
- **Design** an interface around a clear purpose.
- **Build** the experience with native technologies.
- **Evaluate** the result through use and feedback.
- **Refine** the product through successive releases.

Developing Tequila has also changed how I think about design. A choice that looks right to its creator may not be the clearest choice for someone else. A feature that seems obvious during development may need a more visible signal in practice.

The project remains an ongoing exploration of how design and technology can work together to shape everyday digital experiences.

---

<div align="center">

### TEQUILA

**DESIGNED WITH INTENTION. BUILT TO EVOLVE.**

Native macOS · Independent Project

[Download](https://github.com/caiyuyou1227-glitch/tequila/releases/latest) · [Source](https://github.com/caiyuyou1227-glitch/tequila) · [Discussions](https://github.com/caiyuyou1227-glitch/tequila/discussions)

</div>
