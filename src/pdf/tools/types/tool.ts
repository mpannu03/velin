import { LucideIcon } from "lucide-react";

export interface ToolInfo {
  id: ToolId;
  title: string;
  description: string;
  icon: LucideIcon;
  color: string;
  category: ToolCategory;
}

export type ToolCategory = "edit" | "convert" | "optimize" | "security";

export type ToolId =
  | "merge"
  | "split"
  | "extract"
  | "compress"
  | "pdf-to-image"
  | "image-to-pdf"
  | "rotate"
  | "protect"
  | "unlock"
  | "watermark";
