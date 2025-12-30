import { JSX } from "react";
import { PdfPage } from './PdfPage';
import { useDocumentsStore } from "@/app";
import { usePdfInfo } from "../hooks/usePdfInfo";

type PdfViewProps = {
  id: string;
};

export function PdfView({ id }: PdfViewProps): JSX.Element {
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const info = usePdfInfo(id);

  if (!info) {
    return <div>Loading PDF info...</div>;
  }

  return(
    <div
      style={{
        height: "100vh",
        overflow: "auto",
        padding: "16px 16px 92px 16px",
        display: activeDocumentId === id ? 'block' : 'none',
      }}
    >
      {
        info.page_count > 0 && Array.from({ length: info.page_count }).map((_, index) => (
          <PdfPage key={index} id={id} pageIndex={index} />
        ))
      }
    </div>
  );
};