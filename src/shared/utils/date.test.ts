import { describe, it, expect } from 'vitest'
import { parsePdfDate, formatPdfDateTime } from './date'

describe('date utils', () => {
  describe('parsePdfDate', () => {
    it('should return null for empty input', () => {
      expect(parsePdfDate(null)).toBeNull()
      expect(parsePdfDate(undefined)).toBeNull()
      expect(parsePdfDate('')).toBeNull()
    })

    it('should parse basic PDF date with D: prefix', () => {
      // PDF dates without timezone are defaulted to "Z" (UTC) by our utility
      const date = parsePdfDate('D:20240222123045')
      expect(date).toBeInstanceOf(Date)
      expect(date?.getUTCFullYear()).toBe(2024)
      expect(date?.getUTCMonth()).toBe(1) // February is 1 (0-indexed)
      expect(date?.getUTCDate()).toBe(22)
      expect(date?.getUTCHours()).toBe(12)
      expect(date?.getUTCMinutes()).toBe(30)
      expect(date?.getUTCSeconds()).toBe(45)
    })

    it('should parse PDF date without D: prefix', () => {
      const date = parsePdfDate('20240222123045')
      expect(date?.getUTCFullYear()).toBe(2024)
    })

    it('should handle UTC timezone (Z)', () => {
      const date = parsePdfDate('D:20240222123045Z')
      expect(date?.getTime()).toBe(new Date('2024-02-22T12:30:45Z').getTime())
    })

    it('should handle positive offset (+0530)', () => {
      const date = parsePdfDate("D:20240222123045+05'30'")
      expect(date?.getTime()).toBe(new Date('2024-02-22T12:30:45+05:30').getTime())
    })

    it('should handle negative offset (-0800)', () => {
      const date = parsePdfDate("D:20240222123045-08'00'")
      expect(date?.getTime()).toBe(new Date('2024-02-22T12:30:45-08:00').getTime())
    })

    it('should handle partial dates (year only)', () => {
      const date = parsePdfDate('2024')
      expect(date?.getUTCFullYear()).toBe(2024)
      expect(date?.getUTCMonth()).toBe(0) // Jan
      expect(date?.getUTCDate()).toBe(1)
    })

    it('should handle partial dates (year and month)', () => {
      const date = parsePdfDate('202405')
      expect(date?.getUTCFullYear()).toBe(2024)
      expect(date?.getUTCMonth()).toBe(4) // May
    })

    it('should return null for invalid dates', () => {
      expect(parsePdfDate('invalid')).toBeNull()
    })
  })

  describe('formatPdfDateTime', () => {
    it('should return empty string for null input', () => {
      expect(formatPdfDateTime(null)).toBe('')
    })

    it('should format a valid PDF date string', () => {
      const result = formatPdfDateTime('D:20240222123045Z', 'en-US')
      expect(result).toContain('2024')
      expect(result).toContain('Feb')
      expect(result).toContain('22')
    })
  })
})
