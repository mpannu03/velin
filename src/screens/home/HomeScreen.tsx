import { useDocumentRepositoryStore } from "@/app/store/repository.store";
import { 
  Button, 
  Group, 
  Stack, 
  Container, 
  Title, 
  Text, 
  SimpleGrid, 
  Paper, 
  Divider,
  Center,
  ThemeIcon,
  ScrollArea
} from "@mantine/core";
import { JSX } from "react";
import { FiPlus, FiBookOpen, FiFileText } from "react-icons/fi";
import { DocumentCard } from "./components/DocumentCard";
import { openPdf, openPdfFromPath } from "../reader/renderer/pdfLifecycle";

export function HomeScreen(): JSX.Element {
  const { documents, deleteDocument, updateDocument } = useDocumentRepositoryStore();
  const lastOpened = useDocumentRepositoryStore((state) => state.getLastOpened());

  const recentDocs = [...documents].sort(
    (a, b) => b.lastOpened- a.lastOpened
  ).slice(0, 8);

  return (
    <ScrollArea h="100%">
      <Container size="lg" p="xl" h="100%">
        <Stack gap="xl" h="100%">
          <Paper 
            p="xl" 
            radius="md" 
            withBorder 
            bg="var(--mantine-color-blue-light)"
            style={{ borderStyle: 'dashed', borderWidth: 2 }}
          >
            <Group justify="space-between" align="center">
              <Stack gap={4}>
                <Title order={2}>Welcome back</Title>
                <Text c="dimmed" size="sm">
                  Open a PDF to start reading or continue where you left off.
                </Text>
              </Stack>
              <Group>
                <Button 
                  leftSection={<FiPlus size={18} />} 
                  size="md" 
                  radius="md"
                  onClick={() => openPdf()}
                >
                  Open PDF
                </Button>
                {lastOpened && (
                  <Button 
                    variant="outline" 
                    leftSection={<FiBookOpen size={18} />} 
                    size="md" 
                    radius="md"
                    onClick={() => openPdfFromPath(lastOpened.filePath)}
                  >
                    Continue Reading
                  </Button>
                )}
              </Group>
            </Group>
          </Paper>

          <Divider label="Recent Documents" labelPosition="left" />

          {recentDocs.length > 0 ? (
            <Center>
              <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }} spacing="xl">
                {recentDocs.map((doc) => (
                  <DocumentCard 
                    key={doc.filePath} 
                    document={doc} 
                    onClick={() => openPdfFromPath(doc.filePath)}
                    onDelete={() => deleteDocument(doc.filePath)}
                    onToggleStar={() => updateDocument(doc.filePath, { starred: !doc.starred })}
                  />
                ))}
              </SimpleGrid>
            </Center>
          ) : (
            <Center py={80}>
              <Stack align="center" gap="sm">
                <ThemeIcon size={64} radius="xl" variant="light" color="gray">
                  <FiFileText size={32} />
                </ThemeIcon>
                <Text fw={500} c="dimmed">No documents yet</Text>
                <Text size="xs" c="dimmed">Your recently opened PDFs will appear here</Text>
              </Stack>
            </Center>
          )}
        </Stack>
      </Container>
    </ScrollArea>
  );
}