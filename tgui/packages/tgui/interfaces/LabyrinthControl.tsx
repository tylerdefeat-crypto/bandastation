import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const SECTOR_TYPE_NAMES: Record<number, string> = {
  0: 'Empty',
  1: 'Corridor',
  2: 'Trap',
  3: 'Forge',
  4: 'Boss',
};

const SECTOR_TYPE_SHORT: Record<number, string> = {
  0: 'TRN',
  1: 'COR',
  2: 'TRAP',
  3: 'FRG',
  4: 'BOSS',
};

const SECTOR_STATE_NAMES: Record<number, string> = {
  0: 'Unloaded',
  1: 'Loaded',
  2: 'Active',
};

const SECTOR_TYPE_COLORS: Record<number, string> = {
  0: '#1a1a1a',
  1: '#2a3a2a',
  2: '#3a1a1a',
  3: '#3a2a1a',
  4: '#2a0a0a',
};

type HazardEntry = {
  ref: string;
  name: string;
  x: number;
  y: number;
  operating: boolean;
  looping: boolean;
  channel: string;
};

type DoorEntry = {
  ref: string;
  name: string;
  x: number;
  y: number;
  is_open: boolean;
};

type Sector = {
  index: number;
  gx: number;
  gy: number;
  state: number;
  sector_type: number;
  rust_level: number;
  has_sync: boolean;
  has_corrosion: boolean;
  has_mappath: boolean;
  hazard_count: number;
  puzzle_name: string;
  channels: string[];
};

type Data = {
  initialized: boolean;
  labyrinth_z: number | null;
  grid_size: number;
  sectors: Sector[];
  selected_index: number | null;
  hazards: HazardEntry[];
  doors: DoorEntry[];
};

export function LabyrinthControl() {
  const { act, data } = useBackend<Data>();
  const { initialized, labyrinth_z, grid_size, sectors, hazards, doors } = data;

  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [pendingRust, setPendingRust] = useState<number>(0);

  const selected = sectors.find((s) => s.index === selectedIndex) ?? null;

  function selectSector(s: Sector) {
    setSelectedIndex(s.index);
    setPendingRust(s.rust_level);
    act('select_sector', { index: s.index });
  }

  return (
    <Window title="Labyrinth Control Panel" width={960} height={680}>
      <Window.Content fitted>
        <Stack fill>
          {/* Left — 5×5 grid */}
          <Stack.Item>
            <Section title="Sector Grid" fill>
              <Box
                style={{
                  display: 'grid',
                  gridTemplateColumns: `repeat(${grid_size}, 52px)`,
                  gridTemplateRows: `repeat(${grid_size}, 52px)`,
                  gap: '4px',
                }}
              >
                {[...Array(grid_size)].map((_, row) =>
                  [...Array(grid_size)].map((__, col) => {
                    const gx = col + 1;
                    const gy = grid_size - row; // top row = highest gy
                    const s = sectors.find((x) => x.gx === gx && x.gy === gy);
                    if (!s) return <Box key={`${gx}-${gy}`} />;
                    const isSelected = s.index === selectedIndex;
                    return (
                      <Box
                        key={s.index}
                        onClick={() => selectSector(s)}
                        style={{
                          background: SECTOR_TYPE_COLORS[s.sector_type] ?? '#111',
                          border: isSelected
                            ? '2px solid #e08020'
                            : s.state === 1
                              ? '1px solid #555'
                              : '1px solid #333',
                          cursor: 'pointer',
                          borderRadius: '3px',
                          display: 'flex',
                          flexDirection: 'column',
                          alignItems: 'center',
                          justifyContent: 'center',
                          padding: '2px',
                          fontSize: '9px',
                          color: '#ccc',
                          userSelect: 'none',
                        }}
                      >
                        <Box bold style={{ fontSize: '10px' }}>
                          {gx},{gy}
                        </Box>
                        <Box
                          bold
                          style={{
                            fontSize: '11px',
                            color:
                              SECTOR_TYPE_COLORS[s.sector_type] === '#1a1a1a'
                                ? '#666'
                                : '#ddd',
                            letterSpacing: '0.5px',
                          }}
                        >
                          {SECTOR_TYPE_SHORT[s.sector_type] ?? '?'}
                        </Box>
                        <Box color={s.state === 1 ? '#8f8' : '#888'}>
                          {SECTOR_STATE_NAMES[s.state]}
                        </Box>
                        {s.hazard_count > 0 && (
                          <Box color="#e88">⚙{s.hazard_count}</Box>
                        )}
                      </Box>
                    );
                  }),
                )}
              </Box>
            </Section>
          </Stack.Item>

          {/* Right — controls */}
          <Stack.Item grow>
            <Stack vertical fill>
              {/* Global controls */}
              <Stack.Item>
                <Section title="Labyrinth">
                  <LabeledList>
                    <LabeledList.Item label="Z-level">
                      {initialized ? (labyrinth_z ?? '?') : '—'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Status">
                      {initialized ? (
                        <Box color="#8f8">Initialized</Box>
                      ) : (
                        <Box color="#f88">Not initialized</Box>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                  <Box mt={1}>
                    <Stack wrap>
                      <Stack.Item>
                        <Button
                          disabled={initialized}
                          icon="play"
                          color="good"
                          onClick={() => act('initialize')}
                        >
                          Initialize
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={!initialized}
                          icon="map"
                          color="good"
                          onClick={() => act('setup_layout')}
                        >
                          Setup Default Layout
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          disabled={!initialized}
                          icon="layer-group"
                          onClick={() => act('load_all')}
                        >
                          Load All Sectors
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Box>
                </Section>
              </Stack.Item>

              {/* Selected sector controls */}
              <Stack.Item>
                {selected ? (
                  <Section
                    title={`Sector ${selected.gx},${selected.gy} — ${SECTOR_TYPE_NAMES[selected.sector_type]}`}
                  >
                    <LabeledList>
                      <LabeledList.Item label="State">
                        <Box color={selected.state === 1 ? '#8f8' : '#888'}>
                          {SECTOR_STATE_NAMES[selected.state]}
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Puzzle">
                        {selected.puzzle_name ? (
                          <Box color="#8cf">{selected.puzzle_name}</Box>
                        ) : (
                          <Box color="#888">None</Box>
                        )}
                      </LabeledList.Item>
                      <LabeledList.Item label="Rust Level">
                        <Slider
                          value={pendingRust}
                          minValue={0}
                          maxValue={100}
                          step={5}
                          stepPixelSize={4}
                          format={(v) => `${v}%`}
                          onChange={(_e, value) => setPendingRust(value)}
                        />
                      </LabeledList.Item>
                    </LabeledList>

                    <Box mt={1}>
                      <Stack wrap>
                        <Stack.Item>
                          <Button
                            disabled={!initialized || selected.state !== 0}
                            icon="file-import"
                            onClick={() =>
                              act('load_sector', { index: selected.index })
                            }
                          >
                            Load
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="crosshairs"
                            onClick={() =>
                              act('goto_sector', { index: selected.index })
                            }
                          >
                            Go To
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selected.has_sync}
                            icon="bolt"
                            color="orange"
                            onClick={() =>
                              act('pulse_pistons', { index: selected.index })
                            }
                          >
                            Pulse
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selected.has_sync}
                            icon="repeat"
                            color="orange"
                            onClick={() =>
                              act('loop_traps', { index: selected.index })
                            }
                          >
                            Loop All
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selected.has_sync}
                            icon="stop"
                            color="bad"
                            onClick={() =>
                              act('stop_traps', { index: selected.index })
                            }
                          >
                            Stop All
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="sliders-h"
                            color="caution"
                            onClick={() =>
                              act('set_rust', {
                                index: selected.index,
                                level: pendingRust,
                              })
                            }
                          >
                            Apply Rust ({pendingRust}%)
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            disabled={!selected.has_corrosion}
                            icon="wind"
                            color="bad"
                            onClick={() =>
                              act('force_corrosion', { index: selected.index })
                            }
                          >
                            Corrosion
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  </Section>
                ) : (
                  <Section title="Sector Details">
                    <Box color="#666" italic>
                      Click a sector on the grid to select it.
                    </Box>
                  </Section>
                )}
              </Stack.Item>

              {/* Object inspector: individual hazards & doors */}
              {selected && (
                <Stack.Item grow>
                  <Section
                    title={`Zone Objects — ${hazards.length} hazards, ${doors.length} doors`}
                    fill
                    scrollable
                  >
                    {hazards.length === 0 && doors.length === 0 && (
                      <Box color="#666" italic>
                        No hazards or doors mapped in this zone.
                      </Box>
                    )}

                    {hazards.map((h) => (
                      <Box
                        key={h.ref}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          padding: '2px 0',
                          borderBottom: '1px solid #2a2a2a',
                        }}
                      >
                        <Box>
                          <Box bold color={h.looping ? '#e88' : '#ccc'}>
                            {h.name} {h.looping ? '↻' : ''}
                            {h.operating ? ' ●' : ''}
                          </Box>
                          <Box style={{ fontSize: '9px' }} color="#888">
                            ({h.x},{h.y})
                            {h.channel ? ` · ${h.channel}` : ''}
                          </Box>
                        </Box>
                        <Box>
                          <Button
                            compact
                            icon="bolt"
                            color="orange"
                            onClick={() =>
                              act('trigger_hazard', { ref: h.ref })
                            }
                          >
                            Fire
                          </Button>
                          <Button
                            compact
                            icon="repeat"
                            onClick={() => act('loop_hazard', { ref: h.ref })}
                          />
                          <Button
                            compact
                            icon="stop"
                            color="bad"
                            onClick={() => act('stop_hazard', { ref: h.ref })}
                          />
                        </Box>
                      </Box>
                    ))}

                    {doors.map((d) => (
                      <Box
                        key={d.ref}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          padding: '2px 0',
                          borderBottom: '1px solid #2a2a2a',
                        }}
                      >
                        <Box>
                          <Box bold color="#8cf">
                            {d.name}
                          </Box>
                          <Box style={{ fontSize: '9px' }} color="#888">
                            ({d.x},{d.y}) ·{' '}
                            {d.is_open ? (
                              <Box as="span" color="#8f8">
                                OPEN
                              </Box>
                            ) : (
                              <Box as="span" color="#f88">
                                SHUT
                              </Box>
                            )}
                          </Box>
                        </Box>
                        <Button
                          compact
                          icon={d.is_open ? 'lock' : 'lock-open'}
                          color={d.is_open ? 'bad' : 'good'}
                          onClick={() => act('toggle_door', { ref: d.ref })}
                        >
                          {d.is_open ? 'Close' : 'Open'}
                        </Button>
                      </Box>
                    ))}
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
