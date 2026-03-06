import { IconType } from "react-icons";

export interface ToolInfo {
  id: string;
  title: string;
  description: string;
  icon: IconType;
  color: string;
  category: "edit" | "convert" | "optimize" | "security";
}
