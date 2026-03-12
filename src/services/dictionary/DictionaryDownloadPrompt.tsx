import {
  Modal,
  Stack,
  Text,
  Button,
  Progress,
  Group,
  Title,
} from "@mantine/core";
import { useState } from "react";
import { downloadAndInstallWordNet } from "@/services/dictionary";
import { notifyError, notifySuccess } from "../notifications";
import { useTranslation } from "react-i18next";

interface DictionaryDownloadPromptProps {
  opened: boolean;
  onClose: () => void;
  onComplete: () => void;
}

export function DictionaryDownloadPrompt({
  opened,
  onClose,
  onComplete,
}: DictionaryDownloadPromptProps) {
  const { t } = useTranslation("settings");
  const [downloading, setDownloading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [stage, setStage] = useState<"idle" | "downloading" | "extracting">(
    "idle",
  );

  const handleDownload = async () => {
    setDownloading(true);
    setStage("downloading");
    try {
      await downloadAndInstallWordNet((status) => {
        if (status.stage === "downloading") {
          setProgress(status.percent);
        } else if (status.stage === "extracting") {
          setStage("extracting");
        }
      });
      notifySuccess(t("general.dictionary.downloadSuccess"));
      onComplete();
      onClose();
    } catch (error) {
      notifyError(t("general.dictionary.downloadError"));
      setDownloading(false);
      setStage("idle");
    }
  };

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={<Title order={4}>{t("general.dictionary.onboardTitle")}</Title>}
      centered
      closeOnClickOutside={!downloading}
      closeOnEscape={!downloading}
      withCloseButton={!downloading}
    >
      <Stack>
        <Text size="sm">{t("general.dictionary.onboardDescription")}</Text>

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
            />
          </Stack>
        )}

        <Group justify="flex-end" mt="md">
          {!downloading && (
            <Button variant="subtle" onClick={onClose} color="gray">
              {t("general.dictionary.later")}
            </Button>
          )}
          <Button
            onClick={handleDownload}
            loading={downloading}
            disabled={downloading && stage === "extracting"}
          >
            Download Now
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
