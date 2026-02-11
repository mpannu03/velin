import { documentRepository } from "@/shared/storage";
import { DocumentMeta } from "@/shared/types";
import { create } from "zustand";

interface DocumentRepositoryState {
  documents: DocumentMeta[];
  init(): Promise<void>;
  getRecents(): DocumentMeta[];
  getLastOpened(): DocumentMeta | undefined;
  getStarred(): DocumentMeta[];
  getDocumentByFilePath(filePath: string): DocumentMeta | undefined;
  addDocument(doc: DocumentMeta): Promise<void>;
  updateDocument(doc: DocumentMeta): Promise<void>;
  deleteDocument(filePath: string): Promise<void>;
}

export const useDocumentRepositoryStore = create<DocumentRepositoryState>((set, get) => ({
  documents: [],

  async init() {
    await documentRepository.init();
    set({ documents: documentRepository.getAll() });
  },

  getRecents() {
    return get().documents.sort(
      (a, b) => b.lastOpened - a.lastOpened
    );
  },

  getLastOpened() {
    const sorted = get().documents.sort(
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

  async updateDocument(doc: DocumentMeta) {
    await documentRepository.update(doc);
    set({ documents: documentRepository.getAll() });
  },

  async deleteDocument(filePath: string) {
    await documentRepository.delete(filePath);
    set({ documents: documentRepository.getAll() });
  },
}));