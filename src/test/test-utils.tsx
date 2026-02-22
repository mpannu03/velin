import { ReactElement } from 'react'
import {
  render as rtlRender,
  RenderOptions,
  act,
  cleanup,
} from '@testing-library/react'
import { MantineProvider } from '@mantine/core'
import { afterEach, beforeAll, vi } from 'vitest'

// Mock matchMedia
beforeAll(() => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
})

function AllProviders({ children }: { children: React.ReactNode }) {
  return (
    <MantineProvider forceColorScheme="light">
      {children}
    </MantineProvider>
  )
}

function customRender(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  let result: ReturnType<typeof rtlRender>
  
  act(() => {
    result = rtlRender(ui, { wrapper: AllProviders, ...options })
  })
  
  return result!
}

afterEach(() => {
  cleanup()
  vi.clearAllMocks()
})

export * from '@testing-library/react'
export { customRender as render }