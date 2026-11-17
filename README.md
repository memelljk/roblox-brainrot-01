# Pinisi Brainrot Bay

[![make.fun bounty](https://make.fun/bounty/roblox-brainrot-01)](https://make.fun/bounty/roblox-brainrot-01)

A 3D brainrot game on a Bugis island, built for make.fun's
**"Make the best AI Roblox brainrot game"** bounty (roblox-brainrot-01).
A Pinisi ship sails past the north shore while absurd island characters
walk the conveyor, earn money every second, and get stolen, locked away,
mutated, rebirthed — or washed away by the tsunami.

## How to play

1. **Walk to the conveyor** in the middle of the island. Brainrots walk
   south down the belt, each with a name, a rarity and a $/second rate.
2. **Buy one** from the shop panel on the left (or with the money you
   start with, $100). It moves to a free slot on your base.
3. **Watch the money tick up** — every brainrot pays its $/second, once
   a second, straight into your wallet (top right).
4. **Climb the ladder**: Common → Rare → Epic → Legendary → Mythic →
   Secret. Rarer brainrots cost more and pay far more per second.
5. **Lock your base** (bottom right) for 60 seconds when thieves circle
   your plot. A glowing blue wall shows while the lock holds.
6. **Steal**: click a brainrot on someone else's unlocked base and carry
   it home after a 3 second channel — if they don't lock their base first.
7. **Run from the tsunami**: every few minutes a warning sounds and a
   giant wave sweeps the island north to south. Anyone caught outside
   their own base loses 5% of their cash and is washed back to spawn.
8. **Rebirth** when you can afford it: your cash and collection reset,
   but every rebirth adds a permanent +25% income multiplier.
9. **Mutate**: re-roll any owned brainrot's mutation — Golden (x2),
   Diamond (x4) or Rainbow (x8) — for a fee. Its 3D body glows to match.

## The cast

12 original characters, all invented for this game — no character from
Steal a Brainrot or any other published game is used:

| Rarity | Characters | $/second |
|---|---|---|
| Common | Ikan Terbang Terbalik, Ayam Sepatu Roda | $1–$2 |
| Rare | Kapal Kertas Raksasa, Monyet Jual Es Kelapa | $5–$8 |
| Epic | Kuda Laut DJ Pantai, Nasi Goreng Terbang | $15–$22 |
| Legendary | Pinisi Terbang Malam, Hantu Laut Karaoke | $50–$80 |
| Mythic | Raja Udang Emas, Naga Bambu Bernyanyi | $150–$250 |
| Secret | Sultan Sagu Raksasa, Dewa Ombak Pinisi | $500–$1,000 |

## The world

A real 3D island built in `default.project.json`: a grass baseplate, a sea
strip with a wooden Pinisi ship (hull, mast, sails, red flag), a golden
railed conveyor down the middle, 8 coloured player plots with walls, sign
boards and 8 brainrot slots each, a spawn pad, stone steps, 10 trees,
8 rocks and 4 lamps, under a bright afternoon sky.

## Structure

One module per job, state kept in one place, client and server split:

- `src/server/BrainrotData.luau` — the cast, rarities, mutations, prices.
- `src/server/GameState.luau` — the single store for all player state.
- `src/server/BrainrotFactory.luau` — builds each brainrot as a 3D Model
  of parts, with its accessory, floating name/rarity/$-per-second label
  and ClickDetector.
- `src/server/MoneyService.luau` — the 1-second income tick, buying and selling.
- `src/server/BaseService.luau` — plot assignment, sign boards, base lock, upgrades.
- `src/server/SpawnerService.luau` — the conveyor: spawns and walks brainrots.
- `src/server/StealService.luau` — stealing with channel, lock check and cooldown.
- `src/server/EventService.luau` — the tsunami warning, wave sweep and penalty.
- `src/server/RebirthService.luau` — rebirth cost and reset.
- `src/server/MutationService.luau` — mutation re-rolls and body rebuilds.
- `src/server/init.server.luau` — wires the services, remotes and snapshots.
- `src/client/ClientUI.luau` — the whole HUD (money, shop, base, buttons, toasts).
- `src/client/init.client.luau` — client entry point, wires buttons to remotes.

## Build and hand in

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` (Node 22, standard library only) copies `game.rbxl`, `src/`,
`screenshots/` and `PLAY.json` to `/output` and writes
`/output/dossier.json` with the vendored `vendor/makefun-roblox.ts`.

## Status

`PLAY.json` still names no published place (place_id 0): the game is
built and verified locally, but publishing needs a Roblox account that
can publish a Public experience, which is not available in this session.
The screenshots are the kit starter's placeholders until real Studio
captures replace them.
