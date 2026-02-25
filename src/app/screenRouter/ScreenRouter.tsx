import { JSX, ReactNode } from "react";
import {
  ActionIcon,
  Divider,
  Group,
  SegmentedControl,
  Stack,
  Text,
  Tooltip,
} from "@mantine/core";
import { SCREEN_COMPONENTS } from "./screens.registry";
import { Screen } from "@/app/types";
import { FiBookOpen, FiEdit, FiHome, FiSettings, FiTool } from "react-icons/fi";
import { useScreenState } from "@/app/screenRouter";
import { ReaderScreen } from "@/screens";
import { useDisclosure } from "@mantine/hooks";
import { SettingsDialog } from "@/dialog/settings";

export function ScreenRouter(): JSX.Element {
  const screen = useScreenState((s) => s.screen);

  const ScreenComponent = SCREEN_COMPONENTS[screen.name];

  const isReader = screen.name === "reader";

  return (
    <div
      style={{
        width: "100%",
        flex: 1,
        display: "flex",
        flexDirection: "column",
        minHeight: 0,
      }}
    >
      <ReaderScreen />
      {!isReader && <ScreenComponent />}
    </div>
  );
}

export function ScreenNavigationBar(): JSX.Element {
  const router = useScreenState();
  const screen = useScreenState((s) => s.screen);
  const [settingsOpened, { open: openSettings, close: closeSettings }] =
    useDisclosure(false);

  const setScreen = (screenName: Screen["name"]) => {
    switch (screenName) {
      case "home":
        router.goHome();
        break;
      case "reader":
        router.openReader();
        break;
      case "modify":
        router.openModify();
        break;
      case "tools":
        router.openTools();
        break;
    }
  };

  return (
    <Stack gap={0}>
      <Group
        py="4px"
        px="sm"
        justify="space-between"
        style={{ overflow: "hidden" }}
      >
        <SegmentedControl
          w={400}
          h={48}
          radius={24}
          value={screen.name}
          color="var(--mantine-primary-color-filled)"
          onChange={(value) => setScreen(value as Screen["name"])}
          styles={{
            control: {
              height: "100%",
            },
            label: {
              height: "100%",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            },
          }}
          data={[
            {
              value: "home",
              label: <SegmentLabel icon={<FiHome size={16} />} label="Home" />,
            },
            {
              value: "reader",
              label: (
                <SegmentLabel icon={<FiBookOpen size={16} />} label="Reader" />
              ),
            },
            {
              value: "modify",
              label: (
                <SegmentLabel icon={<FiEdit size={16} />} label="Modify" />
              ),
            },
            {
              value: "tools",
              label: <SegmentLabel icon={<FiTool size={16} />} label="Tools" />,
            },
          ]}
        />

        <Tooltip label="Settings" position="left">
          <ActionIcon
            variant="subtle"
            size="lg"
            radius="md"
            onClick={openSettings}
            color="gray"
          >
            <FiSettings size={20} />
          </ActionIcon>
        </Tooltip>
      </Group>
      <Divider />

      <SettingsDialog opened={settingsOpened} onClose={closeSettings} />
    </Stack>
  );
}

type SegmentLabelProps = {
  icon: ReactNode;
  label: string;
};

function SegmentLabel({ icon, label }: SegmentLabelProps): JSX.Element {
  return (
    <Group gap={6}>
      {icon}
      <Text size="sm">{label}</Text>
    </Group>
  );
}
