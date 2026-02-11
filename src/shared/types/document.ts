import { RenderedPage } from "@/screens";

export type DocumentMeta = {
  id: string;
  filePath: string;
  title: string;
  preview: RenderedPage;
  starred: boolean;
  lastOpened: Date;
  pagesCount: number;
  totalPages: number;
  openedCount: number;
}