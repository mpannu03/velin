import { HomeScreen, ModifyScreen, ReaderScreen, ToolsScreen } from "../screens";
import { Screen } from './';

export const SCREEN_COMPONENTS: Record<Screen['name'], React.FC> = {
  home: HomeScreen,
  reader: ReaderScreen,
  modify: ModifyScreen,
  tools: ToolsScreen,
};