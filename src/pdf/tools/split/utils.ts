export function generateEachPageSelection(totalPages: number): string {
  return Array.from({ length: totalPages }, (_, i) => i + 1).join(",");
}

export function generateFixedSizeSplit(
  totalPages: number,
  size: number,
): string {
  const parts: string[] = [];

  for (let start = 1; start <= totalPages; start += size) {
    const end = Math.min(start + size - 1, totalPages);
    parts.push(`${start}-${end}`);
  }

  return parts.join(",");
}
