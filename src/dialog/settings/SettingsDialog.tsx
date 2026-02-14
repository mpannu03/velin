import {
  Modal,
  Group,
  Stack,
  Text,
  Divider,
  ScrollArea,
} from "@mantine/core";
import { useSettingsStore } from "@/app";
import { JSX, useState } from "react";
import { NavigationSection, AppearanceSection, ReaderSection, GeneralSection } from "./components";

interface SettingsDialogProps {
  opened: boolean;
  onClose: () => void;
}

declare const __APP_VERSION__: string;

export type SettingsSection = "appearance" | "reader" | "general";

export function SettingsDialog({
  opened,
  onClose,
}: SettingsDialogProps): JSX.Element {
  const {
    settings,
    updateAppearance,
    updateReader,
    updateGeneral,
    restoreDefaults,
  } = useSettingsStore();
  const [activeSection, setActiveSection] = useState<SettingsSection>("appearance");

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={
        <Text size="xl" fw="600">
          Settings
        </Text>
      }
      size="700px"
      radius="md"
      padding="0"
      styles={{
        header: {
          padding: "var(--mantine-spacing-md) var(--mantine-spacing-md)",
        },
        content: {
          overflow: "hidden",
        },
      }}
    >
      <Group gap={0} align="stretch" h="500px">
        <NavigationSection
          activeSection={activeSection}
          setActiveSection={setActiveSection}
          restoreDefaults={restoreDefaults}
        />

        <Stack
          flex={1}
          p="xl"
        >
          <ScrollArea flex={1} offsetScrollbars>
            {activeSection === "appearance" && (
              <AppearanceSection
                settings={settings}
                updateAppearance={updateAppearance}
              />
            )}

            {activeSection === "reader" && (
              <ReaderSection
                settings={settings} 
                updateReader={updateReader} 
              />
            )}

            {activeSection === "general" && (
              <GeneralSection
                settings={settings}
                updateGeneral={updateGeneral}
              />
            )}
          </ScrollArea>

          <Divider my="md" />
          <Group justify="space-between">
            <Text size="xs" c="dimmed">
              Velin – Free & Open Source
            </Text>
            <Text size="xs" c="dimmed">
              v{__APP_VERSION__}
            </Text>
          </Group>
        </Stack>
      </Group>
    </Modal>
  );
}
