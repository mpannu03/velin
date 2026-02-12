import { ActionIcon, Divider, Group, Text } from "@mantine/core";
import { JSX, useEffect } from "react";
import { PdfDocument } from "@/shared/types";
import { FiPlus, FiX } from "react-icons/fi";
import { useHover } from "@mantine/hooks";
import { useDocumentsStore } from "@/app/store/documents.store";
import { closePdf, openPdf } from "@/screens/reader";
import { useScreenState } from "@/app/screenRouter";
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from "@dnd-kit/core";
import {
  SortableContext,
  horizontalListSortingStrategy,
  useSortable,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

export function PdfTabs(): JSX.Element {
  const docs = useDocumentsStore((s) => s.documents);
  const order = useDocumentsStore((s) => s.documentOrder);
  const reorder = useDocumentsStore((s) => s.reorder);
  const router = useScreenState();

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5,
      },
    })
  );

  useEffect(() => {
    if (Object.keys(docs).length == 0 && router.screen.name == "reader") {
      router.goHome();
    }
  }, [docs]);

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      reorder(active.id as string, over.id as string);
    }
  };

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragEnd={handleDragEnd}
    >
      <Group gap={0} h="100%">
        <SortableContext
          items={order}
          strategy={horizontalListSortingStrategy}
        >
          {order.map((id) => {
            const doc = docs[id];
            if (!doc) return null;
            return (
              <Group key={id} gap={0} h="100%">
                <SortableTab tab={doc} />
                <Divider orientation="vertical" my={4} />
              </Group>
            );
          })}
        </SortableContext>
        <ActionIcon
          w={36}
          h={36}
          variant="subtle"
          onClick={() => openPdf()}
        >
          <FiPlus size={18} />
        </ActionIcon>
      </Group>
    </DndContext>
  );
}

type TabProps = {
  tab: PdfDocument;
};

function SortableTab({ tab }: TabProps): JSX.Element {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: tab.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    zIndex: isDragging ? 100 : undefined,
    opacity: isDragging ? 0.5 : 1,
    height: "100%",
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners}>
      <Tab tab={tab} />
    </div>
  );
}

function Tab({ tab }: TabProps): JSX.Element {
  const { hovered, ref } = useHover();
  const pdfStore = useDocumentsStore();
  const selectedTab = useDocumentsStore((s) => s.activeDocumentId);
  const router = useScreenState();

  return (
    <Group
      ref={ref}
      bg={
        selectedTab === tab.id
          ? "var(--mantine-color-body)"
          : hovered
            ? "var(--mantine-primary-color-light-hover)"
            : "var(--mantine-color-disabled)"
      }
      w={200}
      gap={0}
      h="100%"
      justify="space-between"
      align="center"
      pl="sm"
      onClick={() => {
        pdfStore.setActive(tab.id);
        router.openReader();
      }}
      style={{
        cursor: "default",
        userSelect: "none",
        borderTopLeftRadius: "var(--mantine-radius-md)",
        borderTopRightRadius: "var(--mantine-radius-md)",
      }}
    >
      <Text
        truncate
        size="xs"
        fw={500}
        c="dark.7"
        style={{
          flex: 1,
          minWidth: 0,
        }}
      >
        {tab.title}
      </Text>
      <ActionIcon
        variant="subtle"
        onClick={(e) => {
          e.stopPropagation();
          closePdf(tab.id);
        }}
        onPointerDown={(e) => {
          e.stopPropagation();
        }}
      >
        <FiX />
      </ActionIcon>
    </Group>
  );
}
