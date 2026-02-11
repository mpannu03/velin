import { Card, Text, Group, Badge, Stack, ActionIcon, Menu, Box } from '@mantine/core';
import { DocumentMeta } from '@/shared/types';
import { FiMoreVertical, FiStar, FiFile, FiClock, FiTrash } from 'react-icons/fi';
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

  console.log(previewUrl);
  console.log(document.previewPath);

  const formattedDate = new Date(document.lastOpened).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });

  return (
    <Card 
      w="256px"
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
          <Menu shadow="md" width={160} position="bottom-end">
            <Menu.Target>
              <ActionIcon variant="subtle" color="gray" onClick={(e) => e.stopPropagation()}>
                <FiMoreVertical size={16} />
              </ActionIcon>
            </Menu.Target>
            <Menu.Dropdown onClick={(e) => e.stopPropagation()}>
              <Menu.Item leftSection={<FiStar size={14} />} onClick={onToggleStar}>
                {document.starred ? 'Unstar' : 'Star'}
              </Menu.Item>
              <Menu.Item color="red" leftSection={<FiTrash size={14} />} onClick={onDelete}>
                Remove
              </Menu.Item>
            </Menu.Dropdown>
          </Menu>
        </Group>

        <Group gap={4} wrap="nowrap">
          <FiClock size={12} color="var(--mantine-color-gray-6)" />
          <Text size="xs" color="dimmed">
            {formattedDate}
          </Text>
          <Badge variant="light" size="xs" ml="auto">
            {document.pagesCount} pages
          </Badge>
        </Group>
      </Stack>

      {document.starred && (
        <FiStar 
          style={{ position: 'absolute', top: 10, left: 10, fill: 'var(--mantine-color-yellow-5)', color: 'var(--mantine-color-yellow-5)' }} 
          size={16} 
        />
      )}
    </Card>
  );
}

