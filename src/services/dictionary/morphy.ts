import { PartOfSpeech } from "./types"

export interface MorphyOptions {
  hasIndexEntry: (word: string, PartOfSpeech: PartOfSpeech) => boolean
  exceptionMap: Record<PartOfSpeech, Map<string, string[]>>
}

export const exceptionMap: Record<PartOfSpeech, Map<string, string[]>> = {
  noun: new Map(),
  verb: new Map(),
  adj: new Map(),
  adv: new Map(),
}

export function parseExceptionLine(line: string, pos: PartOfSpeech) {
  const parts = line.trim().split(/\s+/)
  const inflected = parts[0]
  const lemmas = parts.slice(1)

  exceptionMap[pos].set(inflected, lemmas)
}

export const indexStore: Record<PartOfSpeech, Map<string, any>> = {
  noun: new Map(),
  verb: new Map(),
  adj: new Map(),
  adv: new Map(),
}

export function hasIndexEntry(word: string, pos: PartOfSpeech): boolean {
  return indexStore[pos].has(word)
}

export function createMorphy({
  hasIndexEntry,
  exceptionMap,
}: MorphyOptions) {
  const substitutions: Record<PartOfSpeech, Array<[string, string]>> = {
    noun: [
      ["s", ""],
      ["ses", "s"],
      ["xes", "x"],
      ["zes", "z"],
      ["ches", "ch"],
      ["shes", "sh"],
      ["men", "man"],
      ["ies", "y"],
    ],
    verb: [
      ["s", ""],
      ["ies", "y"],
      ["es", ""],
      ["ed", ""],
      ["ing", ""],
    ],
    adj: [
      ["er", ""],
      ["est", ""],
    ],
    adv: [],
  }

  function isVowel(char: string) {
    return "aeiou".includes(char)
  }

  function tryConsonantUndoubling(word: string): string {
    if (word.length >= 2) {
      const last = word[word.length - 1]
      const secondLast = word[word.length - 2]

      if (last === secondLast && !isVowel(last)) {
        return word.slice(0, -1)
      }
    }
    return word
  }

  function applySubstitutions(
    word: string,
    PartOfSpeech: PartOfSpeech,
    results: Set<string>
  ) {
    for (const [suffix, replacement] of substitutions[PartOfSpeech]) {
      if (word.endsWith(suffix)) {
        const base = word.slice(0, -suffix.length) + replacement

        if (base && hasIndexEntry(base, PartOfSpeech)) {
          results.add(base)
        }

        const undoubled = tryConsonantUndoubling(base)
        if (undoubled !== base && hasIndexEntry(undoubled, PartOfSpeech)) {
          results.add(undoubled)
        }
      }
    }
  }

  function morphy(word: string): string[] {
    const normalized = word.toLowerCase()
    const results = new Set<string>()

    const allPartOfSpeech: PartOfSpeech[] = ["noun", "verb", "adj", "adv"]

    for (const PartOfSpeech of allPartOfSpeech) {
      if (hasIndexEntry(normalized, PartOfSpeech)) {
        results.add(normalized)
      }

      const exceptions = exceptionMap[PartOfSpeech].get(normalized)
      if (exceptions) {
        for (const lemma of exceptions) {
          if (hasIndexEntry(lemma, PartOfSpeech)) {
            results.add(lemma)
          }
        }
        continue
      }

      const queue = [normalized]
      const visited = new Set<string>()

      while (queue.length > 0) {
        const current = queue.shift()!
        if (visited.has(current)) continue
        visited.add(current)

        applySubstitutions(current, PartOfSpeech, results)

        for (const [suffix, replacement] of substitutions[PartOfSpeech]) {
          if (current.endsWith(suffix)) {
            const next =
              current.slice(0, -suffix.length) + replacement

            if (next && !visited.has(next)) {
              queue.push(next)
            }
          }
        }
      }
    }

    return [...results]
  }

  return morphy
}
