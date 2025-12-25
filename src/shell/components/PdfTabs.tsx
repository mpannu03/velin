import { ActionIcon, Divider, Group, Text } from "@mantine/core";
import { JSX } from "react";
import { PdfDocument } from "@/shared/types";
import { FiPlus, FiX } from "react-icons/fi";
import { pickPdfFile } from "@/shared/services";
import { useHover } from "@mantine/hooks";
import { useDocumentsStore } from "@/app/store/documents.store";

export function PdfTabs(): JSX.Element {
  const pdfStore = useDocumentsStore();
  const docs = useDocumentsStore((s) => s.documents);

  const handleOpenPdf = async () => {
    const filePath = await pickPdfFile();
    if (!filePath) return;

    pdfStore.open(filePath);
  }

  return(
    <Group
      gap={0}
      h="100%"
    >
      {Object.entries(docs).map(([key, doc]) => (
        <Group key={key} gap={0} h="100%">
          <Tab key={key} tab={doc} />
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
  const pdfStore = useDocumentsStore();
  const selectedTab = useDocumentsStore((s) => s.activeDocumentId);

  return(
    <Group
      ref={ref}
      bg={selectedTab === tab.id
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
      onClick={() => pdfStore.setActive(tab.id)}
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
        onClick={() => pdfStore.close(tab.id)}
      >
        <FiX />
      </ActionIcon>
    </Group>
  );
}