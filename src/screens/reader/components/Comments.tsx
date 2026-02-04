import { Stack, Text } from "@mantine/core";

export function Comments({ id }: { id: string }) {
  console.log(id);
  return (
    <Stack gap="sm" h="100%">
      <Text fw={700} tt="uppercase" size="xs" c="dimmed">
        Comments
      </Text>
      <Text size="sm" c="dimmed" fs="italic">
        No comments yet.
      </Text>
    </Stack>
  );
}