import { useDocumentsStore } from "@/app/store/documents.store";
import { JSX } from "react";
import { PdfView } from "@/pdf/reader/PdfView";
import { useScreenState } from "@/app/screenRouter";
import { NoDocumentOpened } from "./components";

export function ReaderScreen(): JSX.Element {
  const documents = useDocumentsStore((state) => state.documents);
  const screen = useScreenState((s) => s.screen);
  const activeDocumentId = useDocumentsStore((state) => state.activeDocumentId);

  if (Object.keys(documents).length === 0 && screen.name === "reader") {
    return <NoDocumentOpened />;
  }

  return (
    <div
      style={{
        height: "100%",
        flexDirection: "column",
        background:
          "light-dark(var(--mantine-color-gray-0), var(--mantine-color-dark-6))",
        position: "relative",
        flex: 1,
        overflow: "hidden",
      }}
    >
      {Object.values(documents).map(
        (doc): JSX.Element => (
          <PdfView key={doc.id} doc={doc} activeDocumentId={activeDocumentId} />
        ),
      )}
    </div>
  );
}
