import { invoke } from '@tauri-apps/api/core';
import { PdfInfo } from '../types';
import { RenderedPage } from '@/screens/reader/types';

export const openPdf = async (path: string): Promise<string> => {
  return invoke<string>('open_pdf', { path });
};

export const renderPage = async (
  id: string,
  pageIndex: number,
  scale: number
): Promise<RenderedPage> => {
  return invoke('render_page', {
    id,
    pageIndex,
    scale,
  });
};

export const closePdf = async (
  id: string
): Promise<void> => {
  return invoke('close_pdf', { id });
};

export const fetchPdfInfo = async (
  id: string
): Promise<PdfInfo> => {
  return invoke('get_pdf_info', { id });
}