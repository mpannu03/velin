import { ScrollArea, Center, Text } from '@mantine/core';
import { useReaderStore } from './store';
import { useDocumentsStore } from '@/app/store/documents.store';
import { useActivePdfInfo } from './hooks';
import { PdfDocumentView } from './components';
import { JSX } from 'react';
import { ScreenProps } from '../props';

export function ReaderPlaceholder(): JSX.Element {
  return(
    <div></div>
  );
}

export function ReaderScreen({ visible }: ScreenProps): JSX.Element {
  // Tanstack virtualiser for large list
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
      <Center h="100%" style={{ display: visible ? 'block' : 'none' }}>
        <Text>No document open</Text>
      </Center>
    );
  }

  if (!info) {
    return (
      <Center h="100%" style={{ display: visible ? 'block' : 'none' }}>
        <Text>Loading document info…</Text>
      </Center>
    );
  }

  return (
    <ScrollArea type="auto" h="100%" bg="gray.1" style={{ display: visible ? 'block' : 'none' }}>
      <PdfDocumentView docId={activeDocumentId} pageCount={info.page_count} />
    </ScrollArea>
  );
}


