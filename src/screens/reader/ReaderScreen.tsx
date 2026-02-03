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
      <div style={{ 
        display: visible ? 'block' : 'none',
      }}>No document opened.</div>
    );
  }

  return (
    <div 
      style={{ 
        display: visible ? 'block' : 'none',
        backgroundColor: '#f0f0f0',
        position: 'relative',
        height: '100vh',
        overflow: 'hidden',
      }}
    >
      {Object.values(documents).map((doc) => (
        <PdfView id={doc.id} />
      ))}
    </div>
  );
}


