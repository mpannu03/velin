import { Group, Text, ActionIcon, Box, Paper, Stack, Badge, Progress } from '@mantine/core';
import { DocumentMeta } from '@/shared/types';
import { FiStar, FiFile, FiClock, FiTrash } from 'react-icons/fi';
import { JSX, useMemo } from 'react';
import { convertFileSrc } from '@tauri-apps/api/core';

interface DocumentListItemProps {
  document: DocumentMeta;
  onClick: () => void;
  onDelete?: () => void;
  onToggleStar?: () => void;
}

export function DocumentListItem({ document, onClick, onDelete, onToggleStar }: DocumentListItemProps): JSX.Element {
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
    <Paper
      withBorder
      p="sm"
      radius="md"
      className="document-list-item"
      style={{ cursor: 'pointer', transition: 'background-color 0.2s ease' }}
      onClick={onClick}
      onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--mantine-color-gray-0)')}
      onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
    >
      <Group wrap="nowrap" gap="md">
        <Box
          w={60}
          h={80}
          bg="var(--mantine-color-gray-1)"
          style={{ 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'center',
            borderRadius: '4px',
            overflow: 'hidden',
            flexShrink: 0
          }}
        >
          {previewUrl ? (
            <img
              src={previewUrl}
              alt={document.title}
              style={{
                height: '100%',
                width: '100%',
                objectFit: 'cover',
              }}
              loading="lazy"
            />
          ) : (
            <FiFile size={24} stroke="var(--mantine-color-gray-4)" />
          )}
        </Box>

        <Stack gap={4} style={{ flex: 1 }}>
          <Group justify="space-between" wrap="nowrap">
            <Text fw={600} size="sm" truncate="end">
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

          <Group gap="xs" mt={4} mb={4} w="100%">
            <Text size="xs" c="dimmed" fw={500}>Progress</Text>
            <Progress value={progress} size="xs" radius="xl" style={{flex: 1}}/>
            <Text size="xs" c="dimmed">{Math.round(progress)}%</Text>
          </Group>

          <Group gap="md">
            <Group gap={4} wrap="nowrap">
              <FiClock size={12} color="var(--mantine-color-gray-6)" />
              <Text size="xs" c="dimmed">
                {formattedDate}
              </Text>
            </Group>
            <Badge variant="light" size="xs">
              {document.currentPage + 1} / {document.pagesCount} pages
            </Badge>
            <Text size="xs" c="dimmed" truncate="end" style={{ maxWidth: '300px' }}>
              {document.filePath}
            </Text>
          </Group>
        </Stack>
      </Group>
    </Paper>
  );
}
