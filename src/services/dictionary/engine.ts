import { appDataDir } from "@tauri-apps/api/path";
import { readFile } from "@tauri-apps/plugin-fs";
import { SearchResult, Synset } from "./types";

type FileType = "adj" | "adv" | "noun" | "verb";

class DictionaryEngine {
  constructor(private dictPath: string) {}

  public async search(query: string): Promise<SearchResult> {
    const lemma = query.toLowerCase();
    const FILE_TYPES = ["adj", "adv", "noun", "verb"] as const;

    const result: SearchResult = {
      adj: [],
      adv: [],
      noun: [],
      verb: [],
    };

    for (const type of FILE_TYPES) {
      const search = await this.findLemmaLine(lemma, type);
      const offset = this.extractSynsetOffsets(search);
      const data = await this.getData(offset, type, lemma);
      if (data.length > 0) {
        result[type] = data;
      }
    }

    return result;
  }

  private async findLemmaLine(
    lemma: string,
    filetype: FileType,
  ): Promise<string> {
    const nounIndex = await this.openFile(filetype);

    return nounIndex.split("\n").find((line) => line.startsWith(lemma)) || "";
  }

  private async openFile(
    filetype: FileType,
    isData: boolean = false,
  ): Promise<string> {
    var filePath = `${this.dictPath}/index.${filetype}`;
    if (isData) {
      filePath = `${this.dictPath}/data.${filetype}`;
    }

    try {
      const bytes = await readFile(filePath);
      const data = new TextDecoder("utf-8").decode(bytes);
      return data;
    } catch (err) {
      console.error("Error reading file:", err);
      return "";
    }
  }

  private extractSynsetOffsets(line: string): string[] {
    const parts = line.trim().split(/\s+/);

    const pCount = Number(parts[3]);
    const offsetStartIndex = 6 + pCount;

    const offsets = parts.slice(offsetStartIndex);
    return offsets;
  }

  private parseDataLine(line: string, lemma: string): Synset | null {
    const [metaPart, glossPart] = line.split(" | ");
    if (!metaPart || !glossPart) return null;

    const parts = metaPart.trim().split(/\s+/);

    const wordCount = parseInt(parts[3], 10);

    const allSynonyms: string[] = [];
    for (let i = 0; i < wordCount; i++) {
      allSynonyms.push(parts[4 + i * 2]);
    }

    const synonyms = allSynonyms.filter(
      (s) => s.toLowerCase() !== lemma.toLowerCase(),
    );

    const pointerCountIndex = 4 + wordCount * 2;
    const pointerCount = parseInt(parts[pointerCountIndex], 10);

    const pointers: { symbol: string; offset: string; pos: string }[] = [];
    for (let i = 0; i < pointerCount; i++) {
      const base = pointerCountIndex + 1 + i * 4;
      pointers.push({
        symbol: parts[base],
        offset: parts[base + 1],
        pos: parts[base + 2],
      });
    }

    const definition = glossPart.trim().split(";")[0];
    const exampleMatches = [...glossPart.matchAll(/"(.*?)"/g)];
    const lemmaRegex = new RegExp(`\\b${lemma}\\b`, "i");
    const examples = exampleMatches
      .map((m) => m[1])
      .filter((ex) => lemmaRegex.test(ex));

    return {
      synonyms,
      definition,
      examples,
      pointers,
    };
  }

  private async getData(
    offset: string[],
    fileType: FileType,
    lemma: string,
  ): Promise<Synset[]> {
    const nounData = await this.openFile(fileType, true);
    const lines = nounData.split("\n");
    const data: Synset[] = [];

    for (const off of offset) {
      const line = lines.find((line) => line.startsWith(off));
      if (line) {
        const synset = this.parseDataLine(line, lemma);
        if (synset) {
          data.push(synset);
        }
      }
    }

    return data;
  }
}

export async function createDictionaryEngine(): Promise<DictionaryEngine> {
  const base = await appDataDir();
  const dictPath = `${base}/wordnet/WNdb-3.0/dict`;
  return new DictionaryEngine(dictPath);
}
