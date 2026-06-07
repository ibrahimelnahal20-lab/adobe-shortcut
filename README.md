# Adobe Shortcut

Adobe Shortcut is a modern web platform built for creative professionals who use Adobe applications daily.

Discover, search, and explore keyboard shortcuts across Adobe apps with a fast, responsive, and multilingual experience designed to improve workflow efficiency and productivity.

---

## What's New in v1.1.4

### Mobile Experience Improvements
* Improved mobile responsiveness
* Better touch targets
* Reduced unnecessary spacing
* Improved content density
* Better mobile navigation experience

### Performance Improvements
* Search debouncing
* Reduced widget rebuilds
* Optimized About page rendering
* Improved scroll performance
* SVG rendering optimizations
* RepaintBoundary optimizations

### Search Improvements
* Faster search experience
* Reduced lag while typing
* Improved filtering performance

### Stability Improvements
* Route consistency improvements
* Navigation reliability improvements
* Mobile UX polish
* General bug fixes

---

## Features

- **Seamless Web Updates:** Custom Over-The-Air (OTA) update system that instantly notifies users of new deployments and perfectly overrides browser caching for immediate update propagation without any manual cache clearing.
- Fast shortcut search
- Adobe application browsing
- Bookmark favorite shortcuts
- Arabic and English support
- Light and Dark themes
- Mobile responsive experience
- Keyboard shortcut discovery
- Featured shortcuts
- Adobe application explorer

---

## Technology Stack

- **Flutter Web**: Core UI framework compiled to WebAssembly (Wasm).
- **Riverpod**: Robust, predictable reactive state management.
- **GoRouter**: Declarative URL-based routing for Flutter Web.
- **Firebase Hosting**: Fast and secure global content delivery.
- **Cloud Firestore**: Scalable NoSQL cloud database.
- **Flutter SVG**: Hardware-accelerated vector graphic rendering.
- **Lottie**: High-performance JSON-based micro-animations.

---

## Project Structure

The project follows a lightweight, feature-first architecture without unnecessary abstraction layers:

```text
lib/
├── core/         # Shared application infrastructure.
├── features/     # Feature-first modules.
├── shared/       # Reusable widgets and utilities.
└── main.dart     # Application entry point and Riverpod bootstrapping.
```

---

## Performance

* Optimized widget rebuilds
* Debounced search system
* RepaintBoundary optimizations
* Mobile-first performance improvements
* Smooth scrolling experience

---

## Roadmap

* Additional Adobe applications
* Expanded shortcut database
* Improved search capabilities
* More workflow productivity features
* Community-driven shortcut suggestions

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
