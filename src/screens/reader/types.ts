export type RenderedPage = {
  width: number
  height: number
  pixels: number[] // comes from Rust Vec<u8>
}
