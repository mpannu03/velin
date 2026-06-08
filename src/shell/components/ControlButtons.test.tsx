import { render, screen } from '@/test/test-utils'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ControlButtons } from './ControlButtons'
import { getCurrentWindow } from '@tauri-apps/api/window'
import { useWindowMaximized } from '../hooks'

// Mock dependencies
vi.mock('@tauri-apps/api/window')
vi.mock('../hooks')

describe('ControlButtons', () => {
  const mockWindow = {
    minimize: vi.fn(),
    toggleMaximize: vi.fn(),
    close: vi.fn(),
    isMaximized: vi.fn().mockResolvedValue(false),
    onResized: vi.fn().mockResolvedValue(() => {}),
  }

  beforeEach(() => {
    vi.clearAllMocks()
    vi.mocked(getCurrentWindow).mockReturnValue(mockWindow as any)
    vi.mocked(useWindowMaximized).mockReturnValue(false)
  })

  it('should render all control buttons', () => {
    render(<ControlButtons />)
    
    // There should be 3 buttons
    const buttons = screen.getAllByRole('button')
    expect(buttons).toHaveLength(3)
  })

  it('should call minimize when minimize button is clicked', async () => {
    const user = userEvent.setup()
    render(<ControlButtons />)

    const minimizeBtn = screen.getByLabelText('Minimize')
    await user.click(minimizeBtn)

    expect(mockWindow.minimize).toHaveBeenCalledTimes(1)
  })

  it('should call toggleMaximize when maximize button is clicked', async () => {
    const user = userEvent.setup()
    render(<ControlButtons />)

    const maximizeBtn = screen.getByLabelText('Maximize')
    await user.click(maximizeBtn)

    expect(mockWindow.toggleMaximize).toHaveBeenCalledTimes(1)
  })

  it('should call close when close button is clicked', async () => {
    const user = userEvent.setup()
    render(<ControlButtons />)

    const closeBtn = screen.getByLabelText('Close')
    await user.click(closeBtn)

    expect(mockWindow.close).toHaveBeenCalledTimes(1)
  })

  it('should show restore aria-label when maximized', () => {
    vi.mocked(useWindowMaximized).mockReturnValue(true)
    render(<ControlButtons />)
    
    expect(screen.getByLabelText('Restore')).toBeInTheDocument()
  })
})