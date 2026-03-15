import { vi } from "vitest";
import "@testing-library/jest-dom";
import "vitest-canvas-mock";

// Mock Tauri APIs
vi.mock("@tauri-apps/api/core", () => ({
  invoke: vi.fn(),
}));

vi.mock("@tauri-apps/api/path", () => ({
  basename: vi.fn(),
  join: vi.fn(),
  appDataDir: vi.fn(),
}));

vi.mock("@tauri-apps/plugin-store", () => ({
  load: vi.fn().mockResolvedValue({
    get: vi.fn(),
    set: vi.fn(),
    save: vi.fn(),
  }),
}));

vi.mock("@tauri-apps/api/window", () => ({
  getCurrentWindow: vi.fn(() => ({
    minimize: vi.fn(),
    toggleMaximize: vi.fn(),
    close: vi.fn(),
    isMaximized: vi.fn().mockResolvedValue(false),
    onResized: vi.fn().mockResolvedValue(() => {}),
  })),
}));

vi.mock("@tauri-apps/plugin-fs", () => ({
  readTextFile: vi.fn(),
  writeTextFile: vi.fn(),
  exists: vi.fn(),
  mkdir: vi.fn(),
}));

global.createImageBitmap = vi.fn(async () => {
  const canvas = document.createElement("canvas");
  canvas.height = 100;
  canvas.width = 100;
  const ctx = canvas.getContext("2d");
  if (ctx) {
    ctx.fillStyle = "#ff0000";
    ctx.fillRect(0, 0, 100, 100);
  }
  // Add close method to mock ImageBitmap
  (canvas as any).close = vi.fn();
  return canvas as unknown as ImageBitmap;
});
