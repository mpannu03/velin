import { create } from 'zustand';
import { PdfInfo } from '@/shared/types';
import { fetchPdfInfo } from '@/shared/tauri';

type PdfInfoCacheState = {
    infoCache: Record<string, PdfInfo>;
    errorCache: Record<string, string | null>;
    isLoading: Record<string, boolean>;

    fetchInfo: (id: string) => Promise<void>;
    getInfo: (id: string) => PdfInfo | undefined;
};

export const usePdfInfoStore = create<PdfInfoCacheState>((set, get) => ({
    infoCache: {},
    errorCache: {},
    isLoading: {},

    fetchInfo: async (id: string) => {
        // Return if already cached or currently loading
        if (get().infoCache[id] || get().isLoading[id]) return;

        set((state) => ({
            isLoading: { ...state.isLoading, [id]: true },
            errorCache: { ...state.errorCache, [id]: null } // Clear previous error
        }));

        const result = await fetchPdfInfo(id);

        set((state) => {
            const isLoading = { ...state.isLoading };
            delete isLoading[id];

            if (result.ok) {
                return {
                    isLoading,
                    infoCache: { ...state.infoCache, [id]: result.data },
                    errorCache: { ...state.errorCache }
                };
            } else {
                return {
                    isLoading,
                    infoCache: { ...state.infoCache },
                    errorCache: { ...state.errorCache, [id]: result.error }
                };
            }
        });
    },

    getInfo: (id: string) => get().infoCache[id],
}));
