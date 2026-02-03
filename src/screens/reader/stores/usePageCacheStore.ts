import { create } from 'zustand';
import { RenderedPage } from '../types';

type PageCacheState = {
    pages: Map<string, RenderedPage>;
    addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
    getPage: (id: string, pageIndex: number, width: number) => RenderedPage | undefined;
    getAnyPage: (id: string, pageIndex: number) => RenderedPage | undefined;
    purgeDocument: (id: string) => void;
    clear: () => void;
};

const MAX_CACHE_SIZE = 2000;

export const usePageCacheStore = create<PageCacheState>((set, get) => ({
    pages: new Map(),

    addPage: (id, pageIndex, page) => {
        const key = `${id}:${pageIndex}:${page.width}x${page.height}`;
        set((state) => {
            const newPages = new Map(state.pages);

            if (newPages.has(key)) {
                newPages.delete(key);
            }

            newPages.set(key, page);

            if (newPages.size > MAX_CACHE_SIZE) {
                // Tab-Aware Eviction: Prefer evicting pages NOT from the active document
                // This requires importing or passing activeDocumentId. 
                // We'll peek into documents store directly for the best UX.
                let keyToEvict: string | undefined;
                
                // 1. Try to find a page from a background tab
                for (const k of newPages.keys()) {
                    if (!k.startsWith(`${id}:`)) {
                        keyToEvict = k;
                        break;
                    }
                }

                // 2. Fallback to oldest page (LRU) if all are from active tab
                if (!keyToEvict) {
                    keyToEvict = newPages.keys().next().value;
                }

                if (keyToEvict) {
                    newPages.delete(keyToEvict);
                }
            }

            return { pages: newPages };
        });
    },

    getPage: (id, pageIndex, width) => {
        const keyPrefix = `${id}:${pageIndex}:${width}x`;
        return [...get().pages.entries()].find(([k]) => k.startsWith(keyPrefix))?.[1];
    },

    getAnyPage: (id, pageIndex) => {
        const keyPrefix = `${id}:${pageIndex}:`;
        const matches = [...get().pages.entries()]
            .filter(([k]) => k.startsWith(keyPrefix))
            .map(([_, v]) => v);
        
        if (matches.length === 0) return undefined;
        return matches.sort((a, b) => b.width - a.width)[0];
    },

    purgeDocument: (id) => set((state) => {
        const newPages = new Map(state.pages);
        const prefix = `${id}:`;
        for (const key of newPages.keys()) {
            if (key.startsWith(prefix)) {
                newPages.delete(key);
            }
        }
        return { pages: newPages };
    }),

    clear: () => set({ pages: new Map() }),
}));
