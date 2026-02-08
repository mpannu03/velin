import { ActionIcon, Box, Group, Input, Stack, Text, ScrollArea, Loader } from "@mantine/core";
import { Search as SearchIcon, ChevronLeft, ChevronRight, X } from "lucide-react";
import { useSearchStore } from "../stores/search.store";
import { usePdfViewerStore } from "../stores/pdfViewer.store";
import { useEffect } from "react";

export function Search({ id }: { id: string }) {
  const { query, setQuery, search, results, currentIndex, nextResult, prevResult, isSearching, clearResults } = useSearchStore();
  const gotoPage = usePdfViewerStore(s => s.gotoPage);

  const handleSearch = () => {
    search(id, query);
  };

  const currentHit = results[currentIndex];

  useEffect(() => {
     if (currentHit) {
         gotoPage(id, currentHit.page);
     }
  }, [currentIndex, currentHit, id, gotoPage]);

  return (
    <Stack h="100%" gap="md">
      <Group justify="space-between">
        <Text fw={700}>Search</Text>
        <ActionIcon variant="subtle" size="sm" onClick={() => clearResults()}>
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
          rightSection={isSearching ? <Loader size="xs" /> : null}
        />
        <ActionIcon variant="filled" onClick={handleSearch} loading={isSearching}>
          <SearchIcon size={18} />
        </ActionIcon>
      </Group>

      {results.length > 0 && (
        <Group justify="center" gap="xs">
          <ActionIcon variant="light" onClick={prevResult}>
            <ChevronLeft size={18} />
          </ActionIcon>
          <Text size="sm">
            {currentIndex + 1} of {results.length}
          </Text>
          <ActionIcon variant="light" onClick={nextResult}>
            <ChevronRight size={18} />
          </ActionIcon>
        </Group>
      )}

      <ScrollArea style={{ flex: 1 }}>
        <Stack gap="xs">
          {results.map((hit, index) => (
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
          {results.length === 0 && !isSearching && query && (
             <Text size="sm" c="dimmed" ta="center" mt="xl">No results found</Text>
          )}
        </Stack>
      </ScrollArea>
    </Stack>
  );
}
