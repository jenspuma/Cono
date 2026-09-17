<script lang="ts">
  import { onMount } from 'svelte';
  import { base } from '$app/paths';
  import { ConoAudioEngine } from '$lib/audio/ConoAudioEngine';

  const engine = new ConoAudioEngine();

  let poems: string[][] = [];
  let selections = Array.from({ length: 14 }, () => Math.floor(Math.random() * 12));
  let loading = true;
  let loadedAudio = 0;
  let audioTotal = 13;
  let error = '';
  let isPlaying = false;
  let currentLine = -1;
  let mounted = false;

  onMount(() => {
    mounted = true;
    void load();
    return () => { mounted = false; engine.dispose(); };
  });

  async function load() {
    try {
      const lyricsResponse = await fetch('./assets/lyrics.xml');
      if (!lyricsResponse.ok) throw new Error('Could not load lyrics.xml');
      // The original XML is Windows-1252, not UTF-8.
      const xmlText = new TextDecoder('windows-1252').decode(await lyricsResponse.arrayBuffer());
      const xml = new DOMParser().parseFromString(xmlText, 'application/xml');
      poems = Array.from(xml.querySelectorAll('verse')).map((verse) =>
        Array.from(verse.querySelectorAll('line')).map((line) => line.textContent?.trim() ?? '')
      );

      if (poems.length !== 12 || poems.some((poem) => poem.length !== 14)) {
        throw new Error(`Unexpected lyric structure: ${poems.length} poems loaded`);
      }

      if (!mounted) return;
      await engine.load((loaded, total) => {
        loadedAudio = loaded;
        audioTotal = total;
      });
      loading = false;
    } catch (e) {
      error = e instanceof Error ? e.message : String(e);
      loading = false;
    }
  }

  function changeVerse(line: number, delta: number) {
    selections = selections.map((value, index) =>
      index === line ? Math.max(0, Math.min(11, value + delta)) : value
    );
    engine.updateSelections();
  }

  function randomize() {
    selections = selections.map(() => Math.floor(Math.random() * 12));
    engine.updateSelections();
  }

  async function play() {
    error = '';
    try {
      isPlaying = true;
      currentLine = -1;
      await engine.play(
        () => selections,
        (line) => (currentLine = line),
        () => {
          isPlaying = false;
          currentLine = -1;
        }
      );
    } catch (e) {
      error = e instanceof Error ? e.message : String(e);
      isPlaying = false;
    }
  }

  function stop() {
    engine.stop();
    isPlaying = false;
    currentLine = -1;
  }
</script>

<svelte:head>
  <title>Cono — modern prototype</title>
  <meta
    name="description"
    content="A modern browser prototype of Jens Brosbøl-Ravnborg's interactive musical rendition of Raymond Queneau's combinatorial poetry."
  />
</svelte:head>

<main class="stage">
  <section class="book" style:background-image={`url("${base}/assets/Book.png")`} aria-label="Interactive poem">
    <div class="controls top-controls">
      <button onclick={isPlaying ? stop : play} disabled={loading || !!error}>
        {isPlaying ? 'Stop' : 'Play'}
      </button>
      <button onclick={randomize} disabled={loading}>Randomize</button>
    </div>

    {#if loading}
      <div class="status">Loading music… {loadedAudio}/{audioTotal}</div>
    {:else if error}
      <div class="status error">{error}</div>
    {/if}

    <div class="poem">
      {#each selections as verseIndex, lineIndex}
        <div class:active={currentLine === lineIndex} class="line-row">
          <button
            class="step"
            aria-label={`Previous source poem for line ${lineIndex + 1}`}
            onclick={() => changeVerse(lineIndex, -1)}
            disabled={verseIndex === 0}
          >−</button>
          <span class="verse-number">{verseIndex + 1}</span>
          <span class="line-text">{poems[verseIndex]?.[lineIndex] ?? '…'}</span>
          <button
            class="step"
            aria-label={`Next source poem for line ${lineIndex + 1}`}
            onclick={() => changeVerse(lineIndex, 1)}
            disabled={verseIndex === 11}
          >+</button>
        </div>
      {/each}
    </div>

    <footer>
      <span>Original idea and poetry: Raymond Queneau</span>
      <span>Music and programming: Jens Brosbøl-Ravnborg</span>
    </footer>
  </section>
</main>

<style>
  :global(*) { box-sizing: border-box; }
  :global(html, body) { margin: 0; min-height: 100%; }
  :global(body) {
    font-family: Georgia, 'Times New Roman', serif;
    background: #272522;
    color: #2d2924;
  }
  button { font: inherit; }
  .stage {
    min-height: 100vh;
    display: grid;
    place-items: center;
    padding: 24px;
  }
  .book {
    position: relative;
    width: min(1108px, 100%);
    aspect-ratio: 1108 / 620;
    min-height: 620px;
    background-position: center;
    background-size: 100% 100%;
    background-repeat: no-repeat;
    box-shadow: 0 24px 70px rgb(0 0 0 / 0.38);
    overflow: hidden;
  }
  .poem {
    position: absolute;
    left: 51.5%;
    top: 8.9%;
    width: 46%;
  }
  .line-row {
    min-height: 31px;
    display: grid;
    grid-template-columns: 26px 26px 1fr 26px;
    align-items: center;
    gap: 3px;
    padding: 0 4px;
    font-size: clamp(11px, 1.25vw, 14px);
    transition: background 100ms ease, transform 100ms ease;
  }
  .line-row.active {
    background: rgb(255 249 218 / 0.62);
    transform: translateX(-2px);
  }
  .step {
    appearance: none;
    border: 0;
    background: transparent;
    cursor: pointer;
    opacity: 0;
    font-size: 19px;
    line-height: 1;
  }
  .line-row:hover .step,
  .line-row:focus-within .step { opacity: 0.72; }
  .step:disabled { cursor: default; opacity: 0 !important; }
  .verse-number { font-size: 0.9em; opacity: 0.75; }
  .line-text { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .controls {
    position: absolute;
    display: flex;
    gap: 10px;
    z-index: 2;
  }
  .top-controls { right: 28px; bottom: 24px; }
  .controls button {
    border: 0;
    padding: 5px 8px;
    background: rgb(255 255 255 / 0.25);
    color: inherit;
    cursor: pointer;
    font-size: 11px;
  }
  .controls button:hover { background: rgb(255 255 255 / 0.5); }
  .controls button:disabled { opacity: 0.4; cursor: default; }
  .status {
    position: absolute;
    inset: 50% auto auto 50%;
    transform: translate(-50%, -50%);
    padding: 18px 24px;
    background: rgb(245 239 222 / 0.9);
    box-shadow: 0 4px 18px rgb(0 0 0 / 0.2);
    z-index: 3;
  }
  .status.error { color: #8c1e17; }
  footer {
    position: absolute;
    left: 30px;
    bottom: 22px;
    display: grid;
    gap: 3px;
    font-size: 10px;
    opacity: 0.55;
  }
  @media (max-width: 800px) {
    .stage { padding: 0; align-items: start; }
    .book {
      min-height: 100vh;
      aspect-ratio: auto;
      background-size: cover;
      background-position: center;
    }
    .poem {
      position: relative;
      left: auto;
      top: auto;
      width: auto;
      margin: 18vh 7vw 120px;
      padding: 18px;
      background: rgb(246 238 213 / 0.82);
    }
    .line-row {
      grid-template-columns: 32px 28px 1fr 32px;
      min-height: 36px;
      font-size: 14px;
    }
    .step { opacity: 0.55; }
    .line-text { white-space: normal; }
  }
</style>
