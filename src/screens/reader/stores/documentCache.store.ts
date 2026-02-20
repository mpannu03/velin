import { create } from 'zustand';
import { RenderedPage } from '../types';
import { PdfInfo, PageText } from '@/shared/types';
import { fetchPdfInfo, fetchTextByPage } from '@/services/tauri';

const MAX_CACHE_MB = 256;
const MAX_TEXT_CACHE_PAGES = 100;

// Document-level cache containing all related data
type DocumentCache = {
  // Metadata about the PDF
  info?: PdfInfo;
  
  // Rendered pages (keyed by resolution: "width x height")
  pages: Map<string, RenderedPage>;
  
  // Text data (keyed by page number)
  text: Map<number, PageText>;
  
  // Statistics
  lastAccessed: number;
  memoryMb: number;
};

type DocumentCacheState = {
  // Cache per document ID
  documents: Map<string, DocumentCache>;
  
  // Global memory tracking
  totalMemoryMb: number;
  maxMemoryMb: number;
  
  // Page operations
  addPage: (id: string, pageIndex: number, page: RenderedPage) => void;
  getPage: (id: string, pageIndex: number, width: number) => RenderedPage | undefined;
  getAnyPage: (id: string, pageIndex: number) => RenderedPage | undefined;
  
  // Text operations
  addText: (id: string, pageIndex: number, text: PageText) => void;
  getText: (id: string, pageIndex: number) => PageText | undefined;
  fetchText: (id: string, pageIndex: number) => Promise<void>;
  
  // Info operations
  setInfo: (id: string, info: PdfInfo) => void;
  getInfo: (id: string) => PdfInfo | undefined;
  fetchInfo: (id: string) => Promise<void>;
  
  // Cleanup operations
  purgeDocument: (id: string) => void;
  clear: () => void;
};

function estimatePageMB(page: RenderedPage): number {
  if (page.pixels && page.pixels.length > 0) {
    return page.pixels.length / (1024 * 1024);
  }
  // Fallback: assume 8% of raw pixel size (WebP compression)
  return (page.width * page.height * 4 * 0.08) / (1024 * 1024);
}

function estimateTextMB(_text: PageText): number {
  return 0.01; // 10KB
}

function getOrCreateDocCache(documents: Map<string, DocumentCache>, id: string): DocumentCache {
  if (!documents.has(id)) {
    const newCache: DocumentCache = {
      pages: new Map(),
      text: new Map(),
      lastAccessed: Date.now(),
      memoryMb: 0,
    };
    documents.set(id, newCache);
  }
  
  const cache = documents.get(id)!;
  cache.lastAccessed = Date.now();
  return cache;
}

export const useDocumentCacheStore = create<DocumentCacheState>((set, get) => ({
  documents: new Map(),
  totalMemoryMb: 0,
  maxMemoryMb: MAX_CACHE_MB,
  
  addPage: (id, pageIndex, page) => {
    set((state) => {
      const newDocuments = new Map(state.documents);
      const docCache = getOrCreateDocCache(newDocuments, id);
      
      const key = `${pageIndex}:${page.width}x${page.height}`;
      const pageMb = estimatePageMB(page);
      
      const existingPage = docCache.pages.get(key);
      if (existingPage) {
        const oldMb = estimatePageMB(existingPage);
        docCache.memoryMb -= oldMb;
      }

      docCache.pages.set(key, page);
      docCache.memoryMb += pageMb;
      
      let totalMemoryMb = 0;
      for (const cache of newDocuments.values()) {
        totalMemoryMb += cache.memoryMb;
      }
      
      while (totalMemoryMb > MAX_CACHE_MB && newDocuments.size > 0) {
        let oldestId: string | undefined;
        let oldestTime = Infinity;
        
        for (const [docId, cache] of newDocuments) {
          if (cache.lastAccessed < oldestTime) {
            oldestTime = cache.lastAccessed;
            oldestId = docId;
          }
        }
        
        if (oldestId) {
          const removedCache = newDocuments.get(oldestId);
          if (removedCache) {
            totalMemoryMb -= removedCache.memoryMb;
          }
          newDocuments.delete(oldestId);
        } else {
          break;
        }
      }
      
      return { documents: newDocuments, totalMemoryMb };
    });
  },

  getPage: (id, pageIndex, width) => {
    const docCache = get().documents.get(id);
    if (!docCache) return undefined;
    
    docCache.lastAccessed = Date.now();
    
    for (const [key, page] of docCache.pages) {
      if (key.startsWith(`${pageIndex}:`) && Math.abs(page.width - width) < 1) {
        return page;
      }
    }
    
    return undefined;
  },

  getAnyPage: (id, pageIndex) => {
    const docCache = get().documents.get(id);
    if (!docCache || docCache.pages.size === 0) return undefined;

    docCache.lastAccessed = Date.now();
    
    for (const [key, page] of docCache.pages) {
      if (key.startsWith(`${pageIndex}:`)) {
        return page;
      }
    }
    
    return undefined;
  },

  addText: (id, pageIndex, text) => {
    set((state) => {
      const newDocuments = new Map(state.documents);
      const docCache = getOrCreateDocCache(newDocuments, id);
      
      const textMb = estimateTextMB(text);
      
      if (docCache.text.has(pageIndex)) {
        docCache.memoryMb -= estimateTextMB(docCache.text.get(pageIndex)!);
      }
      
      docCache.text.set(pageIndex, text);
      docCache.memoryMb += textMb;
      
      if (docCache.text.size > MAX_TEXT_CACHE_PAGES) {
        const entries = Array.from(docCache.text.entries());
        const [oldestPage, oldestText] = entries[0];
        docCache.text.delete(oldestPage);
        docCache.memoryMb -= estimateTextMB(oldestText);
      }
      
      let totalMemoryMb = 0;
      for (const cache of newDocuments.values()) {
        totalMemoryMb += cache.memoryMb;
      }
      
      return { documents: newDocuments, totalMemoryMb };
    });
  },

  getText: (id, pageIndex) => {
    const docCache = get().documents.get(id);
    if (!docCache) return undefined;
    
    docCache.lastAccessed = Date.now();
    return docCache.text.get(pageIndex);
  },

  fetchText: async (id, pageIndex) => {
    const { getText, addText } = get();
    
    if (getText(id, pageIndex)) return;
    
    try {
      const result = await fetchTextByPage(id, pageIndex);
      
      if (result.ok) {
        addText(id, pageIndex, result.data);
      } else {
        console.error('Failed to fetch text:', result.error);
      }
    } catch (error) {
      console.error('Error fetching text:', error);
    }
  },

  setInfo: (id, info) => {
    set((state) => {
      const newDocuments = new Map(state.documents);
      const docCache = getOrCreateDocCache(newDocuments, id);
      docCache.info = info;
      return { documents: newDocuments };
    });
  },

  getInfo: (id) => {
    const docCache = get().documents.get(id);
    if (!docCache) return undefined;
    
    docCache.lastAccessed = Date.now();
    return docCache.info;
  },

  fetchInfo: async (id) => {
    const { getInfo, setInfo } = get();
    
    if (getInfo(id)) return;
    
    try {
      const result = await fetchPdfInfo(id);
      
      if (result.ok) {
        setInfo(id, result.data);
      } else {
        console.error('Failed to fetch PDF info:', result.error);
      }
    } catch (error) {
      console.error('Error fetching PDF info:', error);
    }
  },
  
  purgeDocument: (id) => {
    set((state) => {
      const newDocuments = new Map(state.documents);
      const docCache = newDocuments.get(id);
      
      if (docCache) {
        const totalMemoryMb = state.totalMemoryMb - docCache.memoryMb;
        newDocuments.delete(id);
        return { documents: newDocuments, totalMemoryMb };
      }
      
      return state;
    });
  },

  clear: () => {
    set({ documents: new Map(), totalMemoryMb: 0 });
  },
}));
