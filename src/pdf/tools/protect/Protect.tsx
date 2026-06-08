import {
  Box,
  Checkbox,
  Divider,
  Group,
  Paper,
  PasswordInput,
  Stack,
  Text,
  Tooltip,
  ActionIcon,
  Alert,
  ThemeIcon,
  LoadingOverlay,
} from "@mantine/core";
import { Shield, Save, Pencil } from "lucide-react";
import { JSX } from "react";
import { useTranslation } from "react-i18next";
import { FileSelection } from "../components";
import { ToolPreferencesProps, TOOLS } from "../types";
import { ToolDetailShell } from "../components";
import { useProtectStore } from "./protect.store";
import { pickPdfFile, savePdfFile } from "@/services/file";

export function Protect({ onBackPressed }: ToolPreferencesProps): JSX.Element {
  const { t } = useTranslation("tools");
  const {
    file,
    destinationPath,
    password,
    confirmPassword,
    requirePasswordToOpen,
    permissions,
    isLoading,
    setFile,
    setDestinationPath,
    setPassword,
    setConfirmPassword,
    setRequirePasswordToOpen,
    togglePermission,
    runProtect,
  } = useProtectStore();

  const hasFile = !!file;
  const MIN_PASSWORD_LENGTH = 8;
  const passwordValid = password.length >= MIN_PASSWORD_LENGTH;
  const passwordsMatch = password === confirmPassword;

  const getDefaultDestination = (sourceFile: string = "image") => {
    const filename = sourceFile.split(/[/\\]/).pop() || "";
    const path = sourceFile.substring(0, sourceFile.lastIndexOf(filename));
    const nameWithoutExt = filename.replace(/\.[^/.]+$/, "");
    return `${path}${nameWithoutExt}_secured.pdf`;
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
      tool={TOOLS.find((t) => t.id === "protect")!}
      actionLabel={t("tools.protect.action", { defaultValue: "Protect PDF" })}
      onAction={runProtect}
      onBackClick={onBackPressed}
      isValid={hasFile && passwordValid && !isLoading && passwordsMatch}
    >
      <Stack gap="lg" pos="relative">
        <LoadingOverlay visible={isLoading} zIndex={1000} />
        <FileSelection onSelect={pickFile} hasFiles={hasFile} toolId="protect">
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
                  {t("tools.protect.password_label", {
                    defaultValue: "Password",
                  })}
                </Text>
                <PasswordInput
                  placeholder={t("tools.protect.password_placeholder", {
                    defaultValue: "Enter password",
                  })}
                  value={password}
                  onChange={(e) => setPassword(e.currentTarget.value)}
                />
                {password.length > 0 &&
                  password.length < MIN_PASSWORD_LENGTH && (
                    <Alert
                      color="red"
                      icon={<Shield size={16} />}
                      title={t("tools.protect.password_error.title", {
                        defaultValue: "Password too short",
                      })}
                    >
                      {t("tools.protect.password_error.desc", {
                        defaultValue: `Password must be at least ${MIN_PASSWORD_LENGTH} characters.`,
                      })}
                    </Alert>
                  )}
                <Text size="sm" fw={600}>
                  {t("tools.protect.confirm_password", {
                    defaultValue: "Confirm Password",
                  })}
                </Text>
                <PasswordInput
                  placeholder={t("tools.protect.password_placeholder", {
                    defaultValue: "Confirm password",
                  })}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.currentTarget.value)}
                />
                {!passwordsMatch && confirmPassword.length > 0 && (
                  <Alert
                    color="red"
                    icon={<Shield size={16} />}
                    title={t("tools.protect.password_mismatch", {
                      defaultValue: "Password do not match",
                    })}
                  >
                    {t("tools.protect.password_mismatch", {
                      defaultValue: "Password do not match",
                    })}
                  </Alert>
                )}
                <Checkbox
                  label={t("tools.protect.require_password_to_open", {
                    defaultValue: "Require password to open document",
                  })}
                  checked={requirePasswordToOpen}
                  onChange={(e) =>
                    setRequirePasswordToOpen(e.currentTarget.checked)
                  }
                  size="sm"
                />
                <Divider
                  label={t("tools.protect.permissions", {
                    defaultValue: "Permissions",
                  })}
                  labelPosition="center"
                />
                <Stack gap="xs">
                  <Checkbox
                    label={t("tools.protect.allow_printing", {
                      defaultValue: "Allow Printing",
                    })}
                    checked={permissions.printing}
                    onChange={() => togglePermission("printing")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_high_quality_printing", {
                      defaultValue: "Allow High Quality Printing",
                    })}
                    checked={permissions.highQualityPrinting}
                    onChange={() => togglePermission("highQualityPrinting")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_modifying", {
                      defaultValue: "Allow Modifying",
                    })}
                    checked={permissions.modifying}
                    onChange={() => togglePermission("modifying")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_copy", {
                      defaultValue: "Allow Content Copying",
                    })}
                    checked={permissions.copying}
                    onChange={() => togglePermission("copying")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_annotating", {
                      defaultValue: "Allow Commenting & Annotations",
                    })}
                    checked={permissions.annotating}
                    onChange={() => togglePermission("annotating")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_form_filling", {
                      defaultValue: "Allow Form Filling",
                    })}
                    checked={permissions.formFilling}
                    onChange={() => togglePermission("formFilling")}
                  />
                  <Checkbox
                    label={t("tools.protect.allow_assembly", {
                      defaultValue: "Allow Document Assembly",
                    })}
                    checked={permissions.assembly}
                    onChange={() => togglePermission("assembly")}
                  />
                </Stack>
                <Alert
                  icon={<Shield size={16} />}
                  title={t("tools.protect.encryption_level", {
                    defaultValue: "Encryption Level",
                  })}
                  color="green"
                  variant="light"
                >
                  {t("tools.protect.encryption_desc", {
                    defaultValue:
                      "Document will be encrypted with AES-256 bit security standard.",
                  })}
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
