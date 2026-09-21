# Editorial thematic edition — first four studies

Reference: `design/mockups/Codex Image 21 Sept 2026, 08_17_10.png`, supplied by the owner on 2026-09-21, alongside the original clean Concept 1 mockup. The board is preserved unchanged.

`web/src/lib/themes.ts` contains all twelve one-based source-poem identities, art direction, organic/secondary motifs, paper-note copy and asset paths. Argentina, Classical Greece, Poetry & Language and Climate & Nature have finished artwork. The remaining eight deliberately display the neutral landscape and olive sprig with their own correct title, pending original artwork.

The theme follows the source poem of the currently playing line because Cono combines lines from different source poems. Before playback, the opening visual study is Argentina. “Explore artwork” pins a visual study without modifying any lyric selections or audio; “Follow music” restores automatic visual switching. Existing audio-loop and randomization behavior is unchanged. No whole-poem selector was added.

The heading, hero frame, paper note and botanical frame have shared geometry. Artwork remains visible on narrow screens in a compact two-column study above the poem. Theme headings and notes are HTML, not baked into the artwork. About / Credits stays separate.

## Asset provenance

Artwork generated with the built-in ImageGen tool. Hero PNG masters were generated at portrait 2:3. Production WebP copies preserve alpha on isolated botanical specimens. The shared paper texture is retained from the approved first edition.

Shared direction: restrained European literary/editorial collage, archival photography, delicate paper grain, muted ivory/olive/sepia/slate, subtle cut edges, no UI, logos, headings or colour swatches. The supplied board was the visual reference for the final Argentina and Climate heroes and all four isolated botanical assets.

- Argentina: gaucho on horseback, distant cattle, Andes/pampas and faded atlas fragment; airy pampas specimen.
- Classical Greece: Parthenon marble, small classical profile and archaeological drawing; isolated olive branch.
- Poetry & Language: library window, worn letterpress/manuscript fragments and printing type; isolated laurel.
- Climate & Nature: receding glacier, alpine lake, rocky foreground, tiny flowers and contour-map fragment; isolated alpine wildflower with a small bee.

Generated images are contemporary illustrative interpretations, not documentary source photographs. Theme names are interpretations of this edition's source poems.

## Validation

- Svelte check: 0 errors, 0 warnings; all seven existing audio regression tests passed.
- Static production build with `BASE_PATH=/Cono` passed.
- Browser inspected at 1440×1080 and 390×844. All four ready sets loaded successfully; measured heading, hero, note, poem and About geometry stayed identical between themes at desktop. On mobile, hero and poem document positions stayed identical across all four sets, with no horizontal overflow.
- Played the local edition and verified that the theme heading matched the active line's source poem (11 → Fashion), including the neutral fallback. Stop and artwork preview work independently.
- All eight production artwork files total approximately 2.3 MB; original reference board retained without changes.
