import { HomeScreen, ModifyScreen, ToolsScreen, ReaderPlaceholder } from '../../screens';
import { Screen } from '@/app/types';

export const SCREEN_COMPONENTS: Record<Screen['name'], React.FC> = {
  home: HomeScreen,
  reader: ReaderPlaceholder,
  modify: ModifyScreen,
  tools: ToolsScreen,
};