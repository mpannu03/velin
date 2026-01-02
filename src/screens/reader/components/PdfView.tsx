import { JSX } from "react";
import { PdfPage } from './PdfPage';
import { useDocumentsStore } from "@/app";
import { usePdfInfo } from "../hooks/usePdfInfo";
import { Loader } from "@mantine/core";

type PdfViewProps = {
  id: string;
};

export function PdfView({ id }: PdfViewProps): JSX.Element {
  const activeDocumentId = useDocumentsStore((s) => s.activeDocumentId);
  const { info, error, loading } = usePdfInfo(id);

  if (loading) {
    return <Loader />
  }

  if (error) {
    return <div>Loading Error: {error}</div>
  }

  if (!info) {
    return <div>Loading PDF info...</div>;
  }

  return(
    <div
      id="pdf-scroll-container"
      style={{
        height: "100vh",
        overflow: "auto",
        padding: "16px 16px 92px 16px",
        display: activeDocumentId === id ? 'block' : 'none',
      }}
    >
      {Array.from({ length: info.page_count }).map((_, index) => (
        <PdfPage key={index} id={id} pageIndex={index} />
      ))}
    </div>
  );
};