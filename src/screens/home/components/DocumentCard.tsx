import { Card, Text, Group, Badge, Stack, ActionIcon, Box, Progress } from '@mantine/core';
import { DocumentMeta } from '@/shared/types';
import { FiStar, FiFile, FiClock, FiTrash } from 'react-icons/fi';
import { JSX, useMemo } from 'react';
import { convertFileSrc } from '@tauri-apps/api/core';

interface DocumentCardProps {
  document: DocumentMeta;
  onClick: () => void;
  onDelete?: () => void;
  onToggleStar?: () => void;
}

export function DocumentCard({ document, onClick, onDelete, onToggleStar }: DocumentCardProps): JSX.Element {
  const previewUrl = useMemo(() => {
    if (!document.previewPath) return undefined;
    return convertFileSrc(document.previewPath);
  }, [document.previewPath]);

  const formattedDate = new Date(document.lastOpened).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });

  const progress = document.pagesCount > 0 
    ? ((document.currentPage + 1) / document.pagesCount) * 100 
    : 0;

  return (
    <Card 
      shadow="sm" 
      padding="md" 
      radius="md" 
      withBorder 
      style={{ cursor: 'pointer', transition: 'transform 0.2s ease' }}
      onMouseEnter={(e) => (e.currentTarget.style.transform = 'translateY(-4px)')}
      onMouseLeave={(e) => (e.currentTarget.style.transform = 'translateY(0)')}
      onClick={onClick}
    >
      <Card.Section>
        <Box 
          h={160} 
          bg="var(--mantine-color-gray-1)" 
          style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          {previewUrl ? (
            <img
              src={previewUrl}
              alt={document.title}
              style={{
                maxHeight: '100%',
                maxWidth: '100%',
                objectFit: 'contain',
              }}
              loading="lazy"
            />
          ) : (
            <FiFile size={48} stroke="var(--mantine-color-gray-4)" />
          )}
        </Box>
      </Card.Section>

      <Stack gap="xs" mt="md">
        <Group justify="space-between" wrap="nowrap">
          <Text fw={600} size="sm" truncate="end" style={{ flex: 1 }}>
            {document.title}
          </Text>
          <Group gap={0}>
            <ActionIcon 
              variant="subtle" 
              color={document.starred ? "yellow" : "gray"} 
              onClick={(e) => {
                e.stopPropagation();
                onToggleStar?.();
              }}
            >
              <FiStar size={16} style={{ fill: document.starred ? 'currentColor' : 'none' }} />
            </ActionIcon>
            <ActionIcon 
              variant="subtle" 
              color="gray" 
              onClick={(e) => {
                e.stopPropagation();
                onDelete?.();
              }}
              onMouseEnter={(e) => (e.currentTarget.style.color = 'var(--mantine-color-red-6)')}
              onMouseLeave={(e) => (e.currentTarget.style.color = 'var(--mantine-color-gray-6)')}
            >
              <FiTrash size={16} />
            </ActionIcon>
          </Group>
        </Group>

        <Stack gap={4} mt={2}>
          <Group justify="space-between">
            <Text size="xs" c="dimmed" fw={500}>Progress</Text>
            <Text size="xs" c="dimmed">{Math.round(progress)}%</Text>
          </Group>
          <Progress value={progress} size="xs" radius="xl" />
        </Stack>

        <Group gap={4} wrap="nowrap">
          <FiClock size={12} color="var(--mantine-color-gray-6)" />
          <Text size="xs" c="dimmed">
            {formattedDate}
          </Text>
          <Badge variant="light" size="xs" ml="auto">
            {document.currentPage + 1} / {document.pagesCount} pages
          </Badge>
        </Group>
      </Stack>
    </Card>
  );
}
