import { ActionIcon, Paper, Stack, Tooltip } from "@mantine/core";
import { JSX } from "react";
import { usePdfViewerStore, ViewerTool } from "../stores";
import { MousePointer, Hand } from "lucide-react";

type ToolsPanelProps = {
	documentId: string;
};

export function ToolsPanel({ documentId }: ToolsPanelProps): JSX.Element {
	const state = usePdfViewerStore(s => s.getState(documentId));
	const setTool = usePdfViewerStore.getState().setTool;

	return (
		<Paper
			shadow="xs"
      p="xs"
			m="xs"
			h="fit-content"
			w="50"
      withBorder
      style={{
        display: 'flex',
        flexDirection: 'column',
      }}
		>
			<Stack gap="xs" align="center">
        <Tooltip label="Selection Tool" position="left">
          <ActionIcon
            variant={state.tool === ViewerTool.Cursor ? 'filled' : 'light'}
            onClick={() => setTool(documentId, ViewerTool.Cursor)}
            size="lg"
          >
            <MousePointer size={20} />
          </ActionIcon>
        </Tooltip>
        <Tooltip label="Hand Tool" position="left">
          <ActionIcon
            variant={state.tool === ViewerTool.Hand ? 'filled' : 'light'}
            onClick={() => setTool(documentId, ViewerTool.Hand)}
            size="lg"
          >
            <Hand size={20} />
          </ActionIcon>
        </Tooltip>
      </Stack>
		</Paper>
	);
}