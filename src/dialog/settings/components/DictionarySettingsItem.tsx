import { downloadAndInstallWordNet, isDictionaryInstalled } from "@/shared/services/dictionary";
import { Box, Button, Group, Loader, Progress, Stack, Text } from "@mantine/core";
import { notifications } from "@mantine/notifications";
import { useEffect, useState } from "react";

export function DictionarySettingsItem() {
  const [downloading, setDownloading] = useState(false);
  const [installed, setInstalled] = useState(false);
  const [checking, setChecking] = useState(true);
  const [progress, setProgress] = useState(0);
  const [stage, setStage] = useState<"idle" | "downloading" | "extracting">(
    "idle",
  );

  useEffect(() => {
    isDictionaryInstalled().then((val) => {
      setInstalled(val);
      setChecking(false);
    });
  }, []);

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
      notifications.show({
        title: "Success",
        message: "Dictionary downloaded and installed successfully",
        color: "green",
      });
      setInstalled(true);
    } catch (error) {
      console.error(error);
      notifications.show({
        title: "Error",
        message: "Failed to download dictionary",
        color: "red",
      });
    } finally {
      setDownloading(false);
      setStage("idle");
    }
  };

  return (
    <Box>
      <Group justify="space-between" align="flex-start" wrap="nowrap" mb="xs">
        <Box>
          <Text fw={500}>Dictionary Data</Text>
          <Text size="xs" c="dimmed">
            {installed
              ? "Dictionary data is installed and ready for offline use."
              : "Download dictionary data (approx. 10MB) to enable offline definitions."}
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
            {installed ? "Installed" : "Download"}
          </Button>
        )}
      </Group>

      {downloading && (
        <Stack gap="xs">
          <Group justify="space-between">
            <Text size="xs" c="dimmed">
              {stage === "downloading" ? "Downloading..." : "Extracting..."}
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