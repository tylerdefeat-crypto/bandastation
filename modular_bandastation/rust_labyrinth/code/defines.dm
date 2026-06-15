// ============================================================
// Rust-Forged Labyrinth — defines
// ============================================================

// Grid dimensions
/// Number of sectors per axis (grid is LABYRINTH_GRID_SIZE × LABYRINTH_GRID_SIZE)
#define LABYRINTH_GRID_SIZE 5
/// Width of a single sector in tiles
#define LABYRINTH_SECTOR_WIDTH 46
/// Height of a single sector in tiles
#define LABYRINTH_SECTOR_HEIGHT 46

/// Flat-list index helper: sectors list is row-major, 1-based
#define LABYRINTH_GRID_INDEX(gx, gy) (((gy) - 1) * LABYRINTH_GRID_SIZE + (gx))

// Sector types
#define LABYRINTH_SECTOR_EMPTY    0
#define LABYRINTH_SECTOR_CORRIDOR 1
#define LABYRINTH_SECTOR_TRAP     2
#define LABYRINTH_SECTOR_FORGE    3
#define LABYRINTH_SECTOR_BOSS     4

// Sector load states
#define LABYRINTH_SECTOR_UNLOADED 0
#define LABYRINTH_SECTOR_LOADED   1
#define LABYRINTH_SECTOR_ACTIVE   2

// Rust level thresholds (0–100)
#define LABYRINTH_RUST_MILD   25
#define LABYRINTH_RUST_HEAVY  60
#define LABYRINTH_RUST_LETHAL 90

// Piston states
#define PISTON_RETRACTED 0
#define PISTON_EXTENDED  1

// Piston timing (deciseconds)
#define PISTON_WARN_TIME    15  // 1.5s — warning groan before extend
#define PISTON_EXTEND_TIME  20  // 2.0s — time to fully extend 1 tile
#define PISTON_HOLD_TIME     8  // 0.8s — dwell at full extension
#define PISTON_RETRACT_TIME 12  // 1.2s — faster retract

// Piston damage
#define PISTON_DAMAGE_GLANCING 20  // mob escapes but still gets clipped
#define PISTON_DAMAGE_CRUSH    55  // mob pinned against a wall

// Corrosion timing (deciseconds)
#define CORROSION_TICK_INTERVAL     100  // 10 s between sweeps
// Item integrity loss per corrosion sweep
#define CORROSION_DAMAGE_MILD         1
#define CORROSION_DAMAGE_HEAVY        4
#define CORROSION_DAMAGE_LETHAL      10
// Mob brute damage per corrosion sweep
#define CORROSION_MOB_DAMAGE_HEAVY    2
#define CORROSION_MOB_DAMAGE_LETHAL   8
/// Percent chance (per sweep) that a mob receives corrosion effects
#define CORROSION_MOB_PROC_CHANCE    40

// Piston trap module orientation
#define PISTON_ORIENT_EW 1  // поршни двигаются вдоль оси X (EAST/WEST)
#define PISTON_ORIENT_NS 2  // поршни двигаются вдоль оси Y (NORTH/SOUTH)

// Signals emitted by /datum/rust_grid_manager
/// (datum/rust_sector/S) — fired after a sector finishes loading its DMM
#define COMSIG_LABYRINTH_SECTOR_LOADED  "labyrinth_sector_loaded"
/// () — fired when Sync_Controller triggers a global piston pulse
#define COMSIG_LABYRINTH_PISTON_SYNC    "labyrinth_piston_sync"

// ============================================================
// Hazards (modular trap framework — Phase F)
// ============================================================

/// Default interval between auto-loop cycles (deciseconds)
#define HAZARD_LOOP_INTERVAL 50  // 5 s

// Reaction of a hazard when its wiring channel fires
#define HAZARD_ACTION_TRIGGER     1  // run one cycle
#define HAZARD_ACTION_START_LOOP  2  // begin continuous looping
#define HAZARD_ACTION_STOP_LOOP   3  // stop looping
#define HAZARD_ACTION_TOGGLE_LOOP 4  // invert loop state

// --- Floor spikes timing (deciseconds) ---
#define SPIKES_WARN_TIME    12  // 1.2 s telegraph before they shoot up
#define SPIKES_UP_TIME       4  // 0.4 s to fully extend
#define SPIKES_HOLD_TIME    10  // 1.0 s dwell while extended
#define SPIKES_DOWN_TIME     8  // 0.8 s retract
#define SPIKES_DAMAGE       45  // brute on impale

// --- Wall saw timing (deciseconds) ---
#define WALLSAW_WARN_TIME   14  // 1.4 s spin-up groan
#define WALLSAW_OUT_TIME    16  // 1.6 s to slide out fully
#define WALLSAW_HOLD_TIME    6  // 0.6 s at full reach
#define WALLSAW_IN_TIME     12  // 1.2 s retract
#define WALLSAW_DAMAGE      40  // brute per hit in path (cycle strike)
#define WALLSAW_CONTACT_DAMAGE 10  // brute per graze tick while the disc spins

// --- Floor saw timing (deciseconds) ---
#define FLOORSAW_WARN_TIME  14  // 1.4 s before it starts rolling
#define FLOORSAW_STEP_TIME   6  // 0.6 s per tile traversed
#define FLOORSAW_DAMAGE     35  // brute per tile passed over (cycle strike)
#define FLOORSAW_CONTACT_DAMAGE 12  // brute per graze tick while the wheel spins

// --- Contact (spinning blade) graze ---
#define HAZARD_CONTACT_INTERVAL 10  // 1.0 s between contact-damage ticks

// ============================================================
// Channels / wiring (mapper linking — Phase G)
// ============================================================

/// (channel, mode) — fired on a rust_sector when one of its channels triggers.
/// Puzzles/terminals listen and filter by channel name.
#define COMSIG_LABYRINTH_CHANNEL_FIRED "labyrinth_channel_fired"

// Pressure-plate activation modes
#define PLATE_MOMENTARY 1  // single pulse on step
#define PLATE_HOLD      2  // active while stood on (start/stop loop)
#define PLATE_WEIGHTED  3  // requires N mobs / enough weight on the tile
