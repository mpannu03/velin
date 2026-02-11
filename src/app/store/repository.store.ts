import { deletePreview } from "@/shared/services/previewPng";
import { documentRepository } from "@/shared/storage";
import { DocumentMeta, DocumentPatch } from "@/shared/types";
import { create } from "zustand";

interface DocumentRepositoryState {
  documents: DocumentMeta[];
  init(): Promise<void>;
  getRecents(): DocumentMeta[];
  getLastOpened(): DocumentMeta | undefined;
  getStarred(): DocumentMeta[];
  getDocumentByFilePath(filePath: string): DocumentMeta | undefined;
  addDocument(doc: DocumentMeta): Promise<void>;
  updateDocument(filePath: string, patch: Omit<DocumentPatch, 'filePath'>): Promise<void>;
  deleteDocument(filePath: string): Promise<void>;
}

export const useDocumentRepositoryStore = create<DocumentRepositoryState>((set, get) => ({
  documents: [],

  async init() {
    await documentRepository.init();
    set({ documents: documentRepository.getAll() });
  },

  getRecents() {
    return [...get().documents].sort(
      (a, b) => b.lastOpened - a.lastOpened
    );
  },

  getLastOpened() {
    const sorted = [...get().documents].sort(
      (a, b) => b.lastOpened - a.lastOpened
    );
    return sorted.length > 0 ? sorted[0] : undefined;
  },

  getStarred() {
    return get().documents.filter((doc) => doc.starred);
  },

  getDocumentByFilePath(filePath: string) {
    return get().documents.find((doc) => doc.filePath === filePath);
  },

  async addDocument(doc: DocumentMeta) {
    await documentRepository.add(doc);
    set({ documents: documentRepository.getAll() });
  },

  async updateDocument(filePath: string, patch: Omit<DocumentPatch, 'filePath'>) {
    await documentRepository.update({ ...patch, filePath });
    set({ documents: documentRepository.getAll() });
  },

  async deleteDocument(filePath: string) {
    const doc = get().documents.find((doc) => doc.filePath === filePath);
    if (!doc) {
      return;
    }
    await documentRepository.delete(filePath);
    await deletePreview(doc);
    set({ documents: documentRepository.getAll() });
  },
}));