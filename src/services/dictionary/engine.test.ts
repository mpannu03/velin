import { describe, it, expect, vi, beforeEach } from 'vitest'
import { DictionaryEngine } from './engine'
import { readFile } from '@tauri-apps/plugin-fs'

// Mock dependencies
vi.mock('@tauri-apps/plugin-fs')
vi.mock('@tauri-apps/api/path')
vi.mock('./morphy', () => ({
  createMorphy: vi.fn(() => vi.fn((word) => [word])),
  exceptionMap: {
    noun: new Map(),
    verb: new Map(),
    adj: new Map(),
    adv: new Map(),
  },
  hasIndexEntry: vi.fn().mockReturnValue(true),
}))

describe('DictionaryEngine', () => {
  const mockDictPath = '/mock/dict'
  let engine: DictionaryEngine

  beforeEach(() => {
    vi.clearAllMocks()
    engine = new DictionaryEngine(mockDictPath)
  })

  describe('extractSynsetOffsets', () => {
    it('should correctly extract offsets from an index line', () => {
      const indexLine = 'dog n 1 2 @ #m 1 0 12345678 87654321'
      const offsets = (engine as any).extractSynsetOffsets(indexLine)
      expect(offsets).toEqual(['12345678', '87654321'])
    })
  })

  describe('parseDataLine', () => {
    it('should correctly parse a synset data line', () => {
      const dataLine = '12345678 01 n 02 dog 0 domestic_dog 0 001 @ 00000000 n 0000 | a common mammal; "the dog barked" "my dog is happy"'
      const synset = (engine as any).parseDataLine(dataLine, 'dog')
      
      expect(synset).not.toBeNull()
      expect(synset.definition).toBe('a common mammal')
      expect(synset.synonyms).toEqual(['domestic_dog'])
      expect(synset.examples).toEqual(['the dog barked', 'my dog is happy'])
    })

    it('should handle complex gloss with multiple semicolons', () => {
      const dataLine = '12345678 01 n 01 test 0 000 | definition 1; definition 2; "this is an example of a test"'
      const synset = (engine as any).parseDataLine(dataLine, 'test')
      expect(synset.definition).toBe('definition 1')
      expect(synset.examples).toEqual(['this is an example of a test'])
    })
  })

  describe('search', () => {
    it('should return search results for a word found in index', async () => {
      const lemma = 'test'
      vi.mocked(readFile).mockImplementation(async (path) => {
        if ((path as string).includes('index.noun')) return new TextEncoder().encode(`${lemma} n 1 0 1 0 11111111\n`)
        if ((path as string).includes('data.noun')) return new TextEncoder().encode('11111111 01 n 01 test 0 000 | research\n')
        return new Uint8Array()
      })

      const result = await engine.search(lemma)
      expect(result.noun).toHaveLength(1)
      expect(result.noun[0].definition).toBe('research')
    })

    it('should use morphy to find lemmas if literal search fails', async () => {
      const query = 'tests'
      const lemma = 'test'
      
      // Mock morphy to always return the lemma for this test
      const { createMorphy } = await import('./morphy')
      vi.mocked(createMorphy).mockReturnValue(vi.fn((word: string) => {
        if (word === query) return [lemma]
        return [word]
      }))

      // Re-initialize engine to use the new mock
      engine = new DictionaryEngine(mockDictPath)

      vi.mocked(readFile).mockImplementation(async (path) => {
        // Return empty for everything except literal 'test' in noun index
        if ((path as string).includes('index.noun')) {
           return new TextEncoder().encode(`test n 1 0 1 0 11111111\n`)
        }
        if ((path as string).includes('data.noun')) {
           return new TextEncoder().encode('11111111 01 n 01 test 0 000 | research\n')
        }
        return new Uint8Array()
      })

      const result = await engine.search(query)
      expect(result.noun).toHaveLength(1)
      expect(result.noun[0].definition).toBe('research')
    })
  })
})
