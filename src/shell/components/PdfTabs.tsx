import { ActionIcon, Divider, Group, Text } from "@mantine/core";
import { JSX } from "react";
import { usePdfTabs } from "@/shared/store";
import { PdfDocument } from "@/shared/types";
import { FiPlus, FiX } from "react-icons/fi";
import { pickPdfFile } from "@/shared/services";
import { useHover } from "@mantine/hooks";

export function PdfTabs(): JSX.Element {
  const pdfStore = usePdfTabs();
  const tabs = usePdfTabs((s) => s.tabs);

  const handleOpenPdf = async () => {
    const filePath = await pickPdfFile();
    if (!filePath) return;

    pdfStore.openPdf(filePath);
  }

  return(
    <Group
      gap={0}
      h="100%"
    >
      {tabs.map((tab) => (
        <Group gap={0} h="100%">
          <Tab key={tab.filePath} tab={tab} />
          <Divider
            orientation="vertical"
            my={4}
          />
        </Group>
      ))}
      <ActionIcon
        w={36}
        h={36}
        variant="subtle"
        onClick={() => handleOpenPdf()}
      >
        <FiPlus size={18} />
      </ActionIcon>
    </Group>
  );
}

type TabProps = {
  tab: PdfDocument;
}

function Tab({ tab }: TabProps): JSX.Element {
  const { hovered, ref } = useHover();
  const pdfStore = usePdfTabs();
  const selectedTab = usePdfTabs((s) => s.activeTab);

  return(
    <Group
      ref={ref}
      bg={selectedTab === tab.filePath
        ? "var(--mantine-color-body)"
        : hovered
          ? "var(--mantine-primary-color-light-hover)"
          : "var(--mantine-color-disabled)"}
      w={200}
      gap={0}
      h="100%"
      justify="space-between"
      align="center"
      pl="sm"
      onClick={() => pdfStore.setActivePdf(tab.filePath)}
      style={{
        cursor: "default",
        userSelect: "none",
        borderTopLeftRadius: "var(--mantine-radius-md)",
        borderTopRightRadius: "var(--mantine-radius-md)",
      }}
    >
      <Text
        truncate
        size="xs"
        fw={500}
        c="dark.7"
        style={{
          flex: 1,
          minWidth: 0,
        }}
      >
        {tab.title}
      </Text>
      <ActionIcon
        variant="subtle"
        onClick={() => pdfStore.closePdf(tab.filePath)}
      >
        <FiX />
      </ActionIcon>
    </Group>
  );
}