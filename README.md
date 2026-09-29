# Tequila 🥑

> **💬 Have feedback or feature ideas?** [👉 Join the Discussion & Request Features](https://github.com/caiyuyou1227-glitch/tequila/discussions) — Every single report directly shapes our next update!

[![Open Issues](https://img.shields.io/github/issues/caiyuyou1227-glitch/tequila?style=flat-square&color=3b82f6)](https://github.com/caiyuyou1227-glitch/tequila/issues)
[![Discussions](https://img.shields.io/badge/Community-Discussions-f97316?style=flat-square)](https://github.com/caiyuyou1227-glitch/tequila/discussions)
[![Latest Release](https://img.shields.io/github/v/release/caiyuyou1227-glitch/tequila?style=flat-square&color=22c55e)](https://github.com/caiyuyou1227-glitch/tequila/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=flat-square)](LICENSE)

**A native, open-source macOS app where deep utility meets aesthetic design.**

Most productivity tools force a trade-off: either powerful but ugly, or pretty but shallow. **Tequila** bridges that gap — combining 6 core workflow modules, full visual customization, and a native macOS experience tailored for creative minds and power users.

---

## ✨ Key Features

### 🎯 Focus — Chronological Task Blocking
Plan tasks for today or any date. Time blocks auto-sort chronologically to map out your day. Export your daily task list in one click.

![Focus module](screenshots/focus.png)

---

### ⏱ Timer — Project-Based Time Tracking
Unlimited count-up and countdown timers. Organize sessions into custom folders to track hours spent across different creative and technical projects.

![Timer module](screenshots/timer.png)

---

### 📅 Calendar — Highlighter Overlap & Schedule Export
Browse any month with an intuitive highlighter tool — overlapping highlights blend colors automatically, making busy schedules visible at a glance. Drag directly to build schedule bars, tweak font/bar colors, and export full-month PDFs in bar or circle style.

![Calendar module](screenshots/calendar.png)

---

### 📬 Mail — Unified Multi-Account Inbox
A unified inbox supporting Gmail, Outlook, iCloud Mail, ProtonMail, Yahoo Mail, 163, and QQ Mail — read, manage, and reply without breaking your flow.

![Mail module](screenshots/mail.png)

---

### 📝 Logs — Rich Workspace for Ideas
An ongoing workspace for notes, creative specs, and research. Insert images, format tables, and organize entries cleanly into folders and files.

![Logs module](screenshots/logs.png)

---

### ⚙️ Settings — Total Aesthetic Control
Customize backgrounds and typography with solid colors or uploaded images. Choose your preferred typeface to match your desktop setup. Built with full localization support so language is never a barrier.

![Settings module](screenshots/settings.png)

> 📍 *Each module includes an auto-detecting, freely movable location indicator that adapts to your region settings.*

---

## ⚡️ Quick Installation Guide

### Step 1 — Download
Head to the [Releases](../../releases) page and grab the latest `tequila.dmg`.

![Download tequila.dmg](screenshots/install-1-download.png)

### Step 2 — Install
Open the `.dmg` installer and drag **Tequila** directly into your **Applications** folder.

![Drag tequila into Applications](screenshots/install-2-drag.png)

### Step 3 — First Launch & Security Notice
Launch Tequila from Applications. Because this is an open-source project without a paid Apple Developer certificate yet, macOS will show a standard unnotarized app warning. 

*(Don't worry — the code is 100% open-source right here. You can inspect it or build it directly via Xcode by opening `tequila.xcodeproj`!)*

![macOS warning on first launch](screenshots/install-3-warning.png)

### Step 4 — One-Click Unlock
1. Click **Done**.
2. Open **System Settings → Privacy & Security**.
3. Scroll down to the Tequila notification, click **Open Anyway**, and enter your Mac password.
4. Open Tequila again — you're all set!

![Open Anyway in Privacy & Security](screenshots/install-4-open-anyway.png)

> 💡 **Terminal Shortcut:** If you don't see the *Open Anyway* button, open Terminal and run:
> ```bash
> xattr -cr /Applications/tequila.app
> ```

---

## 🛠 Tech Stack

- **Language:** Native Swift
- **Platform:** macOS (optimized for Apple Silicon & Intel)
- **Architecture:** Native AppKit / SwiftUI

---

## 🎨 Why I Built This

I come from a background in **fashion design, fashion management, and 2D/3D visual production** rather than traditional software engineering. 

I built Tequila because I couldn't find a macOS productivity tool that truly respected both deep function and visual aesthetics: existing options were either aesthetically lacking or frustratingly clunky. It started as a personal tool to solve my own daily workflow bottlenecks.

I am a **high school student** maintaining this project independently. Feedback, bug reports, and feature requests mean the world to me!

---

## 💬 Feedback & Community

Whether Tequila streamlined your workday or you found something that needs fixing:
- 💡 **Got an idea or UI suggestion?** [Start a Discussion](../../discussions)
- 🐛 **Found a bug or protocol issue?** [Open an Issue](../../issues)

Every single input helps iterate and polish the app. Thank you for testing Tequila! 🚀
