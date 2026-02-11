import { RenderedPage } from "@/screens";

export type DocumentMeta = {
  filePath: string;
  title: string;
  preview: RenderedPage | undefined;
  starred: boolean;
  lastOpened: Date;
  currentPage: number;
  pagesCount: number;
  openedCount: number;
}