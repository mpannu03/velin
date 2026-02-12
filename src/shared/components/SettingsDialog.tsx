import { Modal, Group, Stack, Text, Switch, Select, ColorSwatch, useMantineTheme, Box, NumberInput, ActionIcon, Title, Divider, NavLink, ScrollArea, SegmentedControl, Button, MantineTheme } from "@mantine/core";
import { useSettingsStore } from "@/app/store/settings.store";
import { FiMonitor, FiMoon, FiSun, FiSettings, FiLayout, FiGlobe, FiCheck, FiRotateCcw } from "react-icons/fi";
import { JSX, useState, useEffect } from "react";
import { AppearanceSettings, GeneralSettings, ReaderSettings, Settings, Theme } from "@/shared/types";
import { downloadAndInstallWordNet, isDictionaryInstalled } from "../services/dictionary";
import { notifications } from "@mantine/notifications";
import { Progress, Loader } from "@mantine/core";

interface SettingsDialogProps {
  opened: boolean;
  onClose: () => void;
}

const ACCENT_COLORS = [
  'velinColor', 'blue', 'red', 'green', 'violet', 'orange', 'cyan', 'pink', 'teal'
];

type SettingsSection = 'appearance' | 'reader' | 'general';

export function SettingsDialog({ opened, onClose }: SettingsDialogProps): JSX.Element {
  const { settings, updateAppearance, updateReader, updateGeneral, restoreDefaults } = useSettingsStore();
  const theme = useMantineTheme();
  const [activeSection, setActiveSection] = useState<SettingsSection>('appearance');

  return (
    <Modal 
      opened={opened} 
      onClose={onClose} 
      title={<Title order={4}>Settings</Title>}
      size="700px"
      radius="md"
      padding="0"
      overlayProps={{
        backgroundOpacity: 0.55,
        blur: 3,
      }}
      styles={{
        header: {
          padding: 'var(--mantine-spacing-md) var(--mantine-spacing-md)',
          marginBottom: 0,
        },
        content: {
          overflow: 'hidden'
        }
      }}
    >
      <Group gap={0} wrap="nowrap" align="stretch" h="500px">
        <NavigationSection
          activeSection={activeSection}
          setActiveSection={setActiveSection}
          restoreDefaults={restoreDefaults}
        />

        <Box flex={1} p="xl" style={{ display: 'flex', flexDirection: 'column' }}>
          <ScrollArea flex={1} offsetScrollbars>
            {activeSection === 'appearance' && (
              <AppearanceSection
                settings={settings}
                updateAppearance={updateAppearance}
                theme={theme}
              />
            )}

            {activeSection === 'reader' && (
              <ReaderSection
                settings={settings}
                updateReader={updateReader}
              />
            )}

            {activeSection === 'general' && (
              <GeneralSection
                settings={settings}
                updateGeneral={updateGeneral}
              />
            )}
          </ScrollArea>

          <Divider my="md" />
          <Group justify="space-between">
            <Text size="xs" c="dimmed">Velin – Free & Open Source</Text>
            <Text size="xs" c="dimmed">v0.3.0</Text>
          </Group>
        </Box>
      </Group>
    </Modal>
  );
}

function NavigationSection({
  activeSection,
  setActiveSection,
  restoreDefaults
}: {
  activeSection: SettingsSection;
  setActiveSection: (section: SettingsSection) => void;
  restoreDefaults: () => void;
}): JSX.Element {
  return(
  <Box 
    w={220} 
    bg="gray.0" 
    p="md"
    style={{ 
      borderRight: '1px solid var(--mantine-color-gray-3)',
      display: 'flex',
      flexDirection: 'column',
    }}
  >
    <Stack gap="xs" style={{ flex: 1 }}>
      <NavLink
        label="Appearance"
        leftSection={<FiMonitor size={16} />}
        active={activeSection === 'appearance'}
        onClick={() => setActiveSection('appearance')}
        variant="filled"
        style={(theme) => ({
          borderRadius: theme.radius.md,
        })}
      />
      <NavLink
        label="Reader"
        leftSection={<FiLayout size={16} />}
        active={activeSection === 'reader'}
        onClick={() => setActiveSection('reader')}
        variant="filled"
        style={(theme) => ({
          borderRadius: theme.radius.md,
        })}
      />
      <NavLink
        label="General"
        leftSection={<FiSettings size={16} />}
        active={activeSection === 'general'}
        onClick={() => setActiveSection('general')}
        variant="filled"
        style={(theme) => ({
          borderRadius: theme.radius.md,
        })}
      />
    </Stack>

    <Button 
      variant="subtle" 
      color="gray" 
      leftSection={<FiRotateCcw size={14} />}
      onClick={() => restoreDefaults()}
      fullWidth
      radius="md"
    >
      Restore Defaults
    </Button>
  </Box>
  );
}

function AppearanceSection({
  settings,
  updateAppearance,
  theme
}: {
  settings: Settings;
  updateAppearance: (settings: Partial<AppearanceSettings>) => void;
  theme: MantineTheme;
}): JSX.Element {
  return(
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Color Scheme</Text>
        <SegmentedControlCustom 
          value={settings.appearance.theme} 
          onChange={(val) => updateAppearance({ theme: val as Theme })}
        />
      </Box>

      <Divider />

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Accent Color</Text>
        <Group gap="sm">
          {ACCENT_COLORS.map((color) => (
            <ActionIcon
              key={color}
              onClick={() => updateAppearance({ accentColor: color })}
              variant={settings.appearance.accentColor === color ? 'filled' : 'light'}
              color={color}
              size="xl"
              radius="xl"
            >
              {settings.appearance.accentColor === color ? (
                <FiCheck size={18} />
              ) : (
                <ColorSwatch color={color === 'velinColor' ? theme.colors.velinColor[6] : theme.colors[color][6]} size={24} />
              )}
            </ActionIcon>
          ))}
        </Group>
      </Box>
    </Stack>
  );
}

function ReaderSection({
  settings,
  updateReader,
}: {
  settings: Settings;
  updateReader: (settings: Partial<ReaderSettings>) => void;
}): JSX.Element {
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Default View Mode</Text>
        <Select
          value={settings.reader.defaultViewMode}
          onChange={(value) => updateReader({ defaultViewMode: value as any })}
          data={[
            { label: 'Single Page', value: 'single' },
            { label: 'Continuous', value: 'continuous' },
            { label: 'Double Page', value: 'double' },
          ]}
          radius="md"
          allowDeselect={false}
        />
      </Box>

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Default Zoom Level</Text>
        <NumberInput
          value={settings.reader.defaultZoom}
          onChange={(value) => updateReader({ defaultZoom: typeof value === 'number' ? value : 1.0 })}
          min={0.1}
          max={5.0}
          step={0.1}
          decimalScale={1}
          radius="md"
        />
      </Box>

      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Scroll Sensitivity</Text>
        <NumberInput
          value={settings.reader.scrollSensitivity}
          onChange={(value) => updateReader({ scrollSensitivity: typeof value === 'number' ? value : 1.0 })}
          min={0.1}
          max={3.0}
          step={0.1}
          decimalScale={1}
          radius="md"
        />
      </Box>
    </Stack>
  );
}

function GeneralSection({
  settings,
  updateGeneral,
}: {
  settings: Settings;
  updateGeneral: (settings: Partial<GeneralSettings>) => void;
}): JSX.Element {
  return (
    <Stack gap="xl">
      <Box>
        <Text fw={600} size="sm" mb="xs" c="dimmed" tt="uppercase" lts="0.5px">Language</Text>
        <Select
          value={settings.general.language}
          onChange={(value) => updateGeneral({ language: value || 'en' })}
          data={[
            { label: 'English', value: 'en' },
            { label: 'Spanish', value: 'es' },
            { label: 'French', value: 'fr' },
            { label: 'German', value: 'de' },
          ]}
          leftSection={<FiGlobe size={16} />}
          radius="md"
          allowDeselect={false}
        />
      </Box>

      <Group justify="space-between" align="flex-start" wrap="nowrap">
        <Box>
          <Text fw={500}>Check for updates on start</Text>
          <Text size="xs" c="dimmed">The app will automatically check for new versions on launch.</Text>
        </Box>
        <Switch
          checked={settings.general.checkUpdateOnStart}
          onChange={(event) => updateGeneral({ checkUpdateOnStart: event.currentTarget.checked })}
          size="md"
        />
      </Group>

      <DictionarySettingsItem />
    </Stack>
  );
}

function SegmentedControlCustom({ value, onChange }: { value: string, onChange: (val: string) => void }) {
  return (
    <SegmentedControl
      value={value}
      onChange={onChange}
      fullWidth
      radius="md"
      data={[
        { label: <Group gap="xs" justify="center"><FiSun size={14} /> Light</Group>, value: 'light' },
        { label: <Group gap="xs" justify="center"><FiMoon size={14} /> Dark</Group>, value: 'dark' },
        { label: <Group gap="xs" justify="center"><FiMonitor size={14} /> System</Group>, value: 'system' },
      ]}
    />
  );
}
function DictionarySettingsItem() {
  const [downloading, setDownloading] = useState(false);
  const [installed, setInstalled] = useState(false);
  const [checking, setChecking] = useState(true);
  const [progress, setProgress] = useState(0);
  const [stage, setStage] = useState<'idle' | 'downloading' | 'extracting'>('idle');

  useEffect(() => {
    isDictionaryInstalled().then((val) => {
      setInstalled(val);
      setChecking(false);
    });
  }, []);

  const handleDownload = async () => {
    setDownloading(true);
    setStage('downloading');
    try {
      await downloadAndInstallWordNet((status) => {
        if (status.stage === 'downloading') {
          setProgress(status.percent);
        } else if (status.stage === 'extracting') {
          setStage('extracting');
        }
      });
      notifications.show({
        title: 'Success',
        message: 'Dictionary downloaded and installed successfully',
        color: 'green',
      });
      setInstalled(true);
    } catch (error) {
      console.error(error);
      notifications.show({
        title: 'Error',
        message: 'Failed to download dictionary',
        color: 'red',
      });
    } finally {
      setDownloading(false);
      setStage('idle');
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
                {stage === 'downloading' ? 'Downloading...' : 'Extracting...'}
              </Text>
              {stage === 'downloading' && <Text size="xs" c="dimmed">{progress}%</Text>}
            </Group>
          <Progress value={stage === 'extracting' ? 100 : progress} animated={stage === 'extracting'} size="sm" />
        </Stack>
      )}
    </Box>
  );
}

