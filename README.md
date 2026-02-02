# Velin

A modern, high-performance PDF reader built with **Tauri**, **Rust**, and **React**. Velin focuses on speed, smooth interactions, and a premium reading experience.

> [!IMPORTANT]
> **Project Status: Early Development**
> Velin is currently in active development. While core PDF viewing and navigation are functional, many features are still being implemented. Not everything will be fully functional yet.

## 🚀 Tech Stack

Velin leverages a modern stack to provide a native-feel desktop experience with web-based flexibility:

- **Framework**: [Tauri](https://tauri.app/) (v2)
- **Backend**: [Rust](https://www.rust-lang.org/) (High-performance PDF rendering and OS integration)
- **Frontend**: [React](https://react.dev/) + [TypeScript](https://www.typescriptlang.org/)
- **UI Architecture**: [Mantine](https://mantine.dev/) (Component library)
- **State Management**: [Zustand](https://zustand-demo.pmnd.rs/)
- **Virtualization**: [@tanstack/react-virtual](https://tanstack.com/virtual/latest) (For handling massive PDFs efficiently)
- **Build Tool**: [Vite](https://vitejs.dev/)

## 🛠 Features (Current Progress)

- [x] **Virtual PDF Rendering**: Supports large documents with minimal memory footprint using virtualization.
- [x] **Instant Zoom**: Optimized zoom logic with CSS-first scaling for zero-latency feedback (Ctrl + / Mouse Wheel).
- [x] **Responsive Toolbar**: Vertical sidebar toolbar for quick tool switching.
- [/] **Sidebar Panels**: Placeholders for Bookmarks and Comments (Under active development).
- [/] **Performance**: Continual optimizations to PDF pixel rendering and caching.

## 🤝 Open Source & Contributions

Velin is an open-source project, and we welcome help from the community!

### How You Can Help

- **Testing**: Report bugs or performance issues on different operating systems.
- **Feedback**: Suggest UI/UX improvements or new features.
- **Code**: Check out the issues tab or submit a Pull Request.

### Contribution Protocol

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## 📦 Getting Started

### Prerequisites

- [Rust](https://www.rust-lang.org/tools/install)
- [Node.js](https://nodejs.org/) (pnpm recommended)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/velin.git
   ```
2. Install dependencies:
   ```bash
   pnpm install
   ```
3. Run in development mode:
   ```bash
   pnpm tauri dev
   ```

---

## 📄 License

Velin is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for more details.

Developed with ❤️ using Tauri and Rust.
