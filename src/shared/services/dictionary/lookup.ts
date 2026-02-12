import { open, SeekMode } from "@tauri-apps/plugin-fs";

export async function lookupOffsets(
  indexPath: string,
  lemma: string
): Promise<number[]> {
  const file = await open(indexPath, { read: true });

  try {
    const stat = await file.stat();
    let start = 0;
    let end = stat.size;

    while (start < end) {
      const mid = Math.floor((start + end) / 2);
      await file.seek(mid, SeekMode.Start);
      let currentPos = mid;

      if (mid > 0) {
        const { bytesConsumed } = await readLine(file);
        currentPos += bytesConsumed;
      }

      if (currentPos >= end) break;

      const { line, bytesConsumed } = await readLine(file);

      if (!line) break;

      if (line.startsWith("  ")) {
      }

      const parts = line.split(" ");
      const currentLemma = parts[0];

      if (currentLemma === lemma) {
        // Found match!
        const synsetCountIndex = 2;
        const pCountIndex = 3;
        const pCount = parseInt(parts[pCountIndex], 10);
        const offsetsStartIndex = 4 + pCount + 2;
        const offsets: number[] = [];
        const synsetCount = parseInt(parts[synsetCountIndex], 10);
        
        for (let i = 0; i < synsetCount; i++) {
           offsets.push(parseInt(parts[offsetsStartIndex + i], 10));
        }
        return offsets;

      } else if (currentLemma < lemma) {
        start = currentPos + bytesConsumed;
      } else {
        end = mid;
      }
    }

  } catch (error) {
    console.warn("Lookup failed", error);
  } finally {
    await file.close();
  }

  return [];
}

async function readLine(file: any): Promise<{ line: string, bytesConsumed: number }> {
    const CHUNK_SIZE = 128;
    let line = "";
    let bytesConsumed = 0;
    let buffer = new Uint8Array(CHUNK_SIZE);

    while (true) {
        const bytesRead = await file.read(buffer);
        if (bytesRead === 0) break;

        bytesConsumed += bytesRead;

        let foundNewline = false;
        for (let i = 0; i < bytesRead; i++) {
            if (buffer[i] === 10) { // \n
                line += new TextDecoder().decode(buffer.slice(0, i));
                
                const rewind = bytesRead - i - 1;
                if (rewind > 0) {
                     await file.seek(-rewind, SeekMode.Current);
                     bytesConsumed -= rewind;
                }
                foundNewline = true;
                break;
            }
        }

        if (foundNewline) break;
        
        line += new TextDecoder().decode(buffer.slice(0, bytesRead));
        if (bytesRead < CHUNK_SIZE) break;
    }

    return { line: line.trim(), bytesConsumed };
}
