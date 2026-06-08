import { render, screen } from '@/test/test-utils'
import { describe, it, expect, vi } from 'vitest'
import { TitleBar } from './TitleBar'

// Mock sub-components
vi.mock('./PdfTabs', () => ({
  PdfTabs: () => <div data-testid="mock-pdf-tabs">PdfTabs</div>,
}))

vi.mock('./ControlButtons', () => ({
  ControlButtons: () => <div data-testid="mock-control-buttons">ControlButtons</div>,
}))

describe('TitleBar', () => {
  it('should render TitleBar with its components', () => {
    render(<TitleBar />)

    // Check if sub-components are rendered
    expect(screen.getByTestId('mock-pdf-tabs')).toBeInTheDocument()
    expect(screen.getByTestId('mock-control-buttons')).toBeInTheDocument()
  })

  it('should have tauri drag region attribute', () => {
    render(<TitleBar />)
    const titleBar = screen.getByTestId('title-bar')
    
    expect(titleBar).toHaveAttribute('data-tauri-drag-region')
  })
})
