import { useDocumentRepositoryStore } from "@/app/store/repository.store";
import { useDocumentsStore } from "@/app/store/documents.store";
import { useScreenState } from "@/app/screenRouter";
import { pickPdfFile } from "@/shared/services/filePicker";
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
  ThemeIcon
} from "@mantine/core";
import { JSX } from "react";
import { FiPlus, FiBookOpen, FiFileText } from "react-icons/fi";
import { DocumentCard } from "./components/DocumentCard";

export function HomeScreen(): JSX.Element {
  const { documents, deleteDocument, updateDocument } = useDocumentRepositoryStore();
  const lastOpened = useDocumentRepositoryStore((state) => state.getLastOpened());
  const openDoc = useDocumentsStore((state) => state.open);
  const router = useScreenState();

  const handleOpenPdf = async (path?: string) => {
    const filePath = path || await pickPdfFile();
    if (filePath) {
      const result = await openDoc(filePath);
      if (result.ok) {
        router.openReader();
      }
    }
  };

  const recentDocs = [...documents].sort(
    (a, b) => b.lastOpened- a.lastOpened
  ).slice(0, 8);

  return (
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
                onClick={() => handleOpenPdf()}
              >
                Open PDF
              </Button>
              {lastOpened && (
                <Button 
                  variant="outline" 
                  leftSection={<FiBookOpen size={18} />} 
                  size="md" 
                  radius="md"
                  onClick={() => handleOpenPdf(lastOpened.filePath)}
                >
                  Continue Reading
                </Button>
              )}
            </Group>
          </Group>
        </Paper>

        <Divider label="Recent Documents" labelPosition="left" />

        {recentDocs.length > 0 ? (
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3, lg: 4 }} spacing="md">
            {recentDocs.map((doc) => (
              <DocumentCard 
                key={doc.filePath} 
                document={doc} 
                onClick={() => handleOpenPdf(doc.filePath)}
                onDelete={() => deleteDocument(doc.filePath)}
                onToggleStar={() => updateDocument({ ...doc, starred: !doc.starred })}
              />
            ))}
          </SimpleGrid>
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
  );
}