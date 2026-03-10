import { notifications } from "@mantine/notifications";

export function notifySuccess(message: string) {
  notifications.show({
    title: "Success",
    message,
    color: "green",
  });
}

export function notifyError(message: string) {
  notifications.show({
    title: "Error",
    message,
    color: "red",
  });
}

export function notifyInfo(message: string) {
  notifications.show({
    title: "Info",
    message,
    color: "blue",
  });
}

export function notifyWarning(message: string) {
  notifications.show({
    title: "Warning",
    message,
    color: "orange",
  });
}
