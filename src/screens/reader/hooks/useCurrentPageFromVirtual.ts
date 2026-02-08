import { useEffect } from "react";
import { Virtualizer } from "@tanstack/react-virtual";
import { usePdfViewerStore } from "../stores";

export function useCurrentPageFromVirtual<
  TScroll extends Element,
  TItem extends Element
>({
  virtualizer,
  id,
}: {
  virtualizer: Virtualizer<TScroll, TItem>;
  id: string;
}) {
  const setCurrentPage = usePdfViewerStore((s) => s.setCurrentPage);

  useEffect(() => {
  const scrollTop = virtualizer.scrollOffset;
  const items = virtualizer.getVirtualItems();

  if (!items.length) return;

  let current = items[0].index;

  for (const item of items) {
    if (scrollTop !== null && item.start <= scrollTop + 1) {
      current = item.index;
    } else {
      break;
    }
  }

  setCurrentPage(id, current);
}, [virtualizer.scrollOffset]);
}