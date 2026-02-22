import { renderHook, waitFor } from '@/test/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { useWindowMaximized } from './useWindowMaximized'
import { getCurrentWindow } from '@tauri-apps/api/window'

// Mock Tauri window API
vi.mock('@tauri-apps/api/window')

describe('useWindowMaximized', () => {
  const unlistenMock = vi.fn()
  let onResizedCallback: () => Promise<void>

  const mockWindow = {
    isMaximized: vi.fn(),
    onResized: vi.fn(async (cb) => {
      onResizedCallback = cb
      return unlistenMock
    }),
  }

  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(getCurrentWindow).mockReturnValue(mockWindow as any)
    mockWindow.isMaximized.mockResolvedValue(false)
  })

  it('should initialize with false then update to initial window state', async () => {
    mockWindow.isMaximized.mockResolvedValueOnce(true)
    
    const { result } = renderHook(() => useWindowMaximized())

    // Initial state is false
    expect(result.current).toBe(false)

    // Wait for the effect to resolve
    await waitFor(() => {
      expect(result.current).toBe(true)
    })
    
    expect(mockWindow.isMaximized).toHaveBeenCalled()
    expect(mockWindow.onResized).toHaveBeenCalled()
  })

  it('should update state when window is resized', async () => {
    mockWindow.isMaximized.mockResolvedValue(false)
    
    const { result } = renderHook(() => useWindowMaximized())

    // Wait for init
    await waitFor(() => {
      expect(mockWindow.onResized).toHaveBeenCalled()
    })

    // Simulate window becoming maximized
    mockWindow.isMaximized.mockResolvedValue(true)
    
    // Trigger the callback registered in onResized
    await onResizedCallback()

    await waitFor(() => {
      expect(result.current).toBe(true)
    })
  })

  it('should call unlisten on unmount', async () => {
    const { unmount } = renderHook(() => useWindowMaximized())

    // Wait for unlisten function to be registered
    await waitFor(() => {
      expect(mockWindow.onResized).toHaveBeenCalled()
    })

    // Unmount the hook
    unmount()

    // It might take a tick for unlisten to be called if it was set via await
    await waitFor(() => {
      expect(unlistenMock).toHaveBeenCalledTimes(1)
    })
  })
})
