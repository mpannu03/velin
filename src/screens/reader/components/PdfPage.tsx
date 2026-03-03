import { JSX, memo } from "react";
import { Center, Loader } from "@mantine/core";
import { usePdfAnnotations, usePdfInfo, usePdfText } from "../hooks";
import { TextLayer, SearchHighlightLayer, AnnotationLayer } from "./";
import { SidebarPanel, usePdfViewerStore, useDictionaryStore } from "../stores";
import { TileLayer } from "./TileLayer";

type PdfPageProps = {
  id: string;
  pageIndex: number;
  width: number;
  dpr: number;
  isScrolling: boolean;
  isVisible: boolean;
};

export const PdfPage = memo(
  function PdfPage({
    id,
    pageIndex,
    width,
    dpr,
    isScrolling,
  }: PdfPageProps): JSX.Element {
    const { text: textItems, pageWidth } = usePdfText(id, pageIndex);
    const { info } = usePdfInfo(id);
    const annotations =
      usePdfAnnotations(id).annotations?.filter(
        (a) => a.page_index === pageIndex,
      ) || [];

    const currentToolbar = usePdfViewerStore((s) => s.getState(id).tool);
    const setSidebar = usePdfViewerStore((s) => s.setSidebar);
    const { setQuery, search } = useDictionaryStore();

    const onTextSelected = (selectedText: string) => {
      if (currentToolbar !== "dictionary") return;

      setQuery(id, selectedText);
      search(id, selectedText);
      setSidebar(id, SidebarPanel.Dictionary);
    };

    if (!info) {
      return (
        <Center mb={16}>
          <Loader />
        </Center>
      );
    }

    const displayWidth = width / dpr;

    const pdfWidth = pageWidth ?? info?.width;
    const pdfHeight = info.height;

    const renderWidth = Math.floor(displayWidth * dpr);
    const safePdfWidth = pdfWidth > 0 ? pdfWidth : 1;
    const renderHeight = Math.floor(renderWidth * (pdfHeight / safePdfWidth));

    const displayHeight = renderHeight / dpr;

    const scale = displayWidth / pdfWidth;

    return (
      <div
        style={{
          position: "relative",
          width: `${displayWidth}px`,
          height: `${displayHeight}px`,
          marginBottom: 16,
        }}
      >
        <TileLayer
          id={id}
          pageIndex={pageIndex}
          renderWidth={renderWidth}
          renderHeight={renderHeight}
          dpr={dpr}
          isScrolling={isScrolling}
        />
        {!isScrolling && textItems && info && (
          <TextLayer
            textItems={textItems}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
            onTextSelected={onTextSelected}
          />
        )}
        {!isScrolling && annotations && (
          <AnnotationLayer
            annotations={annotations}
            scale={scale}
            width={displayWidth}
            height={displayHeight}
          />
        )}
        <SearchHighlightLayer pageIndex={pageIndex} scale={scale} id={""} />
      </div>
    );
  },
  (prev, next) =>
    prev.pageIndex === next.pageIndex &&
    prev.width === next.width &&
    prev.dpr === next.dpr &&
    prev.isScrolling === next.isScrolling,
);
