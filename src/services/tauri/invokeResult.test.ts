import { describe, it, expect, vi, beforeEach } from 'vitest'
import { safeInvoke } from './invokeResult'
import { invoke } from '@tauri-apps/api/core'

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}))

describe('safeInvoke', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should return { ok: true, data } when invoke succeeds', async () => {
    const mockData = { test: 'data' }
    vi.mocked(invoke).mockResolvedValue(mockData)

    const result = await safeInvoke('test_cmd', { arg: 1 })

    expect(result).toEqual({ ok: true, data: mockData })
    expect(invoke).toHaveBeenCalledWith('test_cmd', { arg: 1 })
  })

  it('should return { ok: false, error } when invoke rejects with a string', async () => {
    const errorMsg = 'Backend error'
    vi.mocked(invoke).mockRejectedValue(errorMsg)

    const result = await safeInvoke('test_cmd')

    expect(result).toEqual({ ok: false, error: errorMsg })
  })

  it('should return { ok: false, error } when invoke rejects with an Error object', async () => {
    const errorMsg = 'Something went wrong'
    vi.mocked(invoke).mockRejectedValue(new Error(errorMsg))

    const result = await safeInvoke('test_cmd')

    expect(result).toEqual({ ok: false, error: errorMsg })
  })

  it('should return { ok: false, error: "Unexpected error" } when invoke rejects with an unknown error', async () => {
    vi.mocked(invoke).mockRejectedValue({})

    const result = await safeInvoke('test_cmd')

    expect(result).toEqual({ ok: false, error: 'Unexpected error' })
  })
})
