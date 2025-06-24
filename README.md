# 📨 SwiftUI Chat Message Reaction Overlay

![Demo](./demo.gif)

A SwiftUI prototype that demonstrates how to build a **floating emoji reaction overlay** on top of a chat message — complete with hero-style animations, dynamic geometry-based positioning, and smooth transitions using `matchedGeometryEffect` and `anchorPreference`.

---

## 🚀 Features

- ✅ Tap on a message to activate the reaction overlay
- ✅ Emoji reaction buttons with entry animation
- ✅ Hero-style transition between message and overlay
- ✅ Precise overlay positioning using `anchorPreference` and `GeometryProxy`
- ✅ Auto-dismiss on tap or reaction
- ✅ Designed using pure SwiftUI (no UIKit)

---

## 🧠 Core Concepts

This project demonstrates the practical use of:

- [`anchorPreference`](https://developer.apple.com/documentation/swiftui/view/anchorprefence(_:value:transform:)) to pass geometry data upward
- [`PreferenceKey`](https://developer.apple.com/documentation/swiftui/preferencekey) to collect anchors
- [`GeometryReader`](https://developer.apple.com/documentation/swiftui/geometryreader) + `GeometryProxy` to resolve frames
- [`matchedGeometryEffect`](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:isSource:)) for view morphing animations

---
