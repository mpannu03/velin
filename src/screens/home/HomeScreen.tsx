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
  Box,
} from "@mantine/core";
import { JSX, useState } from "react";
import {
  Plus,
  BookOpen,
  FileText,
  Clock,
  Star,
  Grid,
  List,
} from "lucide-react";
import { DocumentCard, DocumentListItem } from "./components";
import { openPdf, openPdfFromPath } from "@/pdf/reader/renderer";
import { useTranslation } from "react-i18next";

export function HomeScreen(): JSX.Element {
  const { documents, deleteDocument, updateDocument } =
    useDocumentRepositoryStore();
  const lastOpened = useDocumentRepositoryStore((state) =>
    state.getLastOpened(),
  );
  const { t } = useTranslation(["home", "common"]);

  const [activeTab, setActiveTab] = useState<string | null>("recent");
  const [viewMode, setViewMode] = useState<"grid" | "list">("list");

  const displayDocs =
    activeTab === "recent"
      ? [...documents].sort((a, b) => b.lastOpened - a.lastOpened)
      : documents
          .filter((doc) => doc.starred)
          .sort((a, b) => b.lastOpened - a.lastOpened);

  return (
    <ScrollArea h="100%">
      <Container size="lg" p="xl" h="100%">
        <Stack gap="xl" h="100%">
          <Paper
            p="xl"
            radius="md"
            withBorder
            bg="var(--mantine-primary-color-light)"
            style={{ borderStyle: "dashed", borderWidth: 2 }}
          >
            <Group justify="space-between" align="center">
              <Stack gap={4}>
                <Title order={2}>{t("welcome.title")}</Title>
                <Text c="dimmed" size="sm">
                  {t("welcome.description")}
                </Text>
              </Stack>
              <Group>
                <Button
                  leftSection={<Plus size={18} />}
                  size="md"
                  radius="md"
                  onClick={() => openPdf()}
                >
                  {t("common:file.open")}
                </Button>
                {lastOpened && (
                  <Button
                    variant="outline"
                    leftSection={<BookOpen size={18} />}
                    size="md"
                    radius="md"
                    onClick={() => openPdfFromPath(lastOpened.filePath)}
                  >
                    {t("common:file.continueReading")}
                  </Button>
                )}
              </Group>
            </Group>
          </Paper>

          <Group justify="space-between" align="center">
            <Tabs
              value={activeTab}
              onChange={setActiveTab}
              variant="pills"
              radius="md"
            >
              <Tabs.List>
                <Tabs.Tab value="recent" leftSection={<Clock size={16} />}>
                  {t("recents.title")}
                </Tabs.Tab>
                <Tabs.Tab value="starred" leftSection={<Star size={16} />}>
                  {t("starred.title")}
                </Tabs.Tab>
              </Tabs.List>
            </Tabs>

            <SegmentedControl
              value={viewMode}
              onChange={(value) => setViewMode(value as "grid" | "list")}
              data={[
                {
                  label: (
                    <Center>
                      <Grid size={16} />
                    </Center>
                  ),
                  value: "grid",
                },
                {
                  label: (
                    <Center>
                      <List size={16} />
                    </Center>
                  ),
                  value: "list",
                },
              ]}
              radius="md"
            />
          </Group>

          {displayDocs.length > 0 ? (
            <Box>
              {viewMode === "grid" ? (
                <SimpleGrid
                  cols={{ base: 2, sm: 3, md: 4, lg: 4 }}
                  spacing="lg"
                >
                  {displayDocs.map((doc) => (
                    <DocumentCard
                      key={doc.filePath}
                      document={doc}
                      onClick={() => openPdfFromPath(doc.filePath)}
                      onDelete={() => deleteDocument(doc.filePath)}
                      onToggleStar={() =>
                        updateDocument(doc.filePath, { starred: !doc.starred })
                      }
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
                      onToggleStar={() =>
                        updateDocument(doc.filePath, { starred: !doc.starred })
                      }
                    />
                  ))}
                </Stack>
              )}
            </Box>
          ) : (
            <Center py={80}>
              <Stack align="center" gap="sm">
                <ThemeIcon size={64} radius="xl" variant="light" color="gray">
                  {activeTab === "recent" ? (
                    <FileText size={32} />
                  ) : (
                    <Star size={32} />
                  )}
                </ThemeIcon>
                <Text fw={500} c="dimmed">
                  {activeTab === "recent"
                    ? t("recents.empty")
                    : t("starred.empty")}
                </Text>
                <Text size="xs" c="dimmed">
                  {activeTab === "recent"
                    ? t("recents.emptyDescription")
                    : t("starred.emptyDescription")}
                </Text>
              </Stack>
            </Center>
          )}
        </Stack>
      </Container>
    </ScrollArea>
  );
}
