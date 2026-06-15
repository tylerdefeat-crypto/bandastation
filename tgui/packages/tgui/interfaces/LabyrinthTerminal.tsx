import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  prompt: string;
  solved: boolean;
};

export function LabyrinthTerminal() {
  const { act, data } = useBackend<Data>();
  const { prompt, solved } = data;

  const [code, setCode] = useState<string>('');

  return (
    <Window title="Corroded Terminal" width={420} height={240}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill title="Prompt">
              <Box
                style={{
                  fontFamily: 'monospace',
                  fontSize: '14px',
                  color: solved ? '#8f8' : '#e0c060',
                  letterSpacing: '1px',
                }}
              >
                {solved ? 'ACCESS GRANTED.' : prompt}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    fluid
                    value={code}
                    disabled={solved}
                    placeholder="enter code…"
                    onChange={(value) => setCode(value)}
                    onEnter={(value) => {
                      act('submit', { code: value });
                      setCode('');
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="arrow-right"
                    color="good"
                    disabled={solved || !code}
                    onClick={() => {
                      act('submit', { code });
                      setCode('');
                    }}
                  >
                    Submit
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
