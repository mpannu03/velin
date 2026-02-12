import { Modal, Stack, Text, Button, Progress, Group, Title } from '@mantine/core';
import { useState } from 'react';
import { downloadAndInstallWordNet } from '../services/dictionary';
import { notifications } from '@mantine/notifications';

interface DictionaryDownloadPromptProps {
  opened: boolean;
  onClose: () => void;
  onComplete: () => void;
}

export function DictionaryDownloadPrompt({ opened, onClose, onComplete }: DictionaryDownloadPromptProps) {
  const [downloading, setDownloading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [stage, setStage] = useState<'idle' | 'downloading' | 'extracting'>('idle');

  const handleDownload = async () => {
    setDownloading(true);
    setStage('downloading');
    try {
      await downloadAndInstallWordNet((status) => {
        if (status.stage === 'downloading') {
          setProgress(status.percent);
        } else if (status.stage === 'extracting') {
          setStage('extracting');
        }
      });
      notifications.show({
        title: 'Success',
        message: 'Dictionary downloaded and installed successfully',
        color: 'green',
      });
      onComplete();
      onClose();
    } catch (error) {
      console.error(error);
      notifications.show({
        title: 'Error',
        message: 'Failed to download dictionary',
        color: 'red',
      });
      setDownloading(false);
      setStage('idle');
    }
  };

  return (
    <Modal
      opened={opened}
      onClose={onClose}
      title={<Title order={4}>Additional Data Required</Title>}
      centered
      closeOnClickOutside={!downloading}
      closeOnEscape={!downloading}
      withCloseButton={!downloading}
    >
      <Stack>
        <Text size="sm">
          To use the dictionary feature offline, we need to download additional data (approx. 10MB).
          Would you like to download it now?
        </Text>

        {downloading && (
          <Stack gap="xs">
             <Group justify="space-between">
                <Text size="xs" c="dimmed">
                  {stage === 'downloading' ? 'Downloading...' : 'Extracting...'}
                </Text>
                {stage === 'downloading' && <Text size="xs" c="dimmed">{progress}%</Text>}
             </Group>
            <Progress value={stage === 'extracting' ? 100 : progress} animated={stage === 'extracting'} />
          </Stack>
        )}

        <Group justify="flex-end" mt="md">
          {!downloading && (
            <Button variant="subtle" onClick={onClose} color="gray">
              Later
            </Button>
          )}
          <Button onClick={handleDownload} loading={downloading} disabled={downloading && stage === 'extracting'}>
            Download Now
          </Button>
        </Group>
      </Stack>
    </Modal>
  );
}
