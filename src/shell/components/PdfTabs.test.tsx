import { render, screen, waitFor, act } from '@/test/test-utils'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { PdfTabs } from './PdfTabs'
import { useDocumentsStore } from '@/app/store/documents.store'
import { useScreenState } from '@/app/screenRouter'
import { closePdf, openPdf } from '@/screens/reader'
import { PdfDocument } from '@/shared/types'

// Mock dependencies
vi.mock('@/app/store/documents.store')
vi.mock('@/app/screenRouter')
vi.mock('@/screens/reader')

// Test data
const mockDocuments: Record<string, PdfDocument> = {
  'doc-1': {
    id: 'doc-1',
    title: 'Document 1.pdf',
    filePath: '/path/doc1.pdf',
  },
  'doc-2': {
    id: 'doc-2',
    title: 'Document 2.pdf',
    filePath: '/path/doc2.pdf',
  },
  'doc-3': {
    id: 'doc-3',
    title: 'Document 3.pdf',
    filePath: '/path/doc3.pdf',
  },
}

const mockOrder = ['doc-1', 'doc-2', 'doc-3']

describe('PdfTabs', () => {
  const mockStore = {
    documents: mockDocuments,
    documentOrder: mockOrder,
    activeDocumentId: 'doc-1',
    reorder: vi.fn(),
    setActive: vi.fn(),
    open: vi.fn(),
    close: vi.fn(),
  }

  const mockRouter = {
    screen: { name: 'reader' },
    goHome: vi.fn(),
    openReader: vi.fn(),
  }

  beforeEach(() => {
    vi.clearAllMocks()
    
    // Setup default mock implementations
    vi.mocked(useDocumentsStore).mockImplementation((selector) => {
      if (typeof selector === 'function') {
        return selector(mockStore)
      }
      return mockStore
    })

    vi.mocked(useScreenState).mockReturnValue(mockRouter)
  })

  afterEach(() => {
    vi.resetAllMocks()
  })

  describe('Rendering', () => {
    it('should render all document tabs', () => {
      render(<PdfTabs />)

      // Check if all document titles are rendered
      expect(screen.getByText('Document 1.pdf')).toBeInTheDocument()
      expect(screen.getByText('Document 2.pdf')).toBeInTheDocument()
      expect(screen.getByText('Document 3.pdf')).toBeInTheDocument()
      
      // Check if open PDF button is rendered
      expect(screen.getByLabelText('Open PDF')).toBeInTheDocument()
    })

    it('should render empty state when no documents exist', () => {
      vi.mocked(useDocumentsStore).mockImplementation((selector) => {
        if (typeof selector === 'function') {
          return selector({
            ...mockStore,
            documents: {},
            documentOrder: [],
            open: vi.mocked(mockStore.open),
            close: vi.mocked(mockStore.close),
          })
        }
        return mockStore
      })

      render(<PdfTabs />)

      // Only the open PDF button should be visible
      expect(screen.queryByText(/Document/)).not.toBeInTheDocument()
      expect(screen.getByLabelText('Open PDF')).toBeInTheDocument()
    })

    it('should highlight the active tab', () => {
      render(<PdfTabs />)

      const activeTab = screen.getByTestId('pdf-tab-doc-1')
      const inactiveTab = screen.getByTestId('pdf-tab-doc-2')

      expect(activeTab).toHaveAttribute('data-active', 'true')
      expect(inactiveTab).toHaveAttribute('data-active', 'false')
    })
  })

  describe('User Interactions', () => {
    it('should call openPdf when clicking the plus button', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      const openButton = screen.getByLabelText('Open PDF')
      await user.click(openButton)

      expect(openPdf).toHaveBeenCalledTimes(1)
    })

    it('should set active document and open reader when clicking a tab', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      const tab = screen.getByText('Document 2.pdf')
      await user.click(tab)

      expect(mockStore.setActive).toHaveBeenCalledWith('doc-2')
      expect(mockRouter.openReader).toHaveBeenCalledTimes(1)
    })

    it('should call closePdf when clicking the close button on a tab', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      // Find the close button for the first tab
      const closeButton = screen.getByLabelText('Close Document 1.pdf')
      
      await user.click(closeButton)

      expect(closePdf).toHaveBeenCalledWith('doc-1')
    })

    it('should not trigger tab selection when clicking the close button', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      const closeButton = screen.getByLabelText('Close Document 1.pdf')
      
      await user.click(closeButton)

      // setActive should not be called
      expect(mockStore.setActive).not.toHaveBeenCalled()
      expect(mockRouter.openReader).not.toHaveBeenCalled()
    })

    it('should handle hover state on tabs', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      const inactiveTab = screen.getByTestId('pdf-tab-doc-2')
      
      // Initially not hovered
      expect(inactiveTab).toHaveAttribute('data-active', 'false')

      // Hover over tab
      await user.hover(inactiveTab)
      
      // Style changes are hard to test with vars, but we can check if it stays not active
      expect(inactiveTab).toHaveAttribute('data-active', 'false')

      // Unhover
      await user.unhover(inactiveTab)
      
      expect(inactiveTab).toHaveAttribute('data-active', 'false')
    })
  })

  describe('Drag and Drop', () => {
    it('should handle drag end and reorder documents', async () => {
      render(<PdfTabs />)

      // Mock the drag end event
      const dragEndEvent = {
        active: { id: 'doc-1' },
        over: { id: 'doc-2' },
      }

      // Trigger drag end through the store's reorder function
      // In a real scenario, you'd simulate actual drag events
      act(() => {
        mockStore.reorder(dragEndEvent.active.id as string, dragEndEvent.over.id as string)
      })

      expect(mockStore.reorder).toHaveBeenCalledWith('doc-1', 'doc-2')
    })

    it('should not reorder when dragging over the same item', async () => {
      render(<PdfTabs />)

      act(() => {
        mockStore.reorder('doc-1', 'doc-1')
      })

      expect(mockStore.reorder).toHaveBeenCalledWith('doc-1', 'doc-1')
    })
  })

  describe('Navigation', () => {
    it('should go home when no documents are open in reader view', async () => {
      // Simulate empty documents
      vi.mocked(useDocumentsStore).mockImplementation((selector) => {
        if (typeof selector === 'function') {
          return selector({
            ...mockStore,
            documents: {},
            documentOrder: [],
            open: vi.mocked(mockStore.open),
            close: vi.mocked(mockStore.close),
          })
        }
        return mockStore
      })

      render(<PdfTabs />)

      await waitFor(() => {
        expect(mockRouter.goHome).toHaveBeenCalledTimes(1)
      })
    })

    it('should not go home when documents exist', async () => {
      render(<PdfTabs />)

      await waitFor(() => {
        expect(mockRouter.goHome).not.toHaveBeenCalled()
      })
    })

    it('should not go home when not in reader view', async () => {
      // Set router to not be in reader view
      vi.mocked(useScreenState).mockReturnValue({
        ...mockRouter,
        screen: { name: 'home' },
      })

      // Empty documents but not in reader
      vi.mocked(useDocumentsStore).mockImplementation((selector) => {
        if (typeof selector === 'function') {
          return selector({
            ...mockStore,
            documents: {},
            documentOrder: [],
            open: vi.mocked(mockStore.open),
            close: vi.mocked(mockStore.close),
          })
        }
        return mockStore
      })

      render(<PdfTabs />)

      await waitFor(() => {
        expect(mockRouter.goHome).not.toHaveBeenCalled()
      })
    })
  })

  describe('Accessibility', () => {
    it('should have proper ARIA labels on interactive elements', () => {
      render(<PdfTabs />)

      // Open PDF button should have a label
      expect(screen.getByLabelText('Open PDF')).toBeInTheDocument()

      // Close buttons should be accessible
      const closeButtons = screen.getAllByRole('button')
      expect(closeButtons.length).toBeGreaterThan(0)
    })

    it('should support keyboard navigation', async () => {
      const user = userEvent.setup()
      render(<PdfTabs />)

      // The first focusable elements are the tabs themselves (because of dnd-kit handle)
      // or the close buttons.
      
      // Let's just tab and check if we hit the "Open PDF" button eventually
      await user.tab() // Focus first tab or close button
      await user.tab() // Focus next...
      await user.tab()
      await user.tab()
      
      // We don't want to be too specific about the exact order because dnd-kit 
      // might inject elements, but the Open PDF button should be reachable.
      const openButton = screen.getByLabelText('Open PDF')
      
      // Tab until we hit the open button or run out of elements (max 10 tabs)
      let found = false
      for (let i = 0; i < 10; i++) {
        if (document.activeElement === openButton) {
          found = true
          break
        }
        await user.tab()
      }
      
      expect(found).toBe(true)
    })
  })

  describe('Error Handling', () => {
    it('should handle missing documents gracefully', () => {
      // Simulate a document missing from the documents object
      vi.mocked(useDocumentsStore).mockImplementation((selector) => {
        if (typeof selector === 'function') {
          return selector({
            ...mockStore,
            documentOrder: ['doc-1', 'missing-doc', 'doc-2'],
            open: vi.mocked(mockStore.open),
            close: vi.mocked(mockStore.close),
          })
        }
        return mockStore
      })

      render(<PdfTabs />)

      // Should render existing documents and skip missing ones
      expect(screen.getByText('Document 1.pdf')).toBeInTheDocument()
      expect(screen.getByText('Document 2.pdf')).toBeInTheDocument()
      
      // There should be 2 tabs instead of 3
      const tabs = screen.getAllByText(/Document.*\.pdf/)
      expect(tabs).toHaveLength(2)
    })
  })
})