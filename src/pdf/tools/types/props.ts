export type ToolPreferencesProps = {
  onBackPressed: () => void;
};

export type PageSelectionInput = {
  file: string;
  selection: string | null;
};

export type ProtectInput = {
  inputPath: string;
  outputPath: string;
  password: string;
  allowPrinting: boolean;
  allowAssembly: boolean;
  allowCommenting: boolean;
  allowCopying: boolean;
};
