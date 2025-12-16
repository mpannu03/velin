export type Screen =
  | { name: 'home' }
  | { name: 'reader'; filePath: string }
  | { name: 'modify'; filePath: string}
  | { name: 'tools' };