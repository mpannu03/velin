import { describe, it, expect, vi, beforeEach } from 'vitest'
import { documentRepository } from './documentRepository'
import { documentStore } from './store'
import { DocumentMeta } from '@/shared/types'

// Mock the store
vi.mock('./store', () => ({
  documentStore: {
    get: vi.fn(),
    set: vi.fn(),
    save: vi.fn(),
  }
}))

describe('DocumentRepository', () => {
  const mockDoc: DocumentMeta = {
    filePath: '/path/test.pdf',
    title: 'test.pdf',
    previewPath: '/preview/test.webp',
    starred: false,
    lastOpened: 1700000000000,
    currentPage: 0,
    pagesCount: 10,
    openedCount: 1
  }

  beforeEach(() => {
    vi.clearAllMocks()
    // Reset the internal state by re-initializing or clearing
    // Since it's a singleton, we need to be careful. 
    // We can use a trick to clear private property if needed, but let's try init first.
    ;(documentRepository as any).documents = {}
  })

  describe('init', () => {
    it('should load documents from store', async () => {
      const mockData = {
        [mockDoc.filePath]: mockDoc
      }
      vi.mocked(documentStore.get).mockResolvedValue(mockData)

      await documentRepository.init()

      expect(documentStore.get).toHaveBeenCalledWith('documents')
      expect(documentRepository.getAll()).toHaveLength(1)
      expect(documentRepository.getByFilePath(mockDoc.filePath)).toEqual(mockDoc)
    })

    it('should handle empty store', async () => {
      vi.mocked(documentStore.get).mockResolvedValue(null)

      await documentRepository.init()

      expect(documentRepository.getAll()).toHaveLength(0)
    })
  })

  describe('add', () => {
    it('should add a document and save to store', async () => {
      await documentRepository.add(mockDoc)

      expect(documentRepository.getByFilePath(mockDoc.filePath)).toEqual(mockDoc)
      expect(documentStore.set).toHaveBeenCalledWith('documents', expect.objectContaining({
        [mockDoc.filePath]: mockDoc
      }))
      expect(documentStore.save).toHaveBeenCalled()
    })
  })

  describe('update', () => {
    it('should update an existing document', async () => {
      await documentRepository.add(mockDoc)
      
      const patch = { filePath: mockDoc.filePath, starred: true }
      await documentRepository.update(patch)

      const updated = documentRepository.getByFilePath(mockDoc.filePath)
      expect(updated?.starred).toBe(true)
      expect(updated?.title).toBe(mockDoc.title) // Unchanged
    })

    it('should do nothing if document does not exist', async () => {
      const patch = { filePath: 'non-existent', starred: true }
      await documentRepository.update(patch)
      
      expect(documentStore.set).not.toHaveBeenCalledTimes(2) // Only called once if we added something before, here 0
    })
  })

  describe('delete', () => {
    it('should remove document and save', async () => {
      await documentRepository.add(mockDoc)
      expect(documentRepository.getAll()).toHaveLength(1)

      await documentRepository.delete(mockDoc.filePath)
      
      expect(documentRepository.getAll()).toHaveLength(0)
      expect(documentStore.set).toHaveBeenCalledWith('documents', {})
    })
  })
})
