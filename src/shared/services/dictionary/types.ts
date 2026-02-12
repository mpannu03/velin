export type PartOfSpeech = 'noun' | 'verb' | 'adj' | 'adv';

export interface Synset {
  offset: number;
  pos: PartOfSpeech;
  synonyms: string[];
  gloss: string;
}
