export type DocumentMeta = {
  filePath: string;
  title: string;
  previewPath: string | undefined;
  starred: boolean;
  lastOpened: number;
  currentPage: number;
  pagesCount: number;
  openedCount: number;
}

export type DocumentPatch = Partial<Omit<DocumentMeta, "filePath">>;