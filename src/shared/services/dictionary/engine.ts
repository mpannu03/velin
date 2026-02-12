import { lookupOffsets } from "./lookup";
import { readSynset } from "./data";
import type { Synset } from "./types";
import { appDataDir } from "@tauri-apps/api/path";

class DictionaryEngine {
  constructor(private dictPath: string) {}

  async lookup(word: string): Promise<Synset[]> {
    const lemma = word.toLowerCase().replace(/\s+/g, "_");

    const posMap = {
      n: "noun",
      v: "verb",
      a: "adj",
      r: "adv",
    };

    const results: Synset[] = [];

    for (const pos of Object.keys(posMap) as Array<keyof typeof posMap>) {
      const indexPath = `${this.dictPath}/index.${posMap[pos]}`;
      const dataPath = `${this.dictPath}/data.${posMap[pos]}`;

      const offsets = await lookupOffsets(indexPath, lemma);

      for (const offset of offsets) {
        const synset = await readSynset(dataPath, offset);
        if (synset) results.push(synset);
      }
    }

    return results;
  }
}

export async function createDictionaryEngine(): Promise<DictionaryEngine> {
  const base = await appDataDir();
  const dictPath = `${base}/wordnet/WNdb-3.0/dict`;
  return new DictionaryEngine(dictPath);
}

