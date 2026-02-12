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
  Center,
  ThemeIcon,
  ScrollArea,
  Tabs,
  SegmentedControl,
  Box
} from "@mantine/core";
import { JSX, useState } from "react";
import { FiPlus, FiBookOpen, FiFileText, FiClock, FiStar, FiGrid, FiList } from "react-icons/fi";
import { DocumentCard } from "./components/DocumentCard";
import { DocumentListItem } from "./components/DocumentListItem";
import { openPdf, openPdfFromPath } from "../reader/renderer/pdfLifecycle";

export function HomeScreen(): JSX.Element {
  const { documents, deleteDocument, updateDocument } = useDocumentRepositoryStore();
  const lastOpened = useDocumentRepositoryStore((state) => state.getLastOpened());
  
  const [activeTab, setActiveTab] = useState<string | null>("recent");
  const [viewMode, setViewMode] = useState<"grid" | "list">("list");

  const displayDocs = activeTab === "recent" 
    ? [...documents].sort((a, b) => b.lastOpened - a.lastOpened)
    : documents.filter(doc => doc.starred).sort((a, b) => b.lastOpened - a.lastOpened);

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

          <Group justify="space-between" align="center">
            <Tabs value={activeTab} onChange={setActiveTab} variant="pills" radius="md">
              <Tabs.List>
                <Tabs.Tab value="recent" leftSection={<FiClock size={16} />}>
                  Recent
                </Tabs.Tab>
                <Tabs.Tab value="starred" leftSection={<FiStar size={16} />}>
                  Starred
                </Tabs.Tab>
              </Tabs.List>
            </Tabs>

            <SegmentedControl
              value={viewMode}
              onChange={(value) => setViewMode(value as "grid" | "list")}
              data={[
                { label: <Center><FiGrid size={16} /></Center>, value: "grid" },
                { label: <Center><FiList size={16} /></Center>, value: "list" },
              ]}
              radius="md"
            />
          </Group>

          {displayDocs.length > 0 ? (
            <Box>
              {viewMode === "grid" ? (
                <SimpleGrid cols={{ base: 2, sm: 3, md: 4, lg: 4 }} spacing="lg">
                  {displayDocs.map((doc) => (
                    <DocumentCard 
                      key={doc.filePath} 
                      document={doc} 
                      onClick={() => openPdfFromPath(doc.filePath)}
                      onDelete={() => deleteDocument(doc.filePath)}
                      onToggleStar={() => updateDocument(doc.filePath, { starred: !doc.starred })}
                    />
                  ))}
                </SimpleGrid>
              ) : (
                <Stack gap="sm">
                  {displayDocs.map((doc) => (
                    <DocumentListItem 
                      key={doc.filePath} 
                      document={doc} 
                      onClick={() => openPdfFromPath(doc.filePath)}
                      onDelete={() => deleteDocument(doc.filePath)}
                      onToggleStar={() => updateDocument(doc.filePath, { starred: !doc.starred })}
                    />
                  ))}
                </Stack>
              )}
            </Box>
          ) : (
            <Center py={80}>
              <Stack align="center" gap="sm">
                <ThemeIcon size={64} radius="xl" variant="light" color="gray">
                  {activeTab === "recent" ? <FiFileText size={32} /> : <FiStar size={32} />}
                </ThemeIcon>
                <Text fw={500} c="dimmed">
                  {activeTab === "recent" ? "No documents yet" : "No starred documents"}
                </Text>
                <Text size="xs" c="dimmed">
                  {activeTab === "recent" 
                    ? "Your recently opened PDFs will appear here" 
                    : "Star your favorite documents to find them quickly"}
                </Text>
              </Stack>
            </Center>
          )}
        </Stack>
      </Container>
    </ScrollArea>
  );
}
