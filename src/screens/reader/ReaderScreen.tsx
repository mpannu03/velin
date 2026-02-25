import { useDocumentsStore } from "@/app/store/documents.store";
import { JSX } from "react";
import { PdfView } from "./components/PdfView";
import { useScreenState } from "@/app/screenRouter";
import { Button, Stack, Text, Title, ThemeIcon, Center } from "@mantine/core";
import { FiPlus, FiFileText } from "react-icons/fi";
import { openPdf } from "./renderer/";

export function ReaderPlaceholder(): JSX.Element {
  return (
    <div
      style={{ flex: 1, backgroundColor: "var(--mantine-color-gray-0)" }}
    ></div>
  );
}

export function ReaderScreen(): JSX.Element {
  const documents = useDocumentsStore((state) => state.documents);
  const screen = useScreenState((s) => s.screen);

  if (Object.keys(documents).length === 0 && screen.name === "reader") {
    return <NoDocumentOpened />;
  }

  return (
    <div
      style={{
        height: "100%",
        flexDirection: "column",
        background:
          "light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-6))",
        position: "relative",
        flex: 1,
        overflow: "hidden",
      }}
    >
      {Object.values(documents).map(
        (doc): JSX.Element => (
          <PdfView key={doc.id} doc={doc} />
        ),
      )}
    </div>
  );
}

function NoDocumentOpened(): JSX.Element {
  return (
    <Center
      style={{
        width: "100%",
        flex: 1,
      }}
    >
      <Stack align="center" gap="xl">
        <ThemeIcon
          size={120}
          radius={100}
          variant="light"
          color="var(--mantine-primary-color-filled)"
          style={{
            boxShadow: "0 10px 30px rgba(0,0,0,0.05)",
          }}
        >
          <FiFileText size={60} />
        </ThemeIcon>

        <Stack gap="xs" align="center">
          <Title order={2} fw={800} c="brightness(1.2)" ta="center">
            No Open Documents
          </Title>
          <Text c="dimmed" size="lg" maw={320} ta="center" fw={500}>
            Your reader is currently empty. Open a PDF file to start reading and
            annotating.
          </Text>
        </Stack>

        <Button
          size="lg"
          radius="xl"
          px={40}
          variant="filled"
          onClick={() => openPdf()}
          leftSection={<FiPlus size={20} />}
        >
          Open Document
        </Button>
      </Stack>
    </Center>
  );
}
