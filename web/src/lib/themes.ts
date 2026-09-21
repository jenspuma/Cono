/** All twelve source-poem studies share one layout. Titles 1–10 follow Rowe;
 * titles 11–12 are provisional editorial labels for the additional sonnets. */
export interface ThemeSet {
  id: number; slug: string; title: string; status: 'ready'; headlineSource: 'rowe' | 'editorial';
  hero: string; botanicalAsset: string; botanical: string; secondaryMotif: string;
  artDirection: string; paper: string; note: string;
}
export const themes: ThemeSet[] = [
  {
    "id": 1,
    "title": "South America",
    "status": "ready",
    "hero": "/assets/editorial/themes/south-america.webp",
    "botanical": "Pampas grass",
    "secondaryMotif": "Atlas fragment",
    "artDirection": "Gaucho, pampas and distant Andes",
    "paper": "/assets/editorial/paper-note.png",
    "note": "A distant plain. / A world between lines.",
    "botanicalAsset": "/assets/editorial/themes/south-america-botanical.webp",
    "slug": "south-america",
    "headlineSource": "rowe"
  },
  {
    "id": 2,
    "title": "Ancient Greece",
    "status": "ready",
    "hero": "/assets/editorial/themes/ancient-greece.webp",
    "botanical": "Olive branch",
    "secondaryMotif": "Marble profile and archaeological drawing",
    "artDirection": "Parthenon marble in Mediterranean light",
    "paper": "/assets/editorial/paper-note.png",
    "note": "What remains / learns another language.",
    "botanicalAsset": "/assets/editorial/themes/ancient-greece-botanical.webp",
    "slug": "ancient-greece",
    "headlineSource": "rowe"
  },
  {
    "id": 3,
    "title": "The Sea",
    "status": "ready",
    "hero": "/assets/editorial/themes/the-sea.webp",
    "botanical": "Seaweed",
    "secondaryMotif": "Nautical chart and fish engraving",
    "artDirection": "Atlantic fishing harbour and sea mist",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The tide returns. / No shore is the same.",
    "botanicalAsset": "/assets/editorial/themes/the-sea-botanical.webp",
    "slug": "the-sea",
    "headlineSource": "rowe"
  },
  {
    "id": 4,
    "title": "India",
    "status": "ready",
    "hero": "/assets/editorial/themes/india.webp",
    "botanical": "Tea plant",
    "secondaryMotif": "Textile fragment and teacup",
    "artDirection": "Stone veranda and tea terraces",
    "paper": "/assets/editorial/paper-note.png",
    "note": "Light in the shade. / A distant conversation.",
    "botanicalAsset": "/assets/editorial/themes/india-botanical.webp",
    "slug": "india",
    "headlineSource": "rowe"
  },
  {
    "id": 5,
    "title": "Italy",
    "status": "ready",
    "hero": "/assets/editorial/themes/italy.webp",
    "botanical": "Cypress and laurel",
    "secondaryMotif": "Architectural sketch and marble fragment",
    "artDirection": "Tuscan landscape and Florence dome",
    "paper": "/assets/editorial/paper-note.png",
    "note": "Stone holds the light. / The hills remember.",
    "botanicalAsset": "/assets/editorial/themes/italy-botanical.webp",
    "slug": "italy",
    "headlineSource": "rowe"
  },
  {
    "id": 6,
    "title": "Visiting Paris",
    "status": "ready",
    "hero": "/assets/editorial/themes/visiting-paris.webp",
    "botanical": "Plane-tree leaves",
    "secondaryMotif": "Metro ticket and street map",
    "artDirection": "Paris streets and Seine bookstalls",
    "paper": "/assets/editorial/paper-note.png",
    "note": "A stranger arrives. / The city unfolds.",
    "botanicalAsset": "/assets/editorial/themes/visiting-paris-botanical.webp",
    "slug": "visiting-paris",
    "headlineSource": "rowe"
  },
  {
    "id": 7,
    "title": "Twinhood",
    "status": "ready",
    "hero": "/assets/editorial/themes/twinhood.webp",
    "botanical": "Paired ginkgo stems",
    "secondaryMotif": "Paired photographic fragments",
    "artDirection": "Paired antique profiles and mirrored fragments",
    "paper": "/assets/editorial/paper-note.png",
    "note": "Two beginnings. / A shared echo.",
    "botanicalAsset": "/assets/editorial/themes/twinhood-botanical.webp",
    "slug": "twinhood",
    "headlineSource": "rowe"
  },
  {
    "id": 8,
    "title": "Poetry",
    "status": "ready",
    "hero": "/assets/editorial/themes/poetry.webp",
    "botanical": "Laurel",
    "secondaryMotif": "Printing type and manuscript",
    "artDirection": "Letterpress page and library light",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The same words. / Another constellation.",
    "botanicalAsset": "/assets/editorial/themes/poetry-botanical.webp",
    "slug": "poetry",
    "headlineSource": "rowe"
  },
  {
    "id": 9,
    "title": "Food and Drink",
    "status": "ready",
    "hero": "/assets/editorial/themes/food-and-drink.webp",
    "botanical": "Grape vine",
    "secondaryMotif": "Carafe and recipe fragment",
    "artDirection": "Pear, bread and wine in a quiet still life",
    "paper": "/assets/editorial/paper-note.png",
    "note": "A place at the table. / A moment to share.",
    "botanicalAsset": "/assets/editorial/themes/food-and-drink-botanical.webp",
    "slug": "food-and-drink",
    "headlineSource": "rowe"
  },
  {
    "id": 10,
    "title": "Death",
    "status": "ready",
    "hero": "/assets/editorial/themes/death.webp",
    "botanical": "Dried poppy",
    "secondaryMotif": "Hourglass and faded paper",
    "artDirection": "Weathered stone and a cypress grove",
    "paper": "/assets/editorial/paper-note.png",
    "note": "What passes / leaves a trace.",
    "botanicalAsset": "/assets/editorial/themes/death-botanical.webp",
    "slug": "death",
    "headlineSource": "rowe"
  },
  {
    "id": 11,
    "title": "Fashion",
    "status": "ready",
    "hero": "/assets/editorial/themes/fashion.webp",
    "botanical": "Flax",
    "secondaryMotif": "Pattern paper and fashion engraving",
    "artDirection": "Tailoring and draped linen",
    "paper": "/assets/editorial/paper-note.png",
    "note": "A line, a fold. / Another way to be.",
    "botanicalAsset": "/assets/editorial/themes/fashion-botanical.webp",
    "slug": "fashion",
    "headlineSource": "editorial"
  },
  {
    "id": 12,
    "title": "Climate & Environment",
    "status": "ready",
    "hero": "/assets/editorial/themes/climate-and-environment.webp",
    "botanical": "Alpine wildflowers",
    "secondaryMotif": "Contour-map fragment and bee",
    "artDirection": "Glacier, alpine lake and weathered mountains",
    "paper": "/assets/editorial/paper-note.png",
    "note": "The weather turns. / The page remains.",
    "botanicalAsset": "/assets/editorial/themes/climate-and-environment-botanical.webp",
    "slug": "climate-and-environment",
    "headlineSource": "editorial"
  }
];
export const previewThemes = themes;
