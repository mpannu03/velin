import { useDocumentsStore } from '@/app/store/documents.store';
import { JSX } from 'react';
import { PdfView } from './components/PdfView';
import { useScreenState } from '@/app/screenRouter';

export function ReaderPlaceholder(): JSX.Element {
  return(
    <div></div>
  );
}

export function ReaderScreen(): JSX.Element {  
  const documents = useDocumentsStore(
    state => state.documents
  );
  const screen = useScreenState(s => s.screen);

  if (Object.keys(documents).length === 0 && screen.name === 'reader') {
    return (
      <div
        style={{
          width: '100%',
          flex: 1,
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
        height: "100%",
        flexDirection: 'column',
        backgroundColor: '#f0f0f0',
        position: 'relative',
        flex: 1,
        overflow: 'hidden',
      }}
    >
      {Object.values(documents).map((doc) => (
        <PdfView key={doc.id} id={doc.id} />
      ))}
    </div>
  );
}


