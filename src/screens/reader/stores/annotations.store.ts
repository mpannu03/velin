import { create } from 'zustand';
import { invoke } from '@tauri-apps/api/core';
import { Annotation } from '../types';
import { fetchAnnotations } from '@/services/tauri';

interface AnnotationsState {
  annotations: Record<string, Annotation[]>; // key: documentId
  loading: boolean;
  error: string | null;

  fetchAnnotations: (documentId: string) => Promise<void>;
  addAnnotation: (documentId: string, annotation: Annotation) => Promise<void>;
  removeAnnotation: (documentId: string, pageIndex: number, annotationId: string) => Promise<void>;
}

export const useAnnotationsStore = create<AnnotationsState>((set, get) => ({
  annotations: {},
  loading: false,
  error: null,

  fetchAnnotations: async (documentId: string) => {
    const { annotations, loading } = get();
    if (loading || annotations[documentId]) return;

    set({ loading: true, error: null });
    const result = await fetchAnnotations(documentId);
    if (result.ok) {
      set((state) => ({
        annotations: { ...state.annotations, [documentId]: result.data },
        loading: false,
      }));
    } else {
      set({ loading: false, error: result.error });
    }
  },

  addAnnotation: async (documentId: string, annotation: Annotation) => {
    try {
      await invoke('add_annotation', { id: documentId, annotation });
      // clear cache or refetch
      get().fetchAnnotations(documentId);
    } catch (e: any) {
      console.error("Failed to add annotation", e);
      throw e;
    }
  },

  removeAnnotation: async (documentId: string, pageIndex: number, annotationId: string) => {
    try {
      await invoke('remove_annotation', { id: documentId, pageIndex, annotationId });
      // refetch
      get().fetchAnnotations(documentId);
    } catch (e: any) {
        console.error("Failed to remove annotation", e);
        throw e;
    }
  },
}));
