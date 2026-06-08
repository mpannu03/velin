import { describe, it, expect, vi, beforeEach } from 'vitest'
import { savePreview, deletePreview } from './previewPng'
import { appCacheDir, join } from '@tauri-apps/api/path'
import { generatePreview } from '@/services/tauri'
import { remove } from '@tauri-apps/plugin-fs'
import { PdfDocument, DocumentMeta } from '@/shared/types'

// Mock dependencies
vi.mock('@tauri-apps/api/path')
vi.mock('@/services/tauri')
vi.mock('@tauri-apps/plugin-fs')

describe('previewPng service', () => {
  const mockCacheDir = '/mock/cache'
  
  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(appCacheDir).mockResolvedValue(mockCacheDir)
    vi.mocked(join).mockImplementation(async (...args) => args.join('/'))
  })

  describe('savePreview', () => {
    const mockDoc: PdfDocument = {
      id: 'test-id',
      title: 'test.pdf',
      filePath: '/path/test.pdf'
    }

    it('should generate and return the preview path on success', async () => {
      vi.mocked(generatePreview).mockResolvedValue({ ok: true, data: new Uint8Array([1, 2, 3]) })
      
      const result = await savePreview(mockDoc)
      
      expect(result).toBe('/mock/cache/previews/test-id.webp')
      expect(generatePreview).toHaveBeenCalledWith('test-id')
      expect(appCacheDir).toHaveBeenCalled()
    })

    it('should throw and log an error when generation fails', async () => {
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      vi.mocked(generatePreview).mockResolvedValue({ ok: false, error: 'Preview failed' })
      
      await expect(savePreview(mockDoc)).rejects.toThrow('Preview failed')
      expect(consoleSpy).toHaveBeenCalledWith('Preview failed')
      
      consoleSpy.mockRestore()
    })
  })

  describe('deletePreview', () => {
    it('should do nothing if document has no previewPath', async () => {
      const mockDoc: DocumentMeta = {
        title: 'test.pdf',
        filePath: '/path/test.pdf',
        previewPath: undefined,
        starred: false,
        lastOpened: 0,
        currentPage: 0,
        pagesCount: 0,
        openedCount: 0
      }
      
      await deletePreview(mockDoc)
      expect(remove).not.toHaveBeenCalled()
    })

    it('should call remove when previewPath exists', async () => {
      const mockDoc: DocumentMeta = {
        title: 'test.pdf',
        filePath: '/path/test.pdf',
        previewPath: '/mock/cache/previews/1.webp',
        starred: false,
        lastOpened: 0,
        currentPage: 0,
        pagesCount: 0,
        openedCount: 0
      }
      
      await deletePreview(mockDoc)
      expect(remove).toHaveBeenCalledWith('/mock/cache/previews/1.webp', expect.anything())
    })

    it('should catch and log errors during removal', async () => {
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      vi.mocked(remove).mockRejectedValue(new Error('FS error'))
      
      const mockDoc = { previewPath: '/path' } as DocumentMeta
      
      await deletePreview(mockDoc)
      expect(consoleSpy).toHaveBeenCalled()
      
      consoleSpy.mockRestore()
    })
  })
})
