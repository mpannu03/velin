import { render, screen } from '@/test/test-utils'
import { describe, it, expect, vi } from 'vitest'
import { ShellLayout } from './ShellLayout'

// Mock sub-components
vi.mock('./components', () => ({
  TitleBar: () => <div data-testid="mock-title-bar">TitleBar</div>,
}))

vi.mock('@/app/screenRouter', () => ({
  ScreenNavigationBar: () => <div data-testid="mock-navigation-bar">NavigationBar</div>,
}))

describe('ShellLayout', () => {
  it('should render ShellLayout with TitleBar and NavigationBar', () => {
    render(
      <ShellLayout>
        <div data-testid="child-content">Content</div>
      </ShellLayout>
    )

    // Check if sub-components are rendered
    expect(screen.getByTestId('mock-title-bar')).toBeInTheDocument()
    expect(screen.getByTestId('mock-navigation-bar')).toBeInTheDocument()
    
    // Check if children content is rendered
    expect(screen.getByTestId('child-content')).toBeInTheDocument()
  })

  it('should render even without children', () => {
    render(<ShellLayout />)
    
    expect(screen.getByTestId('mock-title-bar')).toBeInTheDocument()
    expect(screen.getByTestId('mock-navigation-bar')).toBeInTheDocument()
  })

  it('should wrap content in AppShell.Main', () => {
    const { container } = render(
      <ShellLayout>
        <div data-testid="child-content">Content</div>
      </ShellLayout>
    )

    // Check if the content is inside a main tag (AppShell.Main uses <main>)
    const mainElement = container.querySelector('main')
    expect(mainElement).toBeInTheDocument()
    expect(mainElement).toContainElement(screen.getByTestId('child-content'))
  })
})
