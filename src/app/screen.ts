export type Screen =
  | { name: 'home' }
  | { name: 'editor'; filePath: string }
  | { name: 'tools' };