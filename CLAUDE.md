# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BandaStation is a Space Station 13 game server — a Russian-language fork of [/tg/station](https://github.com/tgstation/tgstation) maintained by the SS220 community. The game runs on the BYOND engine. Primary language is Dream Maker (DM); the UI layer (TGUI) is React/TypeScript.

## Build & Run

**Windows (quickest):**
- Build & run: `bin/server.cmd` (starts server on port 1337)
- Build only: `BUILD.cmd` or `bin/build.cmd` (takes 1–5 min, produces `tgstation.dmb`)

**VSCode:** `Ctrl+Shift+B` to build, `F5` to build and run with debugger.

**CLI:**
```
tools/build/build.bat   # Windows
tools/build/build.sh    # Linux
tools/build/build.sh --help   # list available build targets
```

## Testing

Unit tests live in `code/modules/unit_tests/`. To run them:
1. Uncomment `#define UNIT_TESTS` in `code/_compile_options.dm`
2. Build and run the game — tests execute automatically on round start

CI runs on every PR via GitHub Actions: linting, map compilation, integration tests, and screenshot regression tests. Workflows are in `.github/workflows/`.

**TGUI linting (JavaScript/TypeScript):**
```
npm run tgui:lint    # check
npm run tgui:fix     # auto-fix
```

## Code Architecture

**Entry point:** `tgstation.dme` — the master Dream Maker Environment file. Do not edit manually; it's managed by the build system.

**Key directories:**

| Path | Purpose |
|------|---------|
| `code/` | All DM game logic |
| `code/__DEFINES/` | Compile-time constants and macros |
| `code/controllers/` | Master controller and subsystems (game loop) |
| `code/modules/` | Gameplay systems (atmos, jobs, antagonists, chemistry, …) |
| `modular_bandastation/` | BandaStation-only additions — all custom code lives here |
| `tgui/` | React-based UI (TGUI framework) |
| `_maps/` | Map files (`.dmm` format) |
| `config/` | Runtime server configuration |
| `SQL/` | MariaDB schema (`tgstation_schema.sql`) |

**Subsystem architecture:** The master controller (`code/controllers/master.dm`) initialises and ticks all subsystems in priority order (atmosphere, AI, jobs, chat, etc.). Each subsystem is a separate file under `code/controllers/subsystem/`.

**Modular system:** All BandaStation customisations go into `modular_bandastation/` — never directly into upstream `code/`. This keeps merging `/tg/station` updates feasible. The directory mirrors the upstream structure: `_defines220/`, `_helpers220/`, `antagonists/`, `balance/`, etc.

**TGUI:** UI panels are React components under `tgui/packages/`. They communicate with DM code via a message-passing bridge. `rspack.config.ts` is the bundler config.

## Code Conventions

- **Indentation:** Tabs, not spaces.
- **Line endings:** LF only (enforced by `.gitattributes` and `.editorconfig`).
- **Spaces:** Around boolean/logic operators; no spaces around bitwise operators.
- **Prefer early returns** over deep nesting.
- **`static` over `global`** for file-scoped variables.
- Configure git to ignore bulk-formatting commits: `git config blame.ignoreRevsFile .git-blame-ignore-revs`

Style guide: `.github/guides/STYLE.md`. Code standards: `.github/guides/STANDARDS.md`.

## Changelog System

Every PR must include a changelog block in the PR body:

```
:cl:
add: Short description of new feature
fix: Short description of bug fix
balance: Short description of balance change
/:cl:
```

Valid tags: `add`, `admin`, `balance`, `code_imp`, `config`, `del`, `fix`, `image`, `map`, `qol`, `refactor`, `server`, `sound`, `translation`, `typo`.

Changelogs are compiled automatically by `auto_changelog.yml` and committed by CI.

## Configuration

Runtime config lives in `config/`. Key files:
- `config.txt` — server settings, gamemode probabilities, map rotation
- `dbconfig.txt` — MariaDB connection details (MariaDB 10.2+ required)
- `admins.txt` — admin list (`byondkey = Rank`)
- `jobconfig.toml` — job slots

Compile-time feature flags: `code/_compile_options.dm`.

## Database

Requires MariaDB 10.2+. Initialize with `SQL/tgstation_schema.sql`. Edit `config/dbconfig.txt` with host/credentials. SQL is needed for player stats, admin logs, job-only bans, and library features.

## Native Libraries

`rust_g.dll` (Windows) / `librust_utils.so` (Linux) — Rust-compiled native helpers loaded by the BYOND runtime. These are pre-built binaries; rebuild only if modifying `tools/rust_g/`.

---

## Active Project: "Rust-Forged Labyrinth"

A horror event system currently in development on the `rust` branch. Genre: Industrial Grimdark Horror — Silent Hill meets industrial derelict. Players are stalked by a living, mechanical environment.

### Module Root

`modular_bandastation/rust_labyrinth/` — весь код и карты проекта.

All files **must** stay inside `modular_bandastation/`. Never create global systems; hook into existing ones via clean interfaces.

| Phase | File | Description | Status |
|-------|------|-------------|--------|
| I | `rust_labyrinth/code/defines.dm` | Константы: размеры сетки, типы секторов, сигналы | ✅ Done |
| I | `rust_labyrinth/code/grid_manager.dm` | `rust_grid_manager` (global singleton) + `rust_sector` datum + `map_template/rust_sector_template` | ✅ Done |
| I | `rust_labyrinth/code/admin.dm` | Admin verbs: Initialize / Load All / Status / Set Rust / Force Corrosion | ✅ Done |
| II | `rust_labyrinth/code/mechanics/piston.dm` | `obj/structure/piston` + `/datum/sync_controller` | ✅ Done |
| III | `rust_labyrinth/code/mechanics/corrosion.dm` | `Corrosion_Controller` + `obj/structure/forge_station` + `obj/item/blank` | ✅ Done |
| Fix | `rust_labyrinth/code/admin.dm` + `piston.dm` | Fix ghost verb restriction; fix piston verb to ADMIN_VERB; add "Go to Labyrinth" verb | ✅ Done |
| B1 | `mapping/code/areas/rust_labyrinth.dm` | Custom `/area/awaymission/rust_labyrinth/*` types: corridor, trap_zone, forge, boss, transition | ✅ Done |
| B2 | `rust_labyrinth/code/grid_manager.dm` | `on_loaded()` calls `_make_zone_area()` + `set_turfs_to_area()` | ✅ Done |
| C1 | `rust_labyrinth/code/admin_panel.dm` | `/datum/labyrinth_control_panel` — TGUI datum: `ui_data()`, `ui_act()` | ✅ Done |
| C2 | `tgui/packages/tgui/interfaces/LabyrinthControl.tsx` | React: 5×5 grid map, per-sector panel, global controls | ✅ Done |
| D1 | `rust_labyrinth/code/content/content_module.dm` | Base `/datum/labyrinth_content_module` — `apply(sector)` / `clear(sector)` | ✅ Done |
| D2 | `rust_labyrinth/code/content/modules/piston_trap.dm` | Module: случайные ряды поршней (EW/NS), 3–5 рядов | ✅ Done |
| D2 | `rust_labyrinth/code/content/modules/forge_decor.dm` | Module: forge_station + girder/цепи/кровь/хлам для FORGE-зон | ✅ Done |
| D3 | `rust_labyrinth/code/content/modules/horror_ambience.dm` | Module: фоновые ambient-сообщения ужаса, loop 30–60s | ✅ Done |
| E | `rust_labyrinth/maps/*.dmm` | Base DMM templates (geometry only — walls/floors, no content) | When maps ready |
| IV | `rust_labyrinth/code/mobs/blacksmith.dm` | Blacksmith boss + Keeper NPC | ✅ Done |
| IV | `rust_labyrinth/code/mobs/blacksmith_abilities.dm` | Spell abilities: forge_strike, iron_slam, rust_chains | ✅ Done |

Map modules (`.dmm`) go in `rust_labyrinth/maps/`. Base DMMs should contain only geometry (walls, floors, airlocks) — content is placed by code modules.

### Hard Constraints

- **ADMIN_VERB only — no exceptions.** Admin verbs must use the `ADMIN_VERB` macro through `SSadmin_verbs`. Never use `/client/proc` with `set category`. This is a hard rule: "мы делаем так и никак иначе." Pattern:
  ```dm
  ADMIN_VERB(my_verb, R_ADMIN, "Display Name", "Description.", ADMIN_CATEGORY_EVENTS)
      // body — `user` is the client, `user.mob` is their mob. Never `usr`.
  ```
  Available categories in `code/__DEFINES/admin_verb.dm`: `ADMIN_CATEGORY_EVENTS`, `ADMIN_CATEGORY_FUN`, `ADMIN_CATEGORY_GAME`, etc.
- **Player safety:** Never delete or move a tile a player stands on — apply damage or displacement instead.
- **Piston crush check:** `_process_turf()` always checks before damaging. A piston that skips the mob check is a bug.
- **Performance:** On 230×230 use `locate()` with bounding boxes and `typecacheof()` — no unbounded `for(var/X in world)`.
- **No instant mechanics:** Animations must be slow and weighted. "Calculate → wait → risk."
- **No easy exits:** Nothing should trivialise the Blacksmith hunt or let players skip puzzle sections.

### Katorga13-backup Reference Patterns

The branch `Katorga13-backup` on `tylerdefeat-crypto/BandaStation` is a completed event (Каторга-13: Скрюченный Человек) by the same author. Use it as the canonical reference for how to structure future event bosses and ambience.

**Module layout** — same as ours:
```
modular_bandastation/
  k13_crooked_man/
    _k13_crooked_man.dm    # modpack datum
    _k13_crooked_man.dme   # includes
    code/
      magic/               # boss abilities (spells)
        ability_devour.dm  # example: /datum/action/cooldown/spell/crooked_devour
      ...
  k13ambience/
    _k13ambience.dm
    code/ambience.dm       # global ambient sound system
```

**Boss mob structure:**
- `ai_controller = null` — the boss has **no AI**. During events an admin manually possesses it or a dedicated operator controls it. Do not plan complex BYOND AI; design abilities that an admin can use in real-time.
- Abilities are `/datum/action/cooldown/spell/` subtypes — granted via `Grant(target)` in `Initialize()`. Same system Banshee uses.
- High HP + heavy damage resistance (e.g., 1 000 000 HP, 90% damage reduction) to survive combat.

**Sound / ambience system:**
```dm
// GLOBAL_DATUM (no _INIT) — initialised manually, not at world start
GLOBAL_DATUM(K13_SOUNDS, /datum/k13_sounds)

/datum/k13_sounds
    proc/start_ambience()
        spawn(0)  // parallel, non-blocking
            while(!QDELETED(src))
                playsound(world, 'sound/...', 50, FALSE, channel = 70)
                sleep(...)
```
- Use dedicated sound channels (70, 71, …) to prevent ambient tracks from interrupting each other.
- `GLOBAL_DATUM` (no `_INIT`) + manual `new()` call when the event starts. Avoids wasting a global init slot on something that isn't always active.

**Ability pattern** (from `ability_devour.dm`):
```dm
/datum/action/cooldown/spell/crooked_devour
    cooldown_time = 10 SECONDS
    // ...
/datum/action/cooldown/spell/crooked_devour/Activate(atom/target)
    // uses victim, creates a storage object, ticks damage, handles death messaging
```
- Boss abilities handle all messaging themselves (attacker / victim / observer perspectives).
- `to_chat(victim, span_userdanger("..."))`, `to_chat(world, ...)` for horror ambient text.

### Key Design Decisions (Phase III — Corrosion & Forge)

- **`/datum/corrosion_controller`** lives on `rust_sector.corrosion_controller` (one per loaded sector). Created in `on_loaded()` alongside `sync_controller`. Auto-started if `rust_level > 0` at load time.
- **Loop**: `set waitfor = FALSE` + `SLEEP_NOT_DEL(CORROSION_TICK_INTERVAL)` (100 ds = 10 s). Sweep iterates `sector.get_turfs()` with `CHECK_TICK` to avoid lag spikes.
- **Item damage**: calls `atom.take_damage(amount, BRUTE, sound_effect=FALSE)` on anything with `uses_integrity = TRUE`. Skips `INDESTRUCTIBLE` or `ACID_PROOF` items. Damage scales with `rust_level`: MILD→1, HEAVY→4, LETHAL→10 HP/sweep.
- **Mob damage**: 40% chance per sweep at HEAVY+. HEAVY: 2 brute + lung-burn message. LETHAL: 8 brute + horror message.
- **Admin control**: "Labyrinth: Set Rust Level" (input dialog, 0–100) auto-starts or stops the controller. "Labyrinth: Force Corrosion Sweep" triggers `_sweep()` immediately.
- **`/obj/structure/forge_station`**: unique anchor in FORGE sectors. Spawns `/obj/item/blank` on its own turf in `Initialize()`. Registers `COMSIG_ITEM_PICKUP` on The Blank — fires `COMSIG_LABYRINTH_BLANK_TAKEN` when taken.
- **`/obj/item/blank`** (The Blank): `WEIGHT_CLASS_HUGE`, 30 force, 800 max_integrity. Signals the Blacksmith hunt when picked up. Phase IV subscribes to `COMSIG_LABYRINTH_BLANK_TAKEN` from `forge_station` to spawn/alert the boss.

### Key Design Decisions (Phase I — Grid Manager)

- `rust_grid_manager` singleton: `GLOBAL_DATUM_INIT(rust_grid_manager, /datum/rust_grid_manager, new)` → access via **`GLOB.rust_grid_manager`**.
- `initialize_labyrinth()` creates the Z-level via `SSmapping.add_new_zlevel(name, ZTRAITS_AWAY_SECRET)` — call from admin verb or event, **not** at world start.
- `register_sector(gx, gy, type, mappath, rust_level)` pre-configures cells before loading.
- `load_sector(gx, gy)` loads one `.dmm` via `/datum/map_template/rust_sector_template` (inherits upstream `load()` + `initTemplateBounds()`). Template is cached (`keep_cached_map = TRUE`).
- `get_sector_at(turf/T)` → O(1): divides tile coords by 46, returns `rust_sector` datum.
- Grid index macro: `LABYRINTH_GRID_INDEX(gx, gy)` = `(gy-1)*5 + gx`.
- Sector size: 46×46 tiles (5×46 = 230 per axis).
- Each sector owns a `/datum/sync_controller` created in `on_loaded()`.

### Key Design Decisions (Phase II — Piston & Sync)

- **`obj/structure/piston`** stays on its own turf — never moves between turfs. Extension is purely visual via `animate(src, pixel_x/pixel_y, time, easing)` (32 px = 1 tile).
- **Timing**: warn 1.5 s → extend 2 s → hold 0.8 s → retract 1.2 s. All delays via `SLEEP_NOT_DEL`. `operating = TRUE` blocks re-entry.
- **Crush applied at 60% of extend time** via `addtimer(CALLBACK(...))` so the hit lands mid-stroke, not at the end.
- **Displacement logic** (`_hit_mob`):
  - Mob can escape (open turf ahead) → `PISTON_DAMAGE_GLANCING (20 brute)` + `throw_at()`.
  - Mob pinned (dense turf/wall ahead) → `PISTON_DAMAGE_CRUSH (55 brute)` + `Paralyze(6s)` + splatter.
- **Auto-registration**: `piston/Initialize()` calls `GLOB.rust_grid_manager.get_sector_at()` and self-registers into `S.sync_controller`. `Destroy()` unregisters.
- **`/datum/sync_controller`** lives on `rust_sector.sync_controller` (one per sector). `pulse()` fires all pistons simultaneously and locks itself for one full cycle before allowing the next pulse.
- **Icon/sound placeholders** in piston.dm: `icon = 'icons/obj/structures.dmi'`, sounds from `sound/effects/`. Replace with `rust_labyrinth/icons/piston.dmi` and custom SFX when art is ready.

### Architecture: Zones vs Sectors

The physical 5×5 grid (`rust_grid_manager` + `rust_sector`) handles Z-level layout and DMM loading. On top of it sits a **zone/area layer**:

- Base DMM = geometry only (walls, floors, airlocks). No furniture or content baked in.
- After DMM loads, `on_loaded()` calls `set_turfs_to_area(sector.get_turfs(), zone_area)` to assign all sector tiles to a custom `/area/awaymission/rust_labyrinth/*` instance.
- Custom areas control ambient sound, lighting level, atmosphere.
- **Content modules** (`/datum/labyrinth_content_module`) are applied on top: they spawn and track objects (pistons, decor, etc.). Fixed sectors (FORGE, BOSS) use fixed modules; TRAP and CORRIDOR sectors randomly pick from a pool.

**Area file location:** `modular_bandastation/mapping/code/areas/rust_labyrinth.dm` — included via `_mapping.dme`. This matches the Katorga13 pattern (`katorga13_areas.dm` lives in the same directory). Area types are **NOT** inside the event module itself.

**Key area settings:**
- `ambience_index = null` — suppresses vanilla ambient sound system. The labyrinth uses its own sound loop (Phase V, same as `k13ambience`).
- `requires_power = FALSE` — no APC needed.
- `static_lighting = FALSE` + `base_lighting_alpha = 180–230` — manually controlled darkness per zone.

**`rust_sector._make_zone_area()`** returns a new area instance per sector based on `sector_type`. Called in `on_loaded()`. `set_turfs_to_area(list/turfs, area)` (`code/__HELPERS/areas.dm`) works at runtime — no restart needed. `block(x1, y1, z1, x2, y2, z2)` form confirmed valid (used in `map_template.dm` and `CORNER_BLOCK_OFFSET`).

**Zone types** (`/area/awaymission/rust_labyrinth/`):
| Subtype | Sector type | Purpose |
|---------|-------------|---------|
| `corridor` | CORRIDOR | Random content, moderate darkness |
| `trap_zone` | TRAP | Piston-heavy, very dark |
| `forge` | FORGE | Fixed layout, forge_station anchor |
| `boss` | BOSS | Boss arena, most oppressive lighting |
| `transition` | EMPTY/default | Plot-critical passage between biomes |

### Architecture: Content Modules (Phase D)

Content modules populate sectors with gameplay objects at runtime. Базовый тип — `/datum/labyrinth_content_module` (`code/content/content_module.dm`).

**API:**
```dm
/datum/labyrinth_content_module
    var/module_name = "base"
    var/list/spawned = list()
    var/datum/rust_sector/owner_sector

    proc/apply(datum/rust_sector/S)   // override in subtypes — spawn objects, call _track()
    proc/clear()                       // qdel all spawned, null owner_sector
    proc/_new(type, turf/T)           // spawn + track in one call
    proc/_track(atom/A)               // register existing object
    proc/_rand_turf(S, margin=2)      // random turf inside sector with edge margin
    proc/_sector_turf(S, ox, oy)      // turf at offset from anchor_turf
```

**Подключение к сектору:**
```dm
S.apply_content_module(new /datum/labyrinth_content_module/piston_trap())
S.clear_content_module()   // qdel spawned + qdel модуля
```
`rust_sector.applied_module` — текущий модуль (null если нет).

**Готовые модули:**
| Тип | Файл | Применение |
|-----|------|-----------|
| `piston_trap` | `content/modules/piston_trap.dm` | TRAP/CORRIDOR — 3–5 рядов поршней EW или NS, 40% шанс центрального поршня |
| `forge_decor` | `content/modules/forge_decor.dm` | FORGE — forge_station в центре + girder/цепи/кровь/кирки/металлолом |
| `horror_ambience` | `content/modules/horror_ambience.dm` | Любой — фоновый loop с `to_chat` сообщениями ужаса (Pending) |

**Ключевые решения:**
- `piston_trap` спавнит `/obj/structure/piston` через `new` → `piston/Initialize()` сам регистрируется в `S.sync_controller`. При `clear()` → `qdel(P)` → `piston/Destroy()` сам unregister_piston. Модуль не трогает sync_controller напрямую.
- `forge_decor` спавнит `forge_station` программно — не нужен DMM с forge_station, модуль сам его размещает в центре сектора.
- `forge_chain` и `forge_chain/hanging` — кастомные `/obj/structure` определены прямо в `forge_decor.dm`.
- Дефайны ориентации поршней (`PISTON_ORIENT_EW/NS`) живут в `defines.dm`, не в модуле.
- Plane-константа для "над игровым слоем": `ABOVE_GAME_PLANE` (-3), **не** `GAME_PLANE_UPPER` (не существует).

**TGUI: apply_module / clear_module в ui_act:**
```dm
if("apply_module")
    // params["module_type"] = "piston_trap" | "forge_decor"
    // создаёт нужный тип, вызывает S.apply_content_module(M)
if("clear_module")
    // S.clear_content_module()
```
`module_name` экспортируется в `ui_data` через `S.applied_module?.module_name`.

### Architecture: Admin Control Panel (TGUI)

Pattern from `code/modules/admin/verbs/secrets.dm`:
```dm
// 1. ADMIN_VERB opens a datum that implements TGUI
ADMIN_VERB(labyrinth_panel, R_ADMIN, "Labyrinth: Control Panel", "...", ADMIN_CATEGORY_EVENTS)
    var/datum/labyrinth_control_panel/panel = new(user)
    panel.ui_interact(user.mob)

// 2. Datum: ui_interact / ui_data / ui_act
/datum/labyrinth_control_panel
/datum/labyrinth_control_panel/ui_interact(mob/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "LabyrinthControl")
        ui.open()
/datum/labyrinth_control_panel/ui_data(mob/user)
    // returns JSON-serializable list for the React side
/datum/labyrinth_control_panel/ui_act(action, list/params)
    // handles button clicks from React
```
- React component: `tgui/packages/tgui/interfaces/LabyrinthControl.tsx`
- Shows 5×5 grid (color by status), per-sector sidebar (rust slider, pulse, teleport, module apply/clear), global controls.
- Окно растягиваемое, перетаскиваемое, с кнопкой закрытия — обёрнуто в `<Window>` + `<Window.Content fitted>`.

**TGUI Window паттерн для resizable/movable окон:**
```tsx
import { Window } from '../layouts';

export function MyInterface() {
  return (
    <Window title="Title" width={780} height={560}>
      <Window.Content fitted>
        {/* контент, использующий Stack fill */}
      </Window.Content>
    </Window>
  );
}
```
- `fitted` убирает внутренние отступы — нужен когда контент сам управляет layout через `Stack fill`.
- Drag встроен в TitleBar, resize handles (e/s/se) встроены в Window — ничего дополнительного не нужно.
- `canClose={false}` — скрыть кнопку закрытия (по умолчанию `true`).

### DM / SpacemanDMM gotchas discovered during development

- **Global singletons** via `GLOBAL_DATUM_INIT(name, /type, new)` are accessed as **`GLOB.name`** everywhere — never as bare `name`. The macro declares the var on `/datum/controller/global_vars`; `GLOB` is the singleton of that controller.
- **SpacemanDMM (dreamchecker)** doesn't always pick up newly added files until you do **Ctrl+Shift+P → Restart Language Server** in VSCode. Do this after adding any new `.dm`/`.dme` files to the project.
- **`SLEEP_NOT_DEL(time)`** — always use instead of bare `sleep()` inside procs that may outlive their object. It returns early if `src` was deleted during the sleep.
- **`abstract_move(turf)`** works for both living mobs AND ghosts/observers — use this in admin teleport verbs instead of `forceMove`. Never gate on `isliving(user.mob)` for navigation-only verbs.
- **Signals on plain datums work** — `SEND_SIGNAL` / `RegisterSignal` are defined on `/datum`, not just atoms.
- **Trailing commas in argument lists** are supported in the BYOND version this codebase targets — fine to use.
- **Resource literals** `'path/to/file.ogg'` — обязательно закрывать одинарной кавычкой. Незакрытый литерал "съедает" весь остаток файла как строку — cascade errors вплоть до конца файла.
- **`GAME_PLANE_UPPER` не существует** — правильная константа `ABOVE_GAME_PLANE` (значение -3, над игровым планом). Список планов: `FLOOR_PLANE(-6)`, `WALL_PLANE(-5)`, `GAME_PLANE(-4)`, `ABOVE_GAME_PLANE(-3)`, `SEETHROUGH_PLANE(-2)`.
- **`ABOVE_MOB_LAYER`** (4.1) — существует и корректен для объектов поверх мобов.

### Next Steps (Phase D → IV)

### Architecture: Blacksmith Boss + Keeper NPC (Phase IV)

**The Blacksmith** — `modular_bandastation/rust_labyrinth/code/mobs/blacksmith.dm`:
- Наследует `/mob/living/basic/` напрямую (не /boss, чтобы не получать megafauna AI/traits)
- `ai_controller = null` — admin-controlled через BYOND possess
- `maxHealth = 500000`, `damage_coeff` BRUTE/BURN = 0.1 (90% reduction)
- `AddElement(/datum/element/wall_tearer, tear_time = 0.5 SECONDS)` в Initialize
- Способности выдаются через `new /datum/action/cooldown/spell/blacksmith/X(src)` + `X.Grant(src)`
- Подписывается на `COMSIG_LABYRINTH_BLANK_TAKEN` через `RegisterSignal(GLOB.rust_grid_manager, ...)` в Initialize

**Forge Station → сигнал изменён:** `SEND_SIGNAL(GLOB.rust_grid_manager, COMSIG_LABYRINTH_BLANK_TAKEN, user, B)` — теперь шлёт на singleton, а не на src. Blacksmith регистрирует сигнал там же.

**Способности** (`code/mobs/blacksmith_abilities.dm`):
| Тип | Кулдаун | Эффект |
|-----|---------|--------|
| `forge_strike` | 8s | pointed, range 2 — 150 brute + Knockdown 4s |
| `iron_slam` | 15s | AOE radius 4 — 30 brute + knockback на всех рядом |
| `rust_chains` | 20s | pointed, range 6 — 20 brute + Stun + Paralysis 5s |

Все способности: `spell_requirements = NONE`, `antimagic_flags = NONE` — не магические, не блокируются.

**The Keeper** — пассивный NPC с `idle_behavior = /datum/idle_behavior/idle_random_walk`. Случайные жуткие фразы через `_speak_loop()` (set waitfor = FALSE, rand(400–800) ds интервал).

**ADMIN_VERBs для спавна:** `labyrinth_spawn_blacksmith`, `labyrinth_spawn_keeper` — спавнят на тайле под ногами (работает из ghost). Также доступны через TGUI панель (кнопки Spawn Blacksmith / Spawn Keeper в sidebar сектора).

**Оставшееся:** Phase E — DMM-шаблоны карт (geometry). Создаются в DreamMaker / Spaceman редакторе и кладутся в `rust_labyrinth/maps/`. Регистрируются через `mgr.register_sector(gx, gy, type, 'modular_bandastation/rust_labyrinth/maps/sector_X_Y.dmm')`.

> ⚠️ **УСТАРЕЛО (Phase IV):** Blacksmith + Keeper **удалены** из проекта (файлы `code/mobs/*` и `COMSIG_LABYRINTH_BLANK_TAKEN` убраны). Босс будет переделан отдельно позже. Секция выше оставлена как историческая справка по паттернам, но в текущем коде её нет.

### Round-start загрузка (вместо ручного Initialize)

Лабиринт грузится в `SSmapping/Initialize()` через extension-хук `code/mapping_hook.dm` — тот же этап, что lavaland/ruins, **только при старте сервера, никогда не в середине раунда** (процедурная генерация в раунде роняет сервер). Хук: `. = ..()` → `initialize_labyrinth()` → `register_default_labyrinth_layout()` → цикл `load_sector()` с `CHECK_TICK`. Admin verb «Initialize» оставлен для ручного перезапуска, но в норме не нужен.

DMM-секторы (geometry-only коробки 46×46) лежат в `maps/`: `test_corridor/trap/forge/boss/transition.dmm`. Area прописаны прямо в DMM (`/area/awaymission/rust_labyrinth/*`), плюс `on_loaded()` всё равно переназначает их через `set_turfs_to_area()`.

---

## Модульная система ловушек и головоломок («Куб»)

> Статус: **РЕАЛИЗОВАНО** (фазы F1–H3 + двери + консоль-инспектор). Жанр-референс — «Cube».
> Сборка проверена: `dm.exe tgstation.dme` → **0 errors**. Ниже — план + шпаргалка маппера.

### Шпаргалка маппера (что класть в DMM)

Все типы мапабельные, INDESTRUCTIBLE, авто-регистрируются в сектор при `Initialize()`.

| Тип | Назначение | Ключевые var (set в DMM) |
|-----|-----------|--------------------------|
| `/obj/structure/labyrinth_hazard/piston` | поршень | `dir`, `hazard_channel`, `loop_interval`, `loop_offset` |
| `/obj/structure/labyrinth_hazard/floor_spikes` | шипы из пола (свой тайл) | `hazard_channel`, `loop_*` |
| `/obj/structure/labyrinth_hazard/wall_saw` | пила из стены | `dir`, `reach`, `hazard_channel`, `loop_*` |
| `/obj/structure/labyrinth_hazard/floor_saw` | пила по рельсу | `dir`, `rail_length`, `hazard_channel`, `loop_*` |
| `/obj/structure/labyrinth_pressure_plate` | активатор | `target_channel`, `plate_mode` (1=MOMENTARY/2=HOLD/3=WEIGHTED), `required_count`, `fire_action` |
| `/obj/structure/labyrinth_door` | управляемая дверь | `open_channel`, `close_channel` (равны → toggle) |
| `/obj/structure/labyrinth_terminal` | TGUI-головоломка | `solution`, `prompt`, `win_channel`, `fail_channel` |

**Связь:** плита с `target_channel="trap_a"` + поршни с `hazard_channel="trap_a"` → авто-линк через `rust_sector.wiring`. Канал только внутри одного сектора. `fire_action`/режим плиты решают, что прилетит: `HAZARD_ACTION_TRIGGER`/`START_LOOP`/`STOP_LOOP`/`TOGGLE_LOOP` (см. defines.dm).

**Зацикливание:** у каждого hazard свой self-loop (`start_loop`/`stop_loop`, интервал `loop_interval`, фаза `loop_offset` для волн). Плюс `rust_sector.sync_controller`: `pulse()` (разово все), `loop_all()`/`stop_all()` (групповой непрерывный).

**Головоломки** (`/datum/labyrinth_puzzle`, привязка `sector.attach_puzzle(P)`):
| Тип | Дефолтные каналы | Win-условие |
|-----|------------------|-------------|
| `sequence` | input `seq_a/b/c`, fail `seq_fail`, win `seq_win` | плиты в верном порядке |
| `sacrifice` | input `sac_confirm`, win `sac_win` | конечность/живой моб на altar-тайле (`altar_ox/oy`) |
| `gauntlet` | input `gauntlet_finish`, win `gauntlet_win` | дойти до финиш-плиты живым (на setup стартует `loop_all`) |

### Консоль-инспектор (TGUI)

`LabyrinthControl.tsx` + `admin_panel.dm`: клик по зоне в сетке → `select_sector` → правая панель показывает **список ловушек и дверей зоны** (из `sync_controller.hazards` и `sector.doors`). Per-object кнопки: ловушка — **Fire / Loop / Stop** (`trigger_hazard`/`loop_hazard`/`stop_hazard` по `REF`); дверь — **Open/Close** (`toggle_door`). Плюс агрегатные **Loop All / Stop All / Pulse**, аттач/клир головоломки и модуля, rust-слайдер. Объекты резолвятся через `locate(params["ref"])`.

### Файлы реализации

`code/mechanics/hazard.dm` (база + `sync_controller`), `piston.dm` (рефактор под base), `hazards/{floor_spikes,wall_saw,floor_saw}.dm`, `pressure_plate.dm`, `labyrinth_door.dm`, `wiring.dm` (каналы на `rust_sector`), `puzzles/{puzzle,terminal}.dm` + `puzzles/types/{sequence,sacrifice,gauntlet}.dm`, `tgui/.../LabyrinthTerminal.tsx`. Сигнал каналов: `COMSIG_LABYRINTH_CHANNEL_FIRED` (channel, mode) — пазлы слушают через `RegisterSignal`.

---

### Исходный план (детализация фаз — для справки)

### Цели (из запроса автора)

1. **Зацикленные ловушки** — режим непрерывной работы (loop) без остановки, не только разовый pulse.
2. **Активаторы** — нажимные плиты на полу, которые можно **намаппить в DMM** и привязать к ловушкам/дверям/головоломкам.
3. **Головоломки** — модульные: через TGUI-окна И через нажимные плиты. Примеры: жертва конечности/одного человека из группы; полоса препятствий (шипы из пола, поршни, циркулярные пилы в стенах и полу).
4. Декор автор делает сам в DMM — приоритет на **мапабельные механики**, а не процедурный спавн.

### Архитектура: 4 слоя

```
Activator (вход)  →  Channel (связь)  →  Hazard / Puzzle (реакция)  →  Outcome (дверь/стоп-ловушка)
```

#### Слой 1 — Hazard base (общий тип опасных механизмов)

Рефактор: вынести общий базовый тип `/obj/structure/labyrinth_hazard` из текущего `piston`. Общий контракт:
- `trigger()` — один цикл: warn → strike → reset (медленно, weighted — как у поршня сейчас).
- `var/operating` — lock от повторного входа.
- `var/hazard_channel` — строковый канал привязки (для мапперов).
- `var/loop_active` / `var/loop_interval` / `var/loop_offset` — режим зацикливания.
- `start_loop()` / `stop_loop()` — driver `set waitfor = FALSE` + `while(loop_active)` + `SLEEP_NOT_DEL` (паттерн corrosion_controller).
- Crush/safety-check остаётся обязательным в каждом hazard (правило проекта).

Подтипы hazard (все **мапабельные**, all share base):
| Тип | Поведение | Урон |
|-----|-----------|------|
| `piston` (есть) | выдвигается в соседний тайл, толкает/давит | glancing 20 / crush 55 |
| `floor_spikes` | шипы выстреливают вверх из тайла под ногами | brute + embed, pin |
| `wall_saw` | циркулярка выезжает из стены вдоль линии | brute, кровь, при pinned — высокий |
| `floor_saw` | пила едет по прорези в полу (движется по рельсу N тайлов) | brute по всей линии хода |

#### Слой 2 — Activator (нажимные плиты, мапабельные)

`/obj/structure/labyrinth_pressure_plate` — кладётся в DMM:
- Детект через `AddElement(/datum/element/connect_loc, list(COMSIG_ATOM_ENTERED=…, COMSIG_ATOM_EXITED=…))` (паттерн из `code/game/objects/effects/mines.dm`).
- `var/target_channel` — на какой канал шлёт сигнал.
- Варианты режима: `momentary` (импульс при наступании), `hold` (активен, пока стоят), `weighted` (нужен вес/N мобов — для пазла «положи человека»).
- Визуально: вдавливается (pixel_y) + звук. Не density.

#### Слой 3 — Channel / Linking (связь маппинга)

Привязка по **строковому каналу** (mapper-friendly, рекомендуется вместо ручных refs):
- Реестр на секторе: `rust_sector.wiring` = assoc list `channel → list(responders)`.
- В `Initialize()` и activator, и hazard само-регистрируются в `get_sector_at().wiring[channel]`.
- Activator при срабатывании: `SEND_SIGNAL(sector, COMSIG_LABYRINTH_CHANNEL(channel))` → все подписчики реагируют (`trigger()`, `start_loop()`, `stop_loop()`, открыть дверь).
- Маппер просто ставит плиту с `target_channel = "trap_a"` и поршни с `hazard_channel = "trap_a"` — связь возникает сама.

#### Слой 4 — Puzzle framework

`/datum/labyrinth_puzzle` — оркестратор: владеет входами (активаторы/TGUI), условием победы, условием провала (запускает hazards), наградой (открыть дверь / остановить loop-ловушку).

Подтипы пазлов:
| Тип | Механика | Вход | Провал |
|-----|----------|------|--------|
| `sequence` | наступать на плиты в верном порядке (Cube-like) | плиты | ошибка → hazard pulse |
| `sacrifice` | положить на сенсор конечность ИЛИ живого моба (weighted plate) | weighted plate / altar | нет жертвы → дверь закрыта |
| `gauntlet` | пройти полосу препятствий живым; финишная плита открывает выход | loop-hazards + финиш-плита | смерть в коридоре |
| `terminal` | TGUI-окно: код/загадка/переключатели | `/obj/machinery/labyrinth_terminal` | неверный ввод → hazard |

**TGUI-пазл:** `/obj/machinery/labyrinth_terminal` открывает окно (`ui_interact`/`ui_act`, паттерн как `LabyrinthControl`). На solve → `SEND_SIGNAL` на канал. Новый React-компонент `LabyrinthTerminal.tsx`.

### Предлагаемые фазы реализации

| Фаза | Содержание | Файлы (план) |
|------|-----------|--------------|
| **F1** | Hazard base + рефактор piston под него; loop-driver | `code/mechanics/hazard.dm`, правка `piston.dm` |
| **F2** | Новые hazards: floor_spikes, wall_saw, floor_saw | `code/mechanics/hazards/*.dm` |
| **G1** | Pressure plate activator (connect_loc) | `code/mechanics/pressure_plate.dm` |
| **G2** | Channel/wiring система на rust_sector + сигналы | правка `grid_manager.dm`, `defines.dm` |
| **H1** | Puzzle base framework | `code/puzzles/puzzle.dm` |
| **H2** | Пазлы: sequence, sacrifice, gauntlet | `code/puzzles/types/*.dm` |
| **H3** | TGUI terminal + `LabyrinthTerminal.tsx` | `code/puzzles/terminal.dm`, tsx |
| **G3** | Admin/TGUI контроль: старт/стоп loop, список каналов в панели | правка `admin_panel.dm`, `LabyrinthControl.tsx` |

### Решения, которые надо согласовать ПЕРЕД кодом

1. **Loop ownership** — гонять loop на самом hazard ИЛИ через центральный controller (рекомендую controller-driven: даёт волны/смещение фаз и централизованный стоп).
2. **Рефактор piston** — переписать piston на новый hazard base (рекомендую, ради единообразия) ИЛИ оставить piston как есть и строить base рядом.
3. **Linking** — строковые каналы (рекомендую, mapper-friendly) ИЛИ explicit object refs в DMM.
4. **Приоритет фаз** — что первым: F (новые ловушки+loop) или H (головоломки)?

### Действующие ограничения проекта (применимы к плану)

- **ADMIN_VERB only** для всех админ-verb'ов.
- **Player safety:** не удалять/двигать тайл под игроком — урон/смещение.
- Каждый hazard **обязан** делать mob-check перед уроном (правило поршня).
- **Performance:** `locate()` с bounding box + `typecacheof()`, без `for(X in world)`.
- **No instant mechanics:** «calculate → wait → risk», анимации медленные.
- **No easy exits:** пазлы не должны тривиально пропускаться.
