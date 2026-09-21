# Editorial thematic edition — all twelve studies

All twelve source poems have a finished hero collage, organic specimen, paper note and secondary motif. `web/src/lib/themes.ts` is the single source for UI headings, asset set slugs, motif metadata, notes and the About/Credits index.

## Headline attribution

Headlines 1–10 follow Beverley Charles Rowe's stated themes, as quoted by the owner: South America, Ancient Greece, The Sea, India, Italy, Visiting Paris, Twinhood, Poetry, Food and Drink, Death. Fashion and Climate & Environment remain provisional editorial labels for the two additional English-version sonnets. Metadata records this distinction as `headlineSource`. The artwork itself is an editorial interpretation, not a claim about official illustrations.

The original reference board (`design/mockups/Codex Image 21 Sept 2026, 08_17_10.png`) is preserved unchanged as historical reference; its earlier labels are superseded by the metadata.

## Artwork system

| No. | Headline | Hero | Organic element | Secondary motif |
|---|---|---|---|---|
| 01 | South America | Gaucho, pampas and distant Andes | Pampas grass | Atlas fragment |
| 02 | Ancient Greece | Parthenon marble in Mediterranean light | Olive branch | Marble profile and archaeological drawing |
| 03 | The Sea | Atlantic fishing harbour and sea mist | Seaweed | Nautical chart and fish engraving |
| 04 | India | Stone veranda and tea terraces | Tea plant | Textile fragment and teacup |
| 05 | Italy | Tuscan landscape and Florence dome | Cypress and laurel | Architectural sketch and marble fragment |
| 06 | Visiting Paris | Paris streets and Seine bookstalls | Plane-tree leaves | Metro ticket and street map |
| 07 | Twinhood | Paired antique profiles and mirrored fragments | Paired ginkgo stems | Paired photographic fragments |
| 08 | Poetry | Letterpress page and library light | Laurel | Printing type and manuscript |
| 09 | Food and Drink | Pear, bread and wine in a quiet still life | Grape vine | Carafe and recipe fragment |
| 10 | Death | Weathered stone and a cypress grove | Dried poppy | Hourglass and faded paper |
| 11 | Fashion | Tailoring and draped linen | Flax | Pattern paper and fashion engraving |
| 12 | Climate & Environment | Glacier, alpine lake and weathered mountains | Alpine wildflowers | Contour-map fragment and bee |

The theme follows the source poem of the currently playing line because Cono combines lines from different source poems. While stopped or during the intro, the artwork follows the first line’s selected source poem. Explore artwork previews any of the twelve themes without modifying lyrics or audio selections; Follow music restores automatic visual switching. Playback and randomization behavior are unchanged.

Shared frame dimensions preserve layout during switching, including the long Climate & Environment heading. The twelve-option preview menu scrolls within a bounded panel. Narrow screens keep a compact collage and paper note above the poem. About / Credits includes the twelve-name index and attribution distinction.

## Asset provenance and prompts

All artwork was generated with the built-in ImageGen tool. The eight new studies use the complete prompt set in `all-themes-prompts.md`; the four earlier studies retain their existing art under the corrected names. Production WebP assets live in `web/static/assets/editorial/themes/`, with one `<slug>.webp` hero and one `<slug>-botanical.webp` per set. Botanical alpha transparency is preserved. The approved shared paper texture remains `web/static/assets/editorial/paper-note.png`.

The common direction is warm off-white, muted olive/sepia/slate, photographic and botanical realism, restrained collage edges and paper grain, and European editorial typography. These are contemporary generated illustrations rather than documentary photographs.

## Validation

- Svelte check: no errors or warnings; seven existing audio regression tests pass.
- Static production build with BASE_PATH=/Cono passes.
- Browser tested at 1440×1080 and 390×844; all twelve theme pairs load.
- Desktop heading, hero, note and poem geometry is identical for every theme.
- Mobile hero and poem document positions are identical across all twelve, with no horizontal overflow.
- All twelve headlines are shared by preview, hero heading, metadata and About/Credits.
