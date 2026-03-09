import {
  Paper,
  Stack,
  Text,
  PasswordInput,
  Checkbox,
  Divider,
  Alert,
} from "@mantine/core";
import { JSX, useState } from "react";
import { FiShield, FiAlertTriangle } from "react-icons/fi";
import { FileSelection } from "../components";

export function Security({
  mode,
}: {
  mode: "protect" | "unlock";
}): JSX.Element {
  const [password, setPassword] = useState("");

  return (
    <Stack gap="lg">
      <FileSelection onSelect={() => {}} />

      <Paper withBorder p="md" radius="md">
        <Stack gap="md">
          <Text fw={600}>
            {mode === "protect" ? "Security Settings" : "Unlock Settings"}
          </Text>
          <PasswordInput
            label={mode === "protect" ? "New Password" : "Current Password"}
            placeholder="Enter password"
            value={password}
            onChange={(e) => setPassword(e.currentTarget.value)}
            description={
              mode === "protect"
                ? "Choose a strong password to encrypt the document."
                : "Enter the password to remove protection."
            }
            radius="md"
          />

          {mode === "protect" && (
            <>
              <Divider label="Permissions" labelPosition="center" />
              <Stack gap="xs">
                <Checkbox label="Allow Printing" defaultChecked />
                <Checkbox label="Allow Document Assembly" defaultChecked />
                <Checkbox label="Allow Commenting" defaultChecked />
                <Checkbox label="Allow Content Copying" />
              </Stack>

              <Alert
                icon={<FiShield size={16} />}
                title="Encryption Level"
                color="green"
                variant="light"
              >
                Document will be encrypted with AES-256 bit security standard.
              </Alert>
            </>
          )}

          {mode === "unlock" && (
            <Alert
              icon={<FiAlertTriangle size={16} />}
              title="Warning"
              color="red"
              variant="light"
            >
              This will remove all security restrictions and passwords from the
              document.
            </Alert>
          )}
        </Stack>
      </Paper>
    </Stack>
  );
}
