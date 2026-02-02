import { ActionIcon, Paper, Stack, Text, Tooltip } from '@mantine/core';
import { useHotkeys } from '@mantine/hooks';
import { usePdfViewerStore } from '../stores/usePdfViewerStore';
import {
    IoRemoveOutline,
    IoAddOutline,
    IoHandRightOutline,
    IoNavigateOutline,
    IoChatbubbleOutline,
    IoBookmarkOutline
} from "react-icons/io5";

type ReaderToolbarProps = {
    documentId: string;
};

export function ReaderToolbar({ documentId }: ReaderToolbarProps) {
    const state = usePdfViewerStore(s => s.getState(documentId));
    const setScale = usePdfViewerStore(s => s.setScale);
    const setTool = usePdfViewerStore(s => s.setTool);
    const setSidebar = usePdfViewerStore(s => s.setSidebar);

    const ZOOM_STEPS = [0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0];

    const zoomIn = () => {
        const nextStep = ZOOM_STEPS.find(s => s > state.scale) || 5.0;
        setScale(documentId, nextStep);
    };

    const zoomOut = () => {
        const prevStep = [...ZOOM_STEPS].reverse().find(s => s < state.scale) || 0.1;
        setScale(documentId, prevStep);
    };

    const resetZoom = () => setScale(documentId, 1.0);

    useHotkeys([
        ['mod+equal', zoomIn],
        ['mod+plus', zoomIn],
        ['mod+minus', zoomOut],
        ['mod+0', resetZoom],
    ]);

    return (
        <Paper
            shadow="xs"
            p="xs"
            withBorder
            style={{
                width: 50,
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'space-between',
                backgroundColor: 'var(--mantine-color-body)',
                borderLeft: '1px solid var(--mantine-color-gray-3)',
            }}
        >
            <Stack gap="xs" align="center">
                <Tooltip label="Selection Tool" position="left">
                    <ActionIcon
                        variant={state.tool === 'cursor' ? 'filled' : 'light'}
                        onClick={() => setTool(documentId, 'cursor')}
                        size="lg"
                    >
                        <IoNavigateOutline size={20} />
                    </ActionIcon>
                </Tooltip>
                <Tooltip label="Hand Tool" position="left">
                    <ActionIcon
                        variant={state.tool === 'hand' ? 'filled' : 'light'}
                        onClick={() => setTool(documentId, 'hand')}
                        size="lg"
                    >
                        <IoHandRightOutline size={20} />
                    </ActionIcon>
                </Tooltip>
            </Stack>

            <Stack align="center" gap="xs">
                <Tooltip label="Zoom In (Ctrl++)" position="left">
                    <ActionIcon variant="light" onClick={zoomIn} size="lg">
                        <IoAddOutline size={20} />
                    </ActionIcon>
                </Tooltip>

                <Tooltip label="Reset Zoom (Ctrl+0)" position="left">
                    <Text 
                        size="xs" 
                        fw={700} 
                        style={{ fontSize: 11, textAlign: 'center', cursor: 'pointer' }}
                        onClick={resetZoom}
                    >
                        {Math.round(state.scale * 100)}%
                    </Text>
                </Tooltip>

                <Tooltip label="Zoom Out (Ctrl+-)" position="left">
                    <ActionIcon variant="light" onClick={zoomOut} size="lg">
                        <IoRemoveOutline size={20} />
                    </ActionIcon>
                </Tooltip>
            </Stack>

            <Stack gap="xs" align="center">
                <Tooltip label="Comments" position="left">
                    <ActionIcon
                        variant={state.sidebar === 'comments' ? 'filled' : 'light'}
                        size="lg"
                        onClick={() => setSidebar(documentId, state.sidebar === 'comments' ? 'none' : 'comments')}
                    >
                        <IoChatbubbleOutline size={20} />
                    </ActionIcon>
                </Tooltip>
                <Tooltip label="Bookmarks" position="left">
                    <ActionIcon
                        variant={state.sidebar === 'bookmarks' ? 'filled' : 'light'}
                        size="lg"
                        onClick={() => setSidebar(documentId, state.sidebar === 'bookmarks' ? 'none' : 'bookmarks')}
                    >
                        <IoBookmarkOutline size={20} />
                    </ActionIcon>
                </Tooltip>
            </Stack>
        </Paper>
    );
}
