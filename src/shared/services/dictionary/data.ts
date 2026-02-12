import { open, SeekMode } from "@tauri-apps/plugin-fs";
import type { Synset } from "./types";

export async function readSynset(
  dataPath: string,
  offset: number
): Promise<Synset | null> {
  const file = await open(dataPath, { read: true });

  await file.seek(offset, SeekMode.Start);

  const buffer = new Uint8Array(2048);

  const bytesRead = await file.read(buffer);

  await file.close();

  if (!bytesRead) return null;

  const text = new TextDecoder().decode(buffer.subarray(0, bytesRead));
  const line = text.split("\n")[0];

  return parseDataLine(line, offset);
}

function parseDataLine(line: string, offset: number): Synset {
  const [dataPart, glossPart] = line.split("|");

  const tokens = dataPart.trim().split(/\s+/);

  const pos = tokens[2] as Synset["pos"];
  const wordCount = parseInt(tokens[3], 16);

  const synonyms: string[] = [];
  let index = 4;

  for (let i = 0; i < wordCount; i++) {
    synonyms.push(tokens[index]);
    index += 2;
  }

  return {
    offset,
    pos,
    synonyms,
    gloss: glossPart?.trim() ?? "",
  };
}
