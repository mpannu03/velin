import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createMorphy, parseExceptionLine, exceptionMap, indexStore, hasIndexEntry } from './morphy'
import { PartOfSpeech } from './types'

describe('morphy', () => {
  describe('parseExceptionLine and exceptionMap', () => {
    beforeEach(() => {
      // Clear exception map before each test
      ;(Object.keys(exceptionMap) as PartOfSpeech[]).forEach(pos => {
        exceptionMap[pos].clear()
      })
    })

    it('should parse exception lines correctly', () => {
      parseExceptionLine('feet foot', 'noun')
      expect(exceptionMap.noun.get('feet')).toEqual(['foot'])

      parseExceptionLine('went go', 'verb')
      expect(exceptionMap.verb.get('went')).toEqual(['go'])
      
      parseExceptionLine('better good best', 'adj')
      expect(exceptionMap.adj.get('better')).toEqual(['good', 'best'])
    })
  })

  describe('hasIndexEntry and indexStore', () => {
    beforeEach(() => {
      ;(Object.keys(indexStore) as PartOfSpeech[]).forEach(pos => {
        indexStore[pos].clear()
      })
    })

    it('should return true if word exists in indexStore', () => {
      indexStore.noun.set('cat', {})
      expect(hasIndexEntry('cat', 'noun')).toBe(true)
      expect(hasIndexEntry('dog', 'noun')).toBe(false)
    })
  })

  describe('createMorphy function (morphological processor)', () => {
    const mockHasIndexEntry = vi.fn()
    const mockExceptionMap: Record<PartOfSpeech, Map<string, string[]>> = {
      noun: new Map(),
      verb: new Map(),
      adj: new Map(),
      adv: new Map(),
    }

    const morphy = createMorphy({
      hasIndexEntry: mockHasIndexEntry,
      exceptionMap: mockExceptionMap,
    })

    beforeEach(() => {
      vi.clearAllMocks()
      ;(Object.keys(mockExceptionMap) as PartOfSpeech[]).forEach(pos => {
        mockExceptionMap[pos].clear()
      })
    })

    it('should return the word itself if it has an index entry', () => {
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'cat' && pos === 'noun')
      
      const results = morphy('cat')
      expect(results).toContain('cat')
    })

    it('should handle exceptions', () => {
      mockExceptionMap.noun.set('feet', ['foot'])
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'foot' && pos === 'noun')

      const results = morphy('feet')
      expect(results).toContain('foot')
      expect(results).not.toContain('feet')
    })

    it('should apply noun substitutions (plural to singular)', () => {
      // "cats" -> "cat"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'cat' && pos === 'noun')
      
      const results = morphy('cats')
      expect(results).toContain('cat')
    })

    it('should apply complex noun substitutions', () => {
      // "bushes" -> "bush"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'bush' && pos === 'noun')
      expect(morphy('bushes')).toContain('bush')

      // "flies" -> "fly"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'fly' && pos === 'noun')
      expect(morphy('flies')).toContain('fly')
    })

    it('should handle verb substitutions (inflected to lemma)', () => {
      // "running" -> "run" (requires undoubling check if "run" was "runn")
      // Actually "running" suffix is "ing", replacement is "". "runn" -> "run"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'run' && pos === 'verb')
      expect(morphy('running')).toContain('run')

      // "watched" -> "watch"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'watch' && pos === 'verb')
      expect(morphy('watched')).toContain('watch')
    })

    it('should handle consonant undoubling', () => {
      // "dropped" -> "dropp" -> "drop"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'drop' && pos === 'verb')
      const results = morphy('dropped')
      expect(results).toContain('drop')
    })

    it('should handle recursive substitutions', () => {
      // This tests the queue-based replacement logic
      // e.g., "cities" -> "city"
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'city' && pos === 'noun')
      expect(morphy('cities')).toContain('city')
    })

    it('should lowercase the input word', () => {
      mockHasIndexEntry.mockImplementation((word, pos) => word === 'cat' && pos === 'noun')
      expect(morphy('CATS')).toContain('cat')
    })
  })
})
