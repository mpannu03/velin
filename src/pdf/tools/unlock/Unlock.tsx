import {
  Box,
  Group,
  Paper,
  PasswordInput,
  Stack,
  Text,
  ThemeIcon,
  Tooltip,
  ActionIcon,
  Alert,
  LoadingOverlay,
  Collapse,
} from "@mantine/core";
import { Save, Pencil, Info, AlertTriangle } from "lucide-react";
import { JSX, useState } from "react";
import { useTranslation } from "react-i18next";
import { FileSelection } from "../components";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useUnlockStore } from "./unlock.store";
import { pickPdfFile, savePdfFile } from "@/services/file";

export function Unlock({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    destinationPath,
    password,
    isLoading,
    setFile,
    setDestinationPath,
    setPassword,
    runUnlock,
  } = useUnlockStore();

  const [showPasswordHint, setShowPasswordHint] = useState(false);
  const hasFile = !!file;

  const getDefaultDestination = (sourceFile: string = "image") => {
    const filename = sourceFile.split(/[/\\]/).pop() || "";
    const path = sourceFile.substring(0, sourceFile.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_unlocked.pdf`;
  };

  const pickFile = async () => {
    const selected = await pickPdfFile(false);
    if (selected && typeof selected === "string") {
      setFile(selected);
      if (!destinationPath) {
        setDestinationPath(getDefaultDestination(selected));
      }
    }
  };

  const handleChangeDestination = async () => {
    const path = await savePdfFile(
      destinationPath || getDefaultDestination(file),
    );
    if (path) {
      setDestinationPath(path);
    }
  };

  return (
    <ToolDetailShell
      tool={TOOLS.find((t) => t.id === "unlock")!}
      actionLabel={t("tools.unlock.action", { defaultValue: "Unlock PDF" })}
      onAction={runUnlock}
      onBackClick={onBackPressed}
      isValid={hasFile && !!password && !isLoading}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />
        <FileSelection onSelect={pickFile} hasFiles={hasFile} toolId="unlock">
          {file && (
            <Box>
              <Text fw={600}>{file}</Text>
            </Box>
          )}
        </FileSelection>
        {hasFile && (
          <>
            <Paper withBorder p="md" radius="md">
              <Stack gap="md">
                <Text size="sm" fw={600}>
                  {t("tools.unlock.password_label", {
                    defaultValue: "Current Password",
                  })}
                </Text>
                <PasswordInput
                  placeholder={t("tools.unlock.password_placeholder", {
                    defaultValue: "Enter current password",
                  })}
                  value={password}
                  onChange={(e) => setPassword(e.currentTarget.value)}
                  description={
                    <Group gap={4} wrap="nowrap">
                      <Info size={14} />
                      <Text size="xs" span>
                        {t("tools.unlock.password_hint", {
                          defaultValue:
                            "Enter the password used to restrict or open this PDF.",
                        })}
                      </Text>
                    </Group>
                  }
                />
                <Alert
                  icon={<AlertTriangle size={16} />}
                  title={t("tools.unlock.warning_title", {
                    defaultValue: "Remove Protection",
                  })}
                  color="red"
                  variant="light"
                >
                  <Stack gap="xs">
                    <Text size="sm">
                      {t("tools.unlock.warning_desc", {
                        defaultValue:
                          "This will permanently remove all password protection and security restrictions from the document.",
                      })}
                    </Text>
                    <Box
                      component="button"
                      type="button"
                      onClick={() => setShowPasswordHint((o) => !o)}
                      style={{
                        background: "none",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textDecoration: "underline",
                        fontSize: "inherit",
                        color: "inherit",
                        textAlign: "left",
                      }}
                    >
                      {t("tools.unlock.which_password", {
                        defaultValue: "Which password should I enter?",
                      })}
                    </Box>
                    <Collapse in={showPasswordHint}>
                      <Text size="sm" c="dimmed">
                        {t("tools.unlock.password_guide", {
                          defaultValue:
                            "If the PDF asks for a password when you open it, enter that password. If it opens without asking but has restricted features (like printing or copying), enter the password that was used to set those restrictions (the owner password).",
                        })}
                      </Text>
                    </Collapse>
                  </Stack>
                </Alert>
              </Stack>
            </Paper>
            <Paper
              withBorder
              p="md"
              radius="md"
              bg="light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-8))"
              style={{ borderStyle: "solid" }}
            >
              <Group justify="space-between" wrap="nowrap">
                <Group gap="md" wrap="nowrap" style={{ flex: 1 }}>
                  <ThemeIcon variant="light" size="lg" radius="md">
                    <Save size={20} />
                  </ThemeIcon>
                  <Box style={{ flex: 1, minWidth: 0 }}>
                    <Text size="xs" c="dimmed" tt="uppercase" fw={700} lts={1}>
                      {t("components.destination.destination_file", {
                        defaultValue: "Destination file",
                      })}
                    </Text>
                    <Text size="sm" fw={600} truncate="end">
                      {destinationPath ||
                        t("components.destination.not_set", {
                          defaultValue: "Not set",
                        })}
                    </Text>
                  </Box>
                </Group>
                <Tooltip
                  label={t("components.destination.tooltip_file", {
                    defaultValue: "Change save location",
                  })}
                  withArrow
                >
                  <ActionIcon
                    variant="light"
                    color="blue"
                    size="lg"
                    radius="md"
                    onClick={handleChangeDestination}
                  >
                    <Pencil size={18} />
                  </ActionIcon>
                </Tooltip>
              </Group>
            </Paper>
          </>
        )}
      </Stack>
    </ToolDetailShell>
  );
}
