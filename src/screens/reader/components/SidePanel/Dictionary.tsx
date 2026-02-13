import { ActionIcon, Badge, Card, Group, Input, ScrollArea, Stack, Text } from "@mantine/core";
import { JSX } from "react";
import { useDictionaryStore } from "../../stores/dictionary.store";
import { SearchIcon, X } from "lucide-react";
import { SearchResult, Synset } from "@/shared/services/dictionary";

export function Dictionary({id}: {id: string}): JSX.Element {
  const { query, results, isSearching, error, setQuery, search, clearResults } = useDictionaryStore();

  const handleSearch = () => {
    if (query !== "") {
      try {
        search(id, query);
      } catch (error) {
        console.error(error);
      }
    }
  };

  return(
    <Stack h="100%">
      <Group justify="space-between">
        <Text fw={700} tt="uppercase" size="xs" c="dimmed">
        Dictionary
      </Text>
      <ActionIcon variant="subtle" size="sm" onClick={() => clearResults()}>
        <X size={16} />
      </ActionIcon>
      </Group>

      <Group gap="xs">
        <Input
          placeholder="Search dictionary"
          value={query}
          onChange={(e) => setQuery(e.currentTarget.value)}
          style={{ flex: 1 }}
          leftSection={<SearchIcon size={16} />}
        />
        <ActionIcon variant="filled" onClick={handleSearch} loading={isSearching}>
          <SearchIcon size={18} />
        </ActionIcon>
      </Group>
      {error && <Text c="red">{error}</Text>}
      {results[id] && <SearchResultsView result={results[id]} />}
    </Stack>
  );
}

type Props = {
  result: SearchResult | null;
};

export function SearchResultsView({ result }: Props) {
  if (!result) return null;

  const sections = [
    { key: "noun", label: "Noun", data: result.noun },
    { key: "verb", label: "Verb", data: result.verb },
    { key: "adj", label: "Adjective", data: result.adj },
    { key: "adv", label: "Adverb", data: result.adv },
  ] as const;

  return (
    <ScrollArea>
      <Stack mt="md" gap="lg">
        {sections.map(({ key, label, data }) =>
          data.length > 0 ? (
            <Stack key={key} gap="sm">
              <Text fw={700} tt="uppercase" size="sm" c="dimmed">
                {label}
              </Text>

              {data.map((synset, index) => (
                <SynsetView key={index} synset={synset} index={index} />
              ))}
            </Stack>
          ) : null
        )}
      </Stack>
    </ScrollArea>
  );
}

export function SynsetView({ synset, index }: { synset: Synset, index: number }) {
  return (
    <Card key={index} withBorder radius="md" p="md">
      <Stack gap="xs">
        {/* Definition */}
        <Text size="sm">{synset.definition}</Text>

        {/* Synonyms */}
        {synset.synonyms.length > 0 && (
          <Stack gap={4}>
            <Text size="xs" fw={600} c="dimmed">
              Synonyms
            </Text>
            <Stack gap={4}>
              <div>
                {synset.synonyms.map((s) => (
                  <Badge
                    key={s}
                    variant="light"
                    size="sm"
                    mr={6}
                    mb={6}
                  >
                    {s}
                  </Badge>
                ))}
              </div>
            </Stack>
          </Stack>
        )}

        {/* Examples */}
        {synset.examples && synset.examples.length > 0 && (
          <Stack gap={4}>
            <Text size="xs" fw={600} c="dimmed">
              Examples
            </Text>
            {synset.examples.map((ex, i) => (
              <Text key={i} size="xs" c="dimmed" fs="italic">
                “{ex}”
              </Text>
            ))}
          </Stack>
        )}
      </Stack>
    </Card>
  );
}