import { ActionIcon, Divider, Group, Text } from "@mantine/core";
import { JSX } from "react";
import { PdfDocument } from "@/shared/types";
import { FiPlus, FiX } from "react-icons/fi";
import { pickPdfFile } from "@/shared/services";
import { useHover } from "@mantine/hooks";
import { useDocumentsStore } from "@/app/store/documents.store";
import { notifications } from "@mantine/notifications";
import { usePageCacheStore } from "@/screens/reader/stores/usePageCacheStore";

export function PdfTabs(): JSX.Element {
  const pdfStore = useDocumentsStore();
  const docs = useDocumentsStore((s) => s.documents);

  const handleOpenPdf = async () => {
    const filePath = await pickPdfFile();
    if (!filePath) {
      notifications.show({
        title: "Error",
        message: "Error Opening Pdf",
      });

      return;
    };

    const result = await pdfStore.open(filePath);

    if (!result.ok) {
      notifications.show({
        title: "Error Opening Pdf.",
        message: result.error,
      });
    }
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

  const handleClosePdf = async (id: string) => {
    const result = await pdfStore.close(id);
      if (!result.ok) {
        notifications.show({
          title: "Error Closing Pdf.",
          message: result.error,
        });
      } else {
        usePageCacheStore.getState().purgeDocument(id);
      }
  }

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
        onClick={() => handleClosePdf(tab.id)}
      >
        <FiX />
      </ActionIcon>
    </Group>
  );
}