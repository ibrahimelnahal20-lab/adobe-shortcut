# Adobe Shortcut

Modern keyboard shortcut discovery for creative professionals.

**Adobe Shortcut** is an interactive, responsive web application built with Flutter Web. It provides an elegantly designed platform for creative professionals (designers, video editors, audio engineers) to instantly search, discover, and bookmark keyboard shortcuts for their daily tools.

---

## Features

- **Text Search**: Instantly find shortcuts by typing actions or tool names.
- **Key Search**: Press any key combination on your keyboard to reverse-search what it does.
- **Application Browsing**: Filter shortcuts by your specific creative application.
- **Categories**: Browse categorized shortcuts (e.g., Tools, Layers, View, Audio).
- **Bookmarks**: Save and manage your most-used shortcuts for quick access.
- **Arabic & English Support**: Full bidirectional localization (LTR/RTL) out of the box.
- **Windows & macOS Support**: Toggle between PC and Mac modifier keys automatically.
- **Responsive Flutter Web Experience**: Optimized with Slivers and dynamic grids for butter-smooth scrolling and interactions across desktop and mobile.

---

## Screenshots

*(Screenshots coming soon)*

### Home Page
![Home Page Placeholder]()

### Shortcuts Page
![Shortcuts Page Placeholder]()

### App Details
![App Details Placeholder]()

### Bookmarks
![Bookmarks Placeholder]()

### About Page
![About Page Placeholder]()

---

## Supported Applications

- Adobe Photoshop
- Adobe Illustrator
- Adobe After Effects
- Adobe Premiere Pro
- Adobe Lightroom
- Adobe InDesign
- Adobe Audition
- DaVinci Resolve
- FL Studio

*(Note: Although named Adobe Shortcut, the platform actively supports industry-standard software across multiple creative suites).*

---

## Technology Stack

- **Flutter Web**: Core UI framework compiled to WebAssembly (Wasm).
- **Riverpod**: Robust, predictable reactive state management.
- **GoRouter**: Declarative URL-based routing for Flutter Web.
- **SharedPreferences**: Local persistence for user themes, language, and bookmarks.
- **Flutter SVG**: Hardware-accelerated vector graphic rendering.
- **Lottie**: High-performance JSON-based micro-animations.

---

## Project Structure

The project follows a lightweight, feature-first architecture without unnecessary abstraction layers:

```text
lib/
├── core/         # Core application configurations (router, theme, localization, global providers, base models).
├── features/     # Feature modules (home, about, shortcuts, bookmarks, app_details). Each feature encapsulates its own screens and widgets.
├── shared/       # Shared UI components and universal widgets used across multiple features (navbar, skeleton loaders, generic buttons).
└── main.dart     # Application entry point and Riverpod bootstrapping.
```

---

## Running Locally

To run this project locally, ensure you have the Flutter SDK installed:

```bash
# Fetch dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

---

## Production Build

To generate the highly optimized WebAssembly (Wasm) release bundle:

```bash
flutter build web --release
```

---

## Built by Creators

**Ibrahim Elnahal** — Flutter Developer
- [Portfolio](https://ibrahim-portfolio-zeta.vercel.app/)
- [GitHub](https://github.com/ibrahimelnahal20-lab)
- [LinkedIn](https://www.linkedin.com/in/ibrahim-elnahal-887955410/)
- [Email](ibrahimElnahal20@gmail.com)

**Adham Shawky** — Graphic Designer & Shortcut Database Curator
- [LinkedIn](https://www.linkedin.com/in/adham-shawky-83b90a3a0/)
- [Email](adhamtshawky@gmail.com)

---

## License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
