import { useEffect } from "react";
import { ActionIcon, Box, Group, Input, Stack, Text, ScrollArea } from "@mantine/core";
import { Search as SearchIcon, ChevronLeft, ChevronRight, X } from "lucide-react";
import { useSearchStore, usePdfViewerStore } from "../../stores";

export function Search({ id }: { id: string }) {
  const { query, setQuery, search, results, currentIndex, nextResult, prevResult, isSearching, clearResult } = useSearchStore();
  const gotoPage = usePdfViewerStore(s => s.gotoPage);
  const result = results[id] ?? [];

  const handleSearch = () => {
    search(id, query);
  };

  const currentHit = result[currentIndex];

  useEffect(() => {
     if (currentHit) {
         gotoPage(id, currentHit.page);
     }
  }, [currentIndex, currentHit, id, gotoPage]);

  return (
    <Stack h="100%" gap="md">
      <Group justify="space-between">
        <Text fw={700} tt="uppercase" size="xs" c="dimmed">
          Search
        </Text>
        <ActionIcon variant="subtle" size="sm" onClick={() => clearResult(id)}>
           <X size={16} />
        </ActionIcon>
      </Group>

      <Group gap="xs">
        <Input
          placeholder="Search in document..."
          value={query}
          onChange={(e) => setQuery(e.currentTarget.value)}
          onKeyDown={(e) => e.key === "Enter" && handleSearch()}
          style={{ flex: 1 }}
          leftSection={<SearchIcon size={16} />}
        />
        <ActionIcon variant="filled" onClick={handleSearch} loading={isSearching}>
          <SearchIcon size={18} />
        </ActionIcon>
      </Group>

      {result.length > 0 && (
        <Group justify="center" gap="xs">
          <ActionIcon variant="light" onClick={() => prevResult(id)}>
            <ChevronLeft size={18} />
          </ActionIcon>
          <Text size="sm">
            {currentIndex + 1} of {result.length}
          </Text>
          <ActionIcon variant="light" onClick={() => nextResult(id)}>
            <ChevronRight size={18} />
          </ActionIcon>
        </Group>
      )}

      <ScrollArea style={{ flex: 1 }}>
        <Stack gap="xs">
          {result.map((hit, index) => (
            <Box
              key={index}
              p="xs"
              style={{
                cursor: "pointer",
                backgroundColor: index === currentIndex ? "var(--mantine-color-blue-light)" : "transparent",
                borderRadius: "var(--mantine-radius-sm)",
              }}
              onClick={() => {
                  useSearchStore.setState({ currentIndex: index });
              }}
            >
              <Text size="sm" fw={500}>Page {hit.page + 1}</Text>
              {/* Future: Add preview snippet here */}
            </Box>
          ))}
          {result.length === 0 && !isSearching && query && (
             <Text size="sm" c="dimmed" ta="center" mt="xl">No results found</Text>
          )}
        </Stack>
      </ScrollArea>
    </Stack>
  );
}
