import { ToolInfo } from "../../types";

export * from "./CompressPreferences";
export * from "./EditPreferences";
export * from "./FileSelection";
export * from "./MergePreferences";
export * from "./SecurityPreferences";
export * from "./SplitPreferences";
export * from "./ImagePreferences";
export * from "./preferences";
export * from "./prefsRegistry";

export type ToolDefinition = {
  info: ToolInfo;
  Preferences: React.ComponentType<ToolPreferencesProps>;
};

export type ToolPreferencesProps = {
  setAction: (fn: () => void) => void;
};
