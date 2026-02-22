import { describe, it, expect, vi, beforeEach } from 'vitest'
import { 
  openPdf, 
  renderPage, 
  closePdf, 
  fetchPdfInfo, 
  fetchBookmarks, 
  fetchTextByPage, 
  generatePreview, 
  fetchAnnotations 
} from './reader'
import { safeInvoke } from '@/services/tauri'

// Mock safeInvoke
vi.mock('@/services/tauri', () => ({
  safeInvoke: vi.fn(),
}))

describe('reader tauri service', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('openPdf should call safeInvoke with correct arguments', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: 'doc-id' })
    const result = await openPdf('/path/to.pdf')
    
    expect(safeInvoke).toHaveBeenCalledWith('open_pdf', { path: '/path/to.pdf' })
    expect(result).toEqual({ ok: true, data: 'doc-id' })
  })

  it('closePdf should call safeInvoke with correct arguments', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: undefined })
    await closePdf('doc-id')
    expect(safeInvoke).toHaveBeenCalledWith('close_pdf', { id: 'doc-id' })
  })

  it('fetchPdfInfo should call safeInvoke with correct arguments', async () => {
    const mockInfo = { page_count: 10 }
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: mockInfo })
    const result = await fetchPdfInfo('doc-id')
    expect(safeInvoke).toHaveBeenCalledWith('get_pdf_info', { id: 'doc-id' })
    expect(result).toEqual({ ok: true, data: mockInfo })
  })

  describe('renderPage', () => {
    it('should parse binary data correctly on success', async () => {
      // Create a mock buffer: 4 bytes width (100), 4 bytes height (200), then pixels
      const buffer = new Uint8Array(12)
      const view = new DataView(buffer.buffer)
      view.setUint32(0, 100, false)
      view.setUint32(4, 200, false)
      buffer.set([255, 0, 0, 255], 8) // one red pixel

      vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: buffer })

      const result = await renderPage('doc-id', 0, 1000)

      expect(safeInvoke).toHaveBeenCalledWith('render_page', {
        id: 'doc-id',
        pageIndex: 0,
        targetWidth: 1000
      })

      if (result.ok) {
        expect(result.data.width).toBe(100)
        expect(result.data.height).toBe(200)
        expect(result.data.pixels).toBeInstanceOf(Uint8ClampedArray)
        expect(result.data.pixels[0]).toBe(255)
      } else {
        throw new Error('Should be ok')
      }
    })

    it('should return error if safeInvoke fails', async () => {
      vi.mocked(safeInvoke).mockResolvedValue({ ok: false, error: 'Failed' })
      const result = await renderPage('doc-id', 0, 1000)
      expect(result.ok).toBe(false)
      if (!result.ok) {
        expect(result.error).toBe('Failed')
      }
    })
  })

  it('fetchBookmarks should call safeInvoke', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: [] })
    await fetchBookmarks('doc-id')
    expect(safeInvoke).toHaveBeenCalledWith('get_bookmarks', { id: 'doc-id' })
  })

  it('fetchTextByPage should call safeInvoke', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: { text: '', char_rects: [] } })
    await fetchTextByPage('doc-id', 5)
    expect(safeInvoke).toHaveBeenCalledWith('get_text_by_page', { id: 'doc-id', pageIndex: 5 })
  })

  it('generatePreview should call safeInvoke', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: new Uint8Array() })
    await generatePreview('doc-id')
    expect(safeInvoke).toHaveBeenCalledWith('generate_preview', { id: 'doc-id' })
  })

  it('fetchAnnotations should call safeInvoke', async () => {
    vi.mocked(safeInvoke).mockResolvedValue({ ok: true, data: [] })
    await fetchAnnotations('doc-id')
    expect(safeInvoke).toHaveBeenCalledWith('get_annotations', { id: 'doc-id' })
  })
})
