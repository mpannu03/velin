export type PartOfSpeech = 'noun' | 'verb' | 'adj' | 'adv';

export type Synset = {
  synonyms: string[];
  definition: string;
  examples?: string[];
  pointers: { symbol: string; offset: string; pos: string }[];
};

export type SearchResult = {
  noun: Synset[];
  verb: Synset[];
  adj: Synset[];
  adv: Synset[];
}