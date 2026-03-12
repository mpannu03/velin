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
import { ToolInfo } from "@/pdf/tools";
import { useTranslation } from "react-i18next";

export function ToolCard({ tool }: { tool: ToolInfo }) {
  const { setCurrentTool } = useToolsStore();
  const Icon = tool.icon;
  const { t } = useTranslation("tools");

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
            <Title order={4}>{t(`tools.${tool.id}.title`)}</Title>
            <Badge size="xs" variant="outline" color={tool.color} mt={4}>
              {t(`category.${tool.category}`)}
            </Badge>
          </Box>
        </Group>
        <Text size="sm" c="dimmed" style={{ flexGrow: 1 }}>
          {t(`tools.${tool.id}.description`)}
        </Text>
      </Paper>
    </UnstyledButton>
  );
}
