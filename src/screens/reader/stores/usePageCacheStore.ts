import { create } from 'zustand';
import { RenderedPage } from '../types';

type PageCacheState = {
    pages: Map<string, RenderedPage>;
    addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
    getPage: (id: string, pageIndex: number, width: number) => RenderedPage | undefined;
    clear: () => void;
};

const MAX_CACHE_SIZE = 500;

export const usePageCacheStore = create<PageCacheState>((set, get) => ({
    pages: new Map(),

    addPage: (id, pageIndex, page) => {
        const key = `${id}:${pageIndex}:${page.width}x${page.height}`;
        set((state) => {
            const newPages = new Map(state.pages);

            // If exists, delete to re-insert at end (refresh LRU position)
            if (newPages.has(key)) {
                newPages.delete(key);
            }

            newPages.set(key, page);

            // Evict oldest if limit exceeded
            if (newPages.size > MAX_CACHE_SIZE) {
                // Map iterator yields in insertion order, so first item is oldest
                const oldestKey = newPages.keys().next().value;
                if (oldestKey) {
                    newPages.delete(oldestKey);
                }
            }

            return { pages: newPages };
        });
    },

    getPage: (id, pageIndex, width) => {
        // Find if we have this page at this specific width
        // Target height is estimated, but width is the key for PDF rendering
        const keyPrefix = `${id}:${pageIndex}:${width}x`;
        return [...get().pages.entries()].find(([k]) => k.startsWith(keyPrefix))?.[1];
    },

    clear: () => set({ pages: new Map() }),
}));
