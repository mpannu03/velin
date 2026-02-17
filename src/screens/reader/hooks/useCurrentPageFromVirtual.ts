import { useEffect, useRef } from "react";
import { Virtualizer } from "@tanstack/react-virtual";
import { usePdfViewerStore } from "../stores";
import { useDocumentRepositoryStore, useDocumentsStore } from "@/app";

type UseCurrentPageFromVirtualParams = {
  virtualizer: Virtualizer<HTMLDivElement, Element>;
  id: string;
};

export function useCurrentPageFromVirtual({
  virtualizer,
  id,
}: UseCurrentPageFromVirtualParams) {
  const setCurrentPage = usePdfViewerStore((s) => s.setCurrentPage);
  const updateDocument = useDocumentRepositoryStore((s) => s.updateDocument);
  const filePath = useDocumentsStore((s) => s.documents[id]?.filePath);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    const handleScroll = () => {
      // Cancel previous RAF if it exists
      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
      }

      // Schedule update for next animation frame
      rafRef.current = requestAnimationFrame(() => {
        const items = virtualizer.getVirtualItems();
        if (items.length > 0) {
          const currentPage = items[0].index;
          setCurrentPage(id, currentPage);
          if (filePath) {
            updateDocument(filePath, { currentPage });
          }
        }
        rafRef.current = null;
      });
    };

    const element = virtualizer.scrollElement;
    if (element) {
      element.addEventListener("scroll", handleScroll, { passive: true });
      return () => {
        element.removeEventListener("scroll", handleScroll);
        // Cleanup pending RAF on unmount
        if (rafRef.current !== null) {
          cancelAnimationFrame(rafRef.current);
        }
      };
    }
  }, [virtualizer, id, setCurrentPage, updateDocument, filePath]);
}