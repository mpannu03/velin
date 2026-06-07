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
  allowHighQualityPrinting: boolean;
  allowModifying: boolean;
  allowCopying: boolean;
  allowAnnotating: boolean;
  allowFormFilling: boolean;
  allowAssembly: boolean;
};
