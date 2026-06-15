Roadmap: Project "Rust-Forged Labyrinth" (SS13 Event)
1. Project Constraints
Modular Isolation: All new logic, map modules (.dmm), and assets MUST be located within /modular_bandastation/.

Root Directory: Root must remain clean. Reference all source code from /modular_bandastation/.

Dependencies: Utilize existing codebase from /modular_bandastation/ where applicable.

2. Phase I: Core Modular Engine
Grid Manager: Implement Grid_Manager to handle a 5x5 sector grid (230x230 map).

Path: /modular_bandastation/code/grid_manager.dm

DMM Loader: Logic to instantiate dmm files from /modular_bandastation/maps/ into specific grid coordinates.

Sector Registry: Mapping system to define which module types exist and their metadata (entry/exit points).

3. Phase II: Mechanical Architecture
Piston Logic: Implement obj/structure/piston.

Requirement: Local coordinate-based animation; must include collision check to prevent static crushing.

Path: /modular_bandastation/code/mechanics/piston.dm

Sync Controller: Global trigger for synchronized wall movements across sectors.

4. Phase III: Survival & Forging Mechanics
Corrosion Controller: Item degradation logic based on sector-specific rust_level.

Path: /modular_bandastation/code/mechanics/corrosion.dm

The Forge (Anchor): Implementation of obj/structure/forge_station.

Logic for carrying "The Blank" (heavy object) and triggering the boss hunt.

5. Phase IV: Antagonist & NPC AI
The Blacksmith (Boss): AI implementation using the "Rust Path" network (node-based teleportation).

Path: /modular_bandastation/code/mobs/blacksmith.dm

The Keeper (NPC): Simple state machine for clue delivery and dialogue.

6. Phase V: Scripted Anchors & Stream Content
Event Anchors: Fixed map coordinate triggers for cinematic sequences.

Kerrigan's Tuning Fork: Item logic for real-time map visualization/previewing wall states.

Current Priority (Next Steps)
Initialize Grid_Manager skeleton in /modular_bandastation/code/.

Define the 5x5 grid schema and verify module connectivity logic.

Implement basic piston animation to ensure no engine conflicts occur.

System Context: "The Rust-Forged Labyrinth" (Horror Project)
1. Core Atmosphere
Genre: Industrial Grimdark Horror / Slasher.

Aesthetic: Silent Hill meets industrial derelict. Everything is covered in layers of iron oxide, vibrating, shrieking, and groaning.

Emotional State: Players must feel claustrophobic, resource-deprived, and stalked. The environment is not static—it is a predator.

2. The Narrative Hook
The Blacksmith (Antagonist): A former engineer who believes life is "noise" and "entropy." He wants to freeze existence into a static, perfect, rusted state. He doesn't kill; he "refines" living beings into eternal, immobile statues.

The "Kerrigan" Factor: The Blacksmith's antithesis. He is the "chaos" that must be silenced. All mechanics should emphasize the Blacksmith's obsession with hunting him down.

The Inevitability: There is no escape through simple flight. The environment forces players to move toward the center (The Forge) to survive.

3. Design Philosophy for Code
Anti-Speedrun: Every mechanical interaction should have a cost or a delay. We don't want "click-to-go." We want "calculate-wait-risk."

Environment as a Threat: The map is a machine. Pistons are not just walls; they are crushing gears. If a wall moves, it does so with weight, sound, and lethality.

Modular Integrity: All code is contained within /modular_bandastation/. Avoid creating new global systems; hook into existing ones via clean interfaces.

4. Interaction Guidelines for the AI
Tone: The AI acts as a co-conspirator in building a nightmare. The code you write should be robust but always keep the horror element in mind (e.g., piston animations should be slow and terrifying, not instant).

Strict Constraints:

No "easy" buttons for players.

Any code involving map movement must account for player position (don't delete/move tiles if a player is standing there, instead apply damage or displacement).

Performance: For a 230x230 map, use efficient locate() and typecache lookups.
