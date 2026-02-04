import { useDocumentsStore } from '@/app/store/documents.store';
import { JSX } from 'react';
import { ScreenProps } from '../props';
import { PdfView } from './components/PdfView';

export function ReaderPlaceholder(): JSX.Element {
  return(
    <div></div>
  );
}

export function ReaderScreen({ visible }: ScreenProps): JSX.Element {  
  const documents = useDocumentsStore(
    state => state.documents
  );

  if (Object.keys(documents).length === 0) {
    return (
      <div
        style={{
          width: '100%',
          height: 'calc(100vh - var(--app-shell-header-height, 92px))',
          background: '#f0f0f0',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        No document opened.
      </div>
    );
  }

  return (
    <div 
      style={{ 
        display: visible ? 'block' : 'none',
        backgroundColor: '#f0f0f0',
        position: 'relative',
        height: 'calc(100vh - var(--app-shell-header-height, 92px))',
        overflow: 'hidden',
      }}
    >
      {Object.values(documents).map((doc) => (
        <PdfView key={doc.id} id={doc.id} />
      ))}
    </div>
  );
}


