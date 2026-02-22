import { render, screen, fireEvent, waitFor } from '@/test/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { DictionaryDownloadPrompt } from './DictionaryDownloadPrompt'
import { downloadAndInstallWordNet } from '@/services/dictionary'
import { notifications } from '@mantine/notifications'

// Mock dependencies
vi.mock('@/services/dictionary', () => ({
  downloadAndInstallWordNet: vi.fn(),
}))

vi.mock('@mantine/notifications', () => ({
  notifications: {
    show: vi.fn(),
  },
}))

describe('DictionaryDownloadPrompt', () => {
  const mockOnClose = vi.fn()
  const mockOnComplete = vi.fn()

  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should render when opened', () => {
    render(
      <DictionaryDownloadPrompt 
        opened={true} 
        onClose={mockOnClose} 
        onComplete={mockOnComplete} 
      />
    )

    expect(screen.getByText('Additional Data Required')).toBeInTheDocument()
    expect(screen.getByText(/Additional Data Required/i)).toBeInTheDocument()
    expect(screen.getByText(/Would you like to download it now\?/i)).toBeInTheDocument()
    expect(screen.getByText('Download Now')).toBeInTheDocument()
    expect(screen.getByText('Later')).toBeInTheDocument()
  })

  it('should call onClose when clicking Later', () => {
    render(
      <DictionaryDownloadPrompt 
        opened={true} 
        onClose={mockOnClose} 
        onComplete={mockOnComplete} 
      />
    )

    fireEvent.click(screen.getByText('Later'))
    expect(mockOnClose).toHaveBeenCalled()
  })

  it('should start download and show progress', async () => {
    let statusCallback: (status: any) => void = () => {}
    vi.mocked(downloadAndInstallWordNet).mockImplementation(async (cb) => {
      statusCallback = cb!
      return new Promise(() => {}) // Never resolves to keep it in downloading state
    })

    render(
      <DictionaryDownloadPrompt 
        opened={true} 
        onClose={mockOnClose} 
        onComplete={mockOnComplete} 
      />
    )

    fireEvent.click(screen.getByText('Download Now'))

    expect(downloadAndInstallWordNet).toHaveBeenCalled()
    expect(screen.getByText('Downloading...')).toBeInTheDocument()

    const { act } = await import('react')

    // Update progress
    await act(async () => {
      statusCallback({ stage: 'downloading', percent: 45 })
    })
    expect(screen.getByText('45%')).toBeInTheDocument()

    // Update to extracting
    await act(async () => {
      statusCallback({ stage: 'extracting' })
    })
    expect(screen.getByText('Extracting...')).toBeInTheDocument()
    expect(screen.queryByText('45%')).not.toBeInTheDocument()
  })

  it('should handle successful download', async () => {
    vi.mocked(downloadAndInstallWordNet).mockResolvedValue(undefined)

    render(
      <DictionaryDownloadPrompt 
        opened={true} 
        onClose={mockOnClose} 
        onComplete={mockOnComplete} 
      />
    )

    fireEvent.click(screen.getByText('Download Now'))

    await waitFor(() => {
      expect(notifications.show).toHaveBeenCalledWith(expect.objectContaining({
        title: 'Success',
        color: 'green'
      }))
      expect(mockOnComplete).toHaveBeenCalled()
      expect(mockOnClose).toHaveBeenCalled()
    })
  })

  it('should handle download failure', async () => {
    vi.mocked(downloadAndInstallWordNet).mockRejectedValue(new Error('Network error'))
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

    render(
      <DictionaryDownloadPrompt 
        opened={true} 
        onClose={mockOnClose} 
        onComplete={mockOnComplete} 
      />
    )

    fireEvent.click(screen.getByText('Download Now'))

    await waitFor(() => {
      expect(notifications.show).toHaveBeenCalledWith(expect.objectContaining({
        title: 'Error',
        color: 'red'
      }))
      expect(screen.getByText('Download Now')).not.toHaveAttribute('data-loading')
    })
    
    consoleSpy.mockRestore()
  })
})
