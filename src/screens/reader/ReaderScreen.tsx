import { ScrollArea, Center, Text } from '@mantine/core';
import { useReaderStore } from './store';
import { useDocumentsStore } from '@/app/store/documents.store';
import { useActivePdfInfo } from './hooks';
import { PdfDocumentView } from './components';

export function ReaderScreen() {
  useActivePdfInfo();

  const activeDocumentId = useDocumentsStore(
    state => state.activeDocumentId
  );

  const info = useReaderStore(
    state => activeDocumentId
      ? state.pdfInfo[activeDocumentId]
      : null
  );

  if (!activeDocumentId) {
    return (
      <Center h="100%">
        <Text>No document open</Text>
      </Center>
    );
  }

  if (!info) {
    return (
      <Center h="100%">
        <Text>Loading document info…</Text>
      </Center>
    );
  }

  return (
    <ScrollArea type="auto" h="100%" bg="gray.1">
      <PdfDocumentView docId={activeDocumentId} pageCount={info.page_count} />
    </ScrollArea>
  );
}
