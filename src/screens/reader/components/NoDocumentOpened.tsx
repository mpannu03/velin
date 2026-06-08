import { Center, Stack, ThemeIcon, Title, Text, Button } from "@mantine/core";
import { JSX } from "react";
import { FileText, Plus } from "lucide-react";
import { openPdf } from "@/pdf/reader/renderer";
import { useTranslation } from "react-i18next";

export function NoDocumentOpened(): JSX.Element {
  const { t } = useTranslation(["common", "reader"]);

  return (
    <Center
      style={{
        width: "100%",
        flex: 1,
      }}
    >
      <Stack align="center" gap="xl">
        <ThemeIcon
          size={120}
          radius={100}
          variant="light"
          color="var(--mantine-primary-color-filled)"
          style={{
            boxShadow: "0 10px 30px rgba(0,0,0,0.05)",
          }}
        >
          <FileText size={60} />
        </ThemeIcon>

        <Stack gap="xs" align="center">
          <Title order={2} fw={800} c="brightness(1.2)" ta="center">
            {t("reader:empty.title")}
          </Title>
          <Text c="dimmed" size="lg" maw={320} ta="center" fw={500}>
            {t("reader:empty.description")}
          </Text>
        </Stack>

        <Button
          size="lg"
          radius="xl"
          px={40}
          variant="filled"
          onClick={() => openPdf()}
          leftSection={<Plus size={20} />}
        >
          {t("common:file.open")}
        </Button>
      </Stack>
    </Center>
  );
}
