/** One-based source-poem identities; layout geometry is shared by every set.
 * Planned sets deliberately use the neutral edition artwork, never another theme.
 */
export interface ThemeSet {
  id: number; title: string; status: 'ready' | 'planned'; hero: string | null;
  botanicalAsset: string | null; botanical: string; secondaryMotif: string; artDirection: string; paper: string; note: string;
}
export const themes: ThemeSet[] = [
  {
    "id": 1,
    "title": "Argentina",
    "status": "ready",
    "hero": "/assets/editorial/themes/argentina.webp",
    "botanical": "Pampas grass",
    "secondaryMotif": "Atlas fragment",
    "artDirection": "Gaucho, pampas and distant Andes",
    "paper": "/assets/editorial/paper-note.png",
    "note": "A distant plain. / A world between lines.",
    "botanicalAsset": "/assets/editorial/themes/argentina-botanical.webp"
  },
  {
    "id": 2,
    "title": "Classical Greece",
    "status": "ready",
    "hero": "/assets/editorial/themes/greece.webp",
    "botanical": "Olive branch",
    "secondaryMotif": "Marble profile and archaeological drawing",
    "artDirection": "Parthenon marble in Mediterranean light",
    "paper": "/assets/editorial/paper-note.png",
    "note": "What remains / learns another language.",
    "botanicalAsset": "/assets/editorial/themes/greece-botanical.webp"
  },
  {
    "id": 3,
    "title": "Maritime / Brittany",
    "status": "planned",
    "hero": null,
    "botanical": "Seaweed and coastal grass",
    "secondaryMotif": "Nautical chart and fish engraving",
    "artDirection": "Atlantic fishing harbour",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 4,
    "title": "Colonial India",
    "status": "planned",
    "hero": null,
    "botanical": "Tea plant",
    "secondaryMotif": "Textile fragment and teacup",
    "artDirection": "Veranda and tea plantation",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 5,
    "title": "Italy & Antiquity",
    "status": "planned",
    "hero": null,
    "botanical": "Cypress and laurel",
    "secondaryMotif": "Dome sketch and marble bust",
    "artDirection": "Tuscan landscape and classical architecture",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 6,
    "title": "Country & City",
    "status": "planned",
    "hero": null,
    "botanical": "Wheat and wildflowers",
    "secondaryMotif": "Metro map and rural ledger",
    "artDirection": "Fields at the edge of a city",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 7,
    "title": "Family & Genealogy",
    "status": "planned",
    "hero": null,
    "botanical": "Branching stems",
    "secondaryMotif": "Genealogy diagram and parchment",
    "artDirection": "An archival family portrait",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 8,
    "title": "Poetry & Language",
    "status": "ready",
    "hero": "/assets/editorial/themes/poetry.webp",
    "botanical": "Laurel",
    "secondaryMotif": "Printing type and manuscript",
    "artDirection": "Letterpress page and library light",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / Another constellation.",
    "botanicalAsset": "/assets/editorial/themes/poetry-botanical.webp"
  },
  {
    "id": 9,
    "title": "Food",
    "status": "planned",
    "hero": null,
    "botanical": "Herbs and pear leaf",
    "secondaryMotif": "Recipe fragment and engraved tableware",
    "artDirection": "Quiet European still life",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 10,
    "title": "Death",
    "status": "planned",
    "hero": null,
    "botanical": "Dried poppy",
    "secondaryMotif": "Hourglass and memorial fragment",
    "artDirection": "Cypress grove and weathered stone",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 11,
    "title": "Fashion",
    "status": "planned",
    "hero": null,
    "botanical": "Flax",
    "secondaryMotif": "Pattern paper and fashion engraving",
    "artDirection": "Tailoring and fabric study",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / A different world.",
    "botanicalAsset": null
  },
  {
    "id": 12,
    "title": "Climate & Nature",
    "status": "ready",
    "hero": "/assets/editorial/themes/climate.webp",
    "botanical": "Alpine wildflowers",
    "secondaryMotif": "Contour-map fragment and bee",
    "artDirection": "Glacier, alpine lake and weathered mountains",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The weather turns. / The page remains.",
    "botanicalAsset": "/assets/editorial/themes/climate-botanical.webp"
  }
];
export const previewThemes = themes.filter(theme => theme.status === 'ready');
