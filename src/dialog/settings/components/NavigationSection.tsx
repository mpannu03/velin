import { JSX } from "react";
import { Box, Button, NavLink, Stack } from "@mantine/core";
import { FiMonitor, FiLayout, FiSettings, FiRotateCcw } from "react-icons/fi";
import { SettingsSection } from "@/dialog/settings";

export function NavigationSection({
  activeSection,
  setActiveSection,
  restoreDefaults,
}: {
  activeSection: SettingsSection;
  setActiveSection: (section: SettingsSection) => void;
  restoreDefaults: () => void;
}): JSX.Element {
  return (
    <Box
      w={220}
      bg="light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-6))"
      p="md"
      style={{
        borderRight: "1px solid light-dark(var(--mantine-color-gray-3), var(--mantine-color-dark-4))",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <Stack gap="xs" style={{ flex: 1 }}>
        <NavLink
          label="Appearance"
          leftSection={<FiMonitor size={16} />}
          active={activeSection === "appearance"}
          onClick={() => setActiveSection("appearance")}
          variant="filled"
          style={(theme) => ({
            borderRadius: theme.radius.md,
          })}
        />
        <NavLink
          label="Reader"
          leftSection={<FiLayout size={16} />}
          active={activeSection === "reader"}
          onClick={() => setActiveSection("reader")}
          variant="filled"
          style={(theme) => ({
            borderRadius: theme.radius.md,
          })}
        />
        <NavLink
          label="General"
          leftSection={<FiSettings size={16} />}
          active={activeSection === "general"}
          onClick={() => setActiveSection("general")}
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