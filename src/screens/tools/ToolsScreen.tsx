import {
  Container,
  Stack,
  SimpleGrid,
  Paper,
  Text,
  TextInput,
  Group,
  ScrollArea,
  UnstyledButton,
  Transition,
  Badge,
} from "@mantine/core";
import { JSX, useState, useMemo } from "react";
import { FiSearch } from "react-icons/fi";
import { CATEGORIES, TOOLS } from "./types";
import {
  ToolCard,
  ToolDetailShell,
  MergePreferences,
  SplitPreferences,
  CompressPreferences,
  ImagePreferences,
  SecurityPreferences,
  EditPreferences,
} from "./components";
import { useToolsStore } from "./stores";

export function ToolsScreen(): JSX.Element {
  const currentTool = useToolsStore((s) => s.currentTool);
  const [search, setSearch] = useState("");
  const [activeCategory, setActiveCategory] = useState("all");

  const filteredTools = useMemo(() => {
    return TOOLS.filter((tool) => {
      const matchesSearch =
        tool.title.toLowerCase().includes(search.toLowerCase()) ||
        tool.description.toLowerCase().includes(search.toLowerCase());
      const matchesCategory =
        activeCategory === "all" || tool.category === activeCategory;
      return matchesSearch && matchesCategory;
    });
  }, [search, activeCategory]);

  // If a tool is selected, show its detail view
  if (currentTool) {
    return (
      <ToolDetailShell
        tool={currentTool}
        actionLabel={`${currentTool.title}`}
        onAction={() => console.log(`Running ${currentTool.id}`)}
      >
        {renderToolPreferences(currentTool.id)}
      </ToolDetailShell>
    );
  }

  return (
    <ScrollArea h="100%" scrollbars="y" type="hover">
      <Container size="lg" py="xl">
        <Stack gap="xl">
          <Group justify="space-between" align="center" wrap="nowrap">
            <Group gap="xs" style={{ overflowX: "auto", flexShrink: 1 }}>
              {CATEGORIES.map((cat) => (
                <UnstyledButton
                  key={cat.value}
                  onClick={() => setActiveCategory(cat.value)}
                >
                  <Badge
                    variant={activeCategory === cat.value ? "filled" : "light"}
                    size="lg"
                    radius="md"
                    style={{ cursor: "pointer", transition: "all 0.2s ease" }}
                  >
                    {cat.label}
                  </Badge>
                </UnstyledButton>
              ))}
            </Group>

            <TextInput
              placeholder="Search tools..."
              leftSection={<FiSearch size={16} />}
              value={search}
              onChange={(e) => setSearch(e.currentTarget.value)}
              radius="md"
              w={{ base: "100%", sm: 300 }}
            />
          </Group>

          <Transition
            mounted={true}
            transition="fade"
            duration={400}
            timingFunction="ease"
          >
            {(transitionStyles) => (
              <div style={transitionStyles}>
                <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }} spacing="lg">
                  {filteredTools.map((tool) => (
                    <ToolCard key={tool.id} tool={tool} />
                  ))}
                </SimpleGrid>

                {filteredTools.length === 0 && (
                  <Paper
                    p="xl"
                    withBorder
                    radius="md"
                    style={{ textAlign: "center" }}
                  >
                    <Text c="dimmed">No tools found matching your search.</Text>
                  </Paper>
                )}
              </div>
            )}
          </Transition>
        </Stack>
      </Container>
      <style>{`
        .tool-card {
          transition: all 0.2s ease;
          height: 100%;
          display: flex;
          flex-direction: column;
          background-color: light-dark(var(--mantine-color-white), var(--mantine-color-dark-7));
        }
        .tool-card:hover {
          transform: translateY(-4px);
          box-shadow: var(--mantine-shadow-md);
          border-color: var(--mantine-primary-color-filled);
        }
      `}</style>
    </ScrollArea>
  );
}

function renderToolPreferences(toolId: string): JSX.Element {
  switch (toolId) {
    case "merge":
      return <MergePreferences />;
    case "split":
      return <SplitPreferences />;
    case "compress":
      return <CompressPreferences />;
    case "pdf-to-image":
      return <ImagePreferences title="PDF to Image" />;
    case "image-to-pdf":
      return <ImagePreferences title="Image to PDF" />;
    case "protect":
      return <SecurityPreferences mode="protect" />;
    case "unlock":
      return <SecurityPreferences mode="unlock" />;
    case "rotate":
    case "watermark":
    case "extract":
      return <EditPreferences toolId={toolId} />;
    default:
      return (
        <Paper p="xl" withBorder radius="md">
          <Text c="dimmed">Preferences for this tool are coming soon.</Text>
        </Paper>
      );
  }
}
