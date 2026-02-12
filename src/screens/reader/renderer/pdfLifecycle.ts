import { pickPdfFile } from "@/shared/services";
import { notifications } from "@mantine/notifications";
import { useDocumentsStore } from "@/app/store/documents.store";
import { usePageCacheStore, usePdfInfoStore, usePdfViewerStore } from "../stores";
import { useScreenState } from "@/app/screenRouter";
import { useDocumentRepositoryStore } from "@/app/store/repository.store";

export async function openPdf() {
  const pdfStore = useDocumentsStore.getState();
  const filePath = await pickPdfFile();
  const router = useScreenState.getState();
  if (!filePath) {
    notifications.show({
      title: "Error",
      message: "Error Opening Pdf",
    });

    return;
  };

  const result = await pdfStore.open(filePath);

  if (!result.ok) {
    notifications.show({
      title: "Error Opening Pdf.",
      message: result.error,
    });
    return;
  }

  router.openReader();
}

export async function openPdfFromPath(filePath: string) {
  const pdfStore = useDocumentsStore.getState();
  const router = useScreenState.getState();
  const result = await pdfStore.open(filePath);
  if (!result.ok) {
    notifications.show({
      title: "Error Opening Pdf.",
      message: result.error,
    });
    return;
  }

  router.openReader();
}

export async function closePdf(id: string) {
  const pdfStore = useDocumentsStore.getState();
  const result = await pdfStore.close(id);
  const viewerState = usePdfViewerStore.getState().getState(id);
  const documentRepositoryStore = useDocumentRepositoryStore.getState();


  if (!result.ok) {
    notifications.show({
      title: "Error Closing Pdf.",
      message: result.error,
    });
  } else {
    if (viewerState) {
      documentRepositoryStore.updateDocument(pdfStore.documents[id].filePath, {
        lastOpened: Date.now(),
        currentPage: viewerState.currentPage,
      });
    }

    usePageCacheStore.getState().purgeDocument(id);
    usePdfInfoStore.getState().removeInfo(id);
    usePdfViewerStore.getState().removeState(id);
  }
}