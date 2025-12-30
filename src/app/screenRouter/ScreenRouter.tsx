import { JSX, ReactNode } from "react";
import { Divider, Group, SegmentedControl, Stack, Text } from "@mantine/core";
import { SCREEN_COMPONENTS } from "./screens.registry";
import { Screen } from '../types'
import { FiBookOpen, FiEdit, FiHome, FiTool } from "react-icons/fi";
import { useScreenState } from "./store/screen.store";
import { ReaderScreen } from "@/screens";

export function ScreenRouter(): JSX.Element {
  const screen = useScreenState((s) => s.screen);

  const ScreenComponent = SCREEN_COMPONENTS[screen.name];

  return(
    <Stack
      gap={0}
      style={{ overflow: 'hidden'}}
    >
      <ScreenComponent />
      <ReaderScreen visible={screen.name === 'reader'} />
    </Stack>
  );
};

export function ScreenNavigationBar(): JSX.Element {
  const router = useScreenState();
  const screen = useScreenState((s) => s.screen);

  const setScreen = (screenName: Screen['name']) => {
    switch (screenName) {
      case 'home':
        router.goHome();
        break;
      case 'reader':
        router.openReader();
        break;
      case 'modify':
        router.openModify();
        break;
      case 'tools':
        router.openTools();
        break;
    }
  }

  return(
    <Stack
      gap={0}
    >
      <Group
        py="4px"
        px="sm"
        style={{ overflow: 'hidden' }}
      >
        <SegmentedControl
          w={400}
          h={48}
          radius={24}
          value={screen.name}
          onChange={(value) => setScreen(value as Screen['name'])}
          styles={{
            control: {
              height: '100%',
            },
            label: {
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            },
          }}
          data={[
            {
              value: 'home',
              label: <SegmentLabel icon={<FiHome size={16} />} label="Home" />
            },
            {
              value: 'reader',
              label: <SegmentLabel icon={<FiBookOpen size={16} />} label="Reader" />
            },
            {
              value: 'modify',
              label: <SegmentLabel icon={<FiEdit size={16} />} label="Modify" />
            },
            {
              value: 'tools',
              label: <SegmentLabel icon={<FiTool size={16} />} label="Tools" />
            },
          ]}
        />
      </Group>
      <Divider />
    </Stack>
  );
};

type SegmentLabelProps = {
  icon: ReactNode;
  label: string;
};

function SegmentLabel({ icon, label }: SegmentLabelProps): JSX.Element {
  return(
    <Group gap={6}>
      {icon}
      <Text size="sm">{label}</Text>
    </Group>
  );
}