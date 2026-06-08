export type RenderedPage = {
  width: number;
  height: number;
  /** ImageBitmap for GPU-resident rendering, falls back to Uint8Array for backward compat */
  pixels: ImageBitmap | Uint8Array;
};

export type RenderedTile = {
  x: number;
  y: number;
  width: number;
  height: number;
  /** ImageBitmap is GPU-resident; Uint8Array for CPU fallback */
  pixels: ImageBitmap | Uint8Array;
};
