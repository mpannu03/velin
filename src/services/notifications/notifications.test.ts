import { describe, it, expect, vi } from "vitest";
import {
  notifySuccess,
  notifyError,
  notifyInfo,
  notifyWarning,
} from "./notifications";
import { notifications } from "@mantine/notifications";

// Mock @mantine/notifications
vi.mock("@mantine/notifications", () => ({
  notifications: {
    show: vi.fn(),
  },
}));

describe("notifications service", () => {
  it("should show success notification with correct parameters", () => {
    const message = "Success message";
    notifySuccess(message);
    expect(notifications.show).toHaveBeenCalledWith({
      title: "Success",
      message,
      color: "green",
    });
  });

  it("should show error notification with correct parameters", () => {
    const message = "Error message";
    notifyError(message);
    expect(notifications.show).toHaveBeenCalledWith({
      title: "Error",
      message,
      color: "red",
    });
  });

  it("should show info notification with correct parameters", () => {
    const message = "Info message";
    notifyInfo(message);
    expect(notifications.show).toHaveBeenCalledWith({
      title: "Info",
      message,
      color: "blue",
    });
  });

  it("should show warning notification with correct parameters", () => {
    const message = "Warning message";
    notifyWarning(message);
    expect(notifications.show).toHaveBeenCalledWith({
      title: "Warning",
      message,
      color: "orange",
    });
  });
});
