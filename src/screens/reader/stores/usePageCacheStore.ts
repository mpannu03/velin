import { create } from 'zustand';
import { RenderedPage } from '../types';

type PageCacheState = {
    pages: Map<string, RenderedPage>;
    addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
    getPage: (id: string, pageIndex: number, width: number) => RenderedPage | undefined;
    getAnyPage: (id: string, pageIndex: number) => RenderedPage | undefined;
    clear: () => void;
};

const MAX_CACHE_SIZE = 500;

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
                const oldestKey = newPages.keys().next().value;
                if (oldestKey) {
                    newPages.delete(oldestKey);
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

    clear: () => set({ pages: new Map() }),
}));
