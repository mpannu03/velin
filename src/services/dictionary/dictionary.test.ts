import { describe, it, expect, vi, beforeEach } from 'vitest'
import { isDictionaryInstalled, downloadAndInstallWordNet } from './dictionary'
import { appDataDir, join } from '@tauri-apps/api/path'
import { exists, mkdir, remove, writeFile } from '@tauri-apps/plugin-fs'
import { fetch } from '@tauri-apps/plugin-http'
import { safeInvoke } from '@/services/tauri'

// Mock dependencies
vi.mock('@tauri-apps/api/path')
vi.mock('@tauri-apps/plugin-fs')
vi.mock('@tauri-apps/plugin-http')
vi.mock('@/services/tauri')

describe('dictionary service', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    
    // Default path mocks
    vi.mocked(appDataDir).mockResolvedValue('/app-data')
    vi.mocked(join).mockImplementation(async (...args) => args.join('/'))
  })

  describe('isDictionaryInstalled', () => {
    it('should return true if dict folder exists', async () => {
      vi.mocked(exists).mockResolvedValue(true)
      const result = await isDictionaryInstalled()
      expect(result).toBe(true)
      expect(exists).toHaveBeenCalledWith('/app-data/wordnet/WNdb-3.0/dict')
    })

    it('should return false if dict folder does not exist', async () => {
      vi.mocked(exists).mockResolvedValue(false)
      const result = await isDictionaryInstalled()
      expect(result).toBe(false)
    })
  })

  describe('downloadAndInstallWordNet', () => {
    const mockOnStatus = vi.fn()

    it('should return early if already installed', async () => {
      vi.mocked(exists).mockResolvedValue(true)
      
      await downloadAndInstallWordNet(mockOnStatus)
      
      expect(mockOnStatus).toHaveBeenCalledWith({ stage: 'completed' })
      expect(fetch).not.toHaveBeenCalled()
    })

    it('should download and install successfully', async () => {
      // 1. Not installed initially
      vi.mocked(exists).mockResolvedValueOnce(false) 
      
      // 2. Mock fetch with streaming body
      const mockReader = {
        read: vi.fn()
          .mockResolvedValueOnce({ done: false, value: new Uint8Array([1, 2, 3]) })
          .mockResolvedValueOnce({ done: true }),
      }
      
      const mockResponse = {
        ok: true,
        headers: {
          get: (key: string) => (key === 'content-length' ? '3' : null),
        },
        body: {
          getReader: () => mockReader,
        },
      }
      
      vi.mocked(fetch).mockResolvedValue(mockResponse as any)
      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined })
      
      // 3. Exists check at the end passes
      vi.mocked(exists).mockResolvedValueOnce(true)

      await downloadAndInstallWordNet(mockOnStatus)

      expect(mkdir).toHaveBeenCalled()
      expect(fetch).toHaveBeenCalled()
      expect(writeFile).toHaveBeenCalled()
      expect(safeInvoke).toHaveBeenCalledWith('extract_tar_gz', expect.anything())
      expect(remove).toHaveBeenCalled() // Cleanup tar
      
      // Check status updates
      expect(mockOnStatus).toHaveBeenCalledWith({ stage: 'downloading', percent: 100 })
      expect(mockOnStatus).toHaveBeenCalledWith({ stage: 'extracting' })
      expect(mockOnStatus).toHaveBeenCalledWith({ stage: 'completed' })
    })

    it('should throw if download fails', async () => {
      vi.mocked(exists).mockResolvedValue(false)
      vi.mocked(fetch).mockResolvedValue({ ok: false } as any)

      await expect(downloadAndInstallWordNet()).rejects.toThrow('Failed to download WordNet database')
    })

    it('should throw if extraction fails', async () => {
      vi.mocked(exists).mockResolvedValue(false)
      
      const mockReader = {
        read: vi.fn().mockResolvedValue({ done: true }),
      }
      vi.mocked(fetch).mockResolvedValue({
        ok: true,
        headers: { get: () => '0' },
        body: { getReader: () => mockReader },
      } as any)

      vi.mocked(safeInvoke).mockResolvedValue({ ok: false, error: 'Extract error' })

      await expect(downloadAndInstallWordNet()).rejects.toThrow('Extraction failed: Extract error')
    })

    it('should throw if dict folder missing after extraction', async () => {
      vi.mocked(exists).mockResolvedValueOnce(false) // Initial check
      
      const mockReader = {
        read: vi.fn().mockResolvedValue({ done: true }),
      }
      vi.mocked(fetch).mockResolvedValue({
        ok: true,
        headers: { get: () => '0' },
        body: { getReader: () => mockReader },
      } as any)

      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined })
      vi.mocked(exists).mockResolvedValueOnce(false) // Final check

      await expect(downloadAndInstallWordNet()).rejects.toThrow('WordNet extraction failed: dict folder not found')
    })
  })
})
