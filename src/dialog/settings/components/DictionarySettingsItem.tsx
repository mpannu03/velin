import {
  downloadAndInstallWordNet,
  isDictionaryInstalled,
  WordnetInstallStatus,
} from "@/services/dictionary";
import { notifyError, notifySuccess } from "@/services/notifications";
import {
  Box,
  Button,
  Group,
  Loader,
  Progress,
  Stack,
  Text,
} from "@mantine/core";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

export function DictionarySettingsItem() {
  const { t } = useTranslation("settings");
  const [downloading, setDownloading] = useState(false);
  const [installed, setInstalled] = useState(false);
  const [checking, setChecking] = useState(true);
  const [progress, setProgress] = useState(0);
  const [stage, setStage] = useState<"idle" | "downloading" | "extracting">(
    "idle",
  );

  useEffect(() => {
    isDictionaryInstalled().then((val: boolean) => {
      setInstalled(val);
      setChecking(false);
    });
  }, []);

  const handleDownload = async () => {
    setDownloading(true);
    setStage("downloading");
    try {
      await downloadAndInstallWordNet((status: WordnetInstallStatus) => {
        if (status.stage === "downloading") {
          setProgress(status.percent);
        } else if (status.stage === "extracting") {
          setStage("extracting");
        }
      });
      notifySuccess(t("general.dictionary.downloadSuccess"));
      setInstalled(true);
    } catch (error) {
      notifyError(t("general.dictionary.downloadError"));
    } finally {
      setDownloading(false);
      setStage("idle");
    }
  };

  return (
    <Box>
      <Group justify="space-between" align="flex-start" wrap="nowrap" mb="xs">
        <Box>
          <Text fw={500}>{t("general.dictionary.title")}</Text>
          <Text size="xs" c="dimmed">
            {installed
              ? t("general.dictionary.installedDescription")
              : t("general.dictionary.notInstalledDescription")}
          </Text>
        </Box>
        {checking ? (
          <Loader size="sm" />
        ) : (
          <Button
            w="128px"
            variant={installed ? "outline" : "filled"}
            color={installed ? "green" : "var(--mantine-color-primary)"}
            onClick={installed ? undefined : handleDownload}
            disabled={installed || downloading}
            loading={downloading}
          >
            {installed
              ? t("general.dictionary.installed")
              : t("general.dictionary.download")}
          </Button>
        )}
      </Group>

      {downloading && (
        <Stack gap="xs">
          <Group justify="space-between">
            <Text size="xs" c="dimmed">
              {stage === "downloading"
                ? t("general.dictionary.downloading")
                : t("general.dictionary.extracting")}
            </Text>
            {stage === "downloading" && (
              <Text size="xs" c="dimmed">
                {progress}%
              </Text>
            )}
          </Group>
          <Progress
            value={stage === "extracting" ? 100 : progress}
            animated={stage === "extracting"}
            size="sm"
          />
        </Stack>
      )}
    </Box>
  );
}
