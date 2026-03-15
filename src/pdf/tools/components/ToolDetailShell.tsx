import {
  ActionIcon,
  Box,
  Button,
  Container,
  Divider,
  Group,
  Stack,
  Text,
  ThemeIcon,
  Title,
  ScrollArea,
} from "@mantine/core";
import { JSX, ReactNode } from "react";
import { ArrowLeft, Play } from "lucide-react";
import { ToolInfo } from "@/pdf/tools";
import { useTranslation } from "react-i18next";

interface ToolDetailShellProps {
  tool: ToolInfo;
  children: ReactNode;
  actionLabel?: string;
  onBackClick?: () => void;
  onAction?: () => void;
  isValid?: boolean;
}

export function ToolDetailShell({
  tool,
  children,
  actionLabel = "Run Tool",
  onBackClick,
  onAction,
  isValid = true,
}: ToolDetailShellProps): JSX.Element {
  const { t } = useTranslation("tools");
  const Icon = tool.icon;

  return (
    <ScrollArea h="100%" scrollbars="y" type="hover">
      <Container size="lg" py="xl">
        <Stack gap="xl">
          <Group justify="space-between">
            <Group gap="md">
              <ActionIcon
                variant="light"
                size="lg"
                radius="md"
                onClick={onBackClick}
                color="gray"
              >
                <ArrowLeft size={20} />
              </ActionIcon>
              <ThemeIcon
                size={44}
                radius="md"
                variant="light"
                color={tool.color}
              >
                <Icon size={24} />
              </ThemeIcon>
              <Box>
                <Title order={2}>{t(`tools.${tool.id}.title`)}</Title>
                <Text size="sm" c="dimmed">
                  {t(`tools.${tool.id}.description`)}
                </Text>
              </Box>
            </Group>

            <Button
              size="md"
              radius="md"
              color={tool.color}
              leftSection={<Play size={18} />}
              onClick={onAction}
              disabled={!isValid}
            >
              {actionLabel}
            </Button>
          </Group>

          <Divider />

          <Stack gap="lg">{children}</Stack>
        </Stack>
      </Container>
    </ScrollArea>
  );
}
