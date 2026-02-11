import { documentRepository } from "@/shared/storage";
import { DocumentMeta } from "@/shared/types";
import { create } from "zustand";

interface DocumentRepositoryState {
  documents: DocumentMeta[];
  init(): void;
  getRecents(): DocumentMeta[];
  getStarred(): DocumentMeta[];
  getDocumentById(id: string): DocumentMeta | undefined;
  addDocument(doc: DocumentMeta): void;
  updateDocument(doc: DocumentMeta): void;
  deleteDocument(id: string): void;
}

export const useDocumentRepositoryStore = create<DocumentRepositoryState>((set, get) => ({
  documents: [],

  init() {
    set({ documents: documentRepository.getAll() });
  },

  getRecents() {
    return get().documents.sort(
      (a, b) => b.lastOpened.getTime() - a.lastOpened.getTime()
    );
  },

  getStarred() {
    return get().documents.filter((doc) => doc.starred);
  },

  getDocumentById(id: string) {
    return get().documents.find((doc) => doc.id === id);
  },

  async addDocument(doc: DocumentMeta) {
    await documentRepository.add(doc);
    set({ documents: documentRepository.getAll() });
  },

  async updateDocument(doc: DocumentMeta) {
    await documentRepository.update(doc);
    set({ documents: documentRepository.getAll() });
  },

  async deleteDocument(id: string) {
    await documentRepository.delete(id);
    set({ documents: documentRepository.getAll() });
  },
}));