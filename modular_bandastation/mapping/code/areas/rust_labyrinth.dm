// ============================================================
// Rust-Forged Labyrinth — Area definitions
// Follows the same pattern as katorga13_areas.dm:
//   all areas under /area/awaymission/rust_labyrinth/
//   ambience_index = null  suppresses vanilla ambient sound
//   (rust_labyrinth uses its own ambient loop via K13-style GLOBAL_DATUM)
// ============================================================

/area/awaymission/rust_labyrinth
	name = "\improper Rust-Forged Labyrinth"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "away"
	requires_power = FALSE
	ambience_index = null
	static_lighting = FALSE
	base_lighting_alpha = 180

// Standard connecting passages — moderate rust, random content
/area/awaymission/rust_labyrinth/corridor
	name = "\improper Labyrinth Corridor"
	icon_state = "away"

// Trap sectors — heavy piston density, high rust
/area/awaymission/rust_labyrinth/trap_zone
	name = "\improper Labyrinth Trap Zone"
	icon_state = "away"
	base_lighting_alpha = 210

// The Forge sector — fixed layout, forge_station anchor lives here
/area/awaymission/rust_labyrinth/forge
	name = "\improper The Forge"
	icon_state = "away"
	base_lighting_alpha = 160

// Boss arena — only one, fixed, no content randomisation
/area/awaymission/rust_labyrinth/boss
	name = "\improper The Smithy"
	icon_state = "away"
	base_lighting_alpha = 230

// Fixed plot-critical transitions between biomes — no randomisation
/area/awaymission/rust_labyrinth/transition
	name = "\improper Labyrinth Threshold"
	icon_state = "away"
	base_lighting_alpha = 150
