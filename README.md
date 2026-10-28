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

    A --> B["FOCUS<br/>Task Management"]
    A --> C["TIMER<br/>Time Tracking"]
    A --> D["CALENDAR<br/>Scheduling"]
    A --> E["MAIL<br/>Communication"]
    A --> F["SETTINGS<br/>Personalization"]
    A --> G["LOGS<br/>Notes and Research"]

    B -. "Plan" .-> C
    C -. "Track" .-> G
    D -. "Schedule" .-> B
    F -. "Customize" .-> A

    classDef core fill:#101714,stroke:#8AFFC1,color:#8AFFC1,stroke-width:2px
    classDef module fill:#171C19,stroke:#59665F,color:#FFFFFF
    class A core
    class B,C,D,E,F,G module
