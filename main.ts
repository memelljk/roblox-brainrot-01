// Pinisi Brainrot Bay: the hand-in program for make.fun's roblox-brainrot-01.
// Node 22, standard library only, no install and no network. It copies this
// repository's Rojo-built place (game.rbxl), its Luau sources (src/), its
// screenshots and its PLAY.json into the grader's output directory, then
// writes dossier.json there with the vendored make.fun library.
//
// The grader runs this program twice and demands byte-identical output, so
// it only copies and summarises: nothing here reads the clock, the network
// or any random source. Run it locally the same way the grader does:
//
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
//
// Names under /output must start with a letter, a digit or _ and hold only
// letters, digits, . _ and -: a dotted name (.gitkeep, .DS_Store) fails the
// entry, so the directory copies below skip every dotted name, at any depth.

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The repository root: the folder this file lives in.
const repoRoot = fileURLToPath(new URL('.', import.meta.url));
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output.
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** cpSync filter: keep every file and folder whose name does not start with a dot. */
function keepUndotted(path: string): boolean {
  return !basename(path).startsWith('.');
}

// The place file and the play link go over as single files.
copyFileSync(join(repoRoot, 'game.rbxl'), join(outputDir, 'game.rbxl'));
copyFileSync(join(repoRoot, 'PLAY.json'), join(outputDir, 'PLAY.json'));

// Sources and screenshots go over whole, dotted names left behind.
cpSync(join(repoRoot, 'src'), join(outputDir, 'src'), { recursive: true, filter: keepUndotted });
mkdirSync(join(outputDir, 'screenshots'), { recursive: true });
if (existsSync(join(repoRoot, 'screenshots'))) {
  cpSync(join(repoRoot, 'screenshots'), join(outputDir, 'screenshots'), { recursive: true, filter: keepUndotted });
}

// The dossier is the judge's view of the game: screenshots, place summary
// and scripts. The caps are the gate's own (see the kit's RULES.txt): the
// text cap shapes the bytes, the rest only refuse an entry the scorer
// would refuse anyway (too many or too large screenshots, a place past
// 500,000 instances, scripts past 8 MiB of source or 1,048,576 path chars).
writeFileSync(
  join(outputDir, 'dossier.json'),
  buildDossier(outputDir, {
    text_max_bytes: 65536,
    screenshots: { max: 4, max_bytes: 262144 },
    max_instances: 500000,
    scripts_max_source_bytes: 8388608,
    scripts_max_path_chars: 1048576,
  }),
);
