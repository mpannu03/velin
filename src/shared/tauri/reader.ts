import { PdfInfo } from '../types';
import { RenderedPage } from '@/screens/reader/types';
import { InvokeResult, safeInvoke } from './invoke_result';

export const openPdf = async (
  path: string
): Promise<InvokeResult<string>> => {
  return safeInvoke<string>('open_pdf', { path });
};

export const renderPage = async (
  id: string,
  pageIndex: number,
  targetWidth: number
): Promise<InvokeResult<RenderedPage>> => {
  return safeInvoke<RenderedPage>('render_page', {
    id,
    pageIndex,
    targetWidth,
  });
};

export const closePdf = async (
  id: string
): Promise<InvokeResult<void>> => {
  return safeInvoke('close_pdf', { id });
};

export const fetchPdfInfo = async (
  id: string
): Promise<InvokeResult<PdfInfo>> => {
  return safeInvoke<PdfInfo>('get_pdf_info', { id });
}