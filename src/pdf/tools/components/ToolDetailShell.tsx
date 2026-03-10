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
import { FiArrowLeft, FiPlay } from "react-icons/fi";
import { ToolInfo } from "@/pdf/tools";

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
                <FiArrowLeft size={20} />
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
                <Title order={2}>{tool.title}</Title>
                <Text size="sm" c="dimmed">
                  {tool.description}
                </Text>
              </Box>
            </Group>

            <Button
              size="md"
              radius="md"
              color={tool.color}
              leftSection={<FiPlay size={18} />}
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
