import {
  Badge,
  Box,
  Group,
  Paper,
  Text,
  ThemeIcon,
  Title,
  UnstyledButton,
} from "@mantine/core";
import { useToolsStore } from "../stores";
import { ToolInfo } from "../types";

export function ToolCard({ tool }: { tool: ToolInfo }) {
  const { setCurrentTool } = useToolsStore();
  const Icon = tool.icon;

  return (
    <UnstyledButton
      style={{ width: "100%" }}
      onClick={() => setCurrentTool(tool)}
    >
      <Paper p="lg" radius="md" withBorder className="tool-card">
        <Group align="flex-start" wrap="nowrap" mb="sm">
          <ThemeIcon size={44} radius="md" variant="light" color={tool.color}>
            <Icon size={24} />
          </ThemeIcon>
          <Box>
            <Title order={4}>{tool.title}</Title>
            <Badge size="xs" variant="outline" color={tool.color} mt={4}>
              {tool.category.toUpperCase()}
            </Badge>
          </Box>
        </Group>
        <Text size="sm" c="dimmed" style={{ flexGrow: 1 }}>
          {tool.description}
        </Text>
      </Paper>
    </UnstyledButton>
  );
}
