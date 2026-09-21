<script lang="ts">
  import { onMount } from 'svelte';
  import { base } from '$app/paths';
  import { ConoAudioEngine } from '$lib/audio/ConoAudioEngine';

  import { themes, previewThemes } from '$lib/themes';

  let previewId: number | null = null;
  $: theme = themes[previewId !== null ? previewId - 1 : selections[currentLine >= 0 ? currentLine : 0]];

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
        (nextSelections) => (selections = nextSelections)
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
  <title>Cent mille milliards de poèmes</title>
  <meta name="description" content="An interactive musical interpretation of Raymond Queneau’s combinatorial poem, with music by Jens Brosbøl-Ravnborg." />
</svelte:head>

<main class="stage">
  <article class="edition" aria-label="Interactive musical poem">
    <div class="margin-label left-label" aria-hidden="true">Poetry<br />Music<br />Algorithms</div>
    <div class="margin-label right-label" aria-hidden="true">Same<br />words<br />new<br />worlds<span class="small-rule"></span></div>

    <header>
      <h1 lang="fr">Cent mille milliards de poèmes</h1>
      <p class="subtitle">An interactive musical interpretation of Raymond Queneau’s combinatorial poem.</p>
    </header>

    <div class="controls" aria-label="Playback controls">
      <button class="transport play" onclick={play} disabled={loading || !!error || isPlaying} aria-label="Play">
        <span class="control-disc"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="m8 4 12 8-12 8Z" fill="currentColor" /></svg></span><span>Play</span>
      </button>
      <button class="transport" onclick={stop} disabled={!isPlaying} aria-label="Stop">
        <span class="control-disc"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 5h14v14H5z" fill="currentColor" /></svg></span><span>Stop</span>
      </button>
      <button class="transport" onclick={randomize} disabled={loading} aria-label="Randomize">
        <span class="control-disc"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 6h3c4 0 8 12 12 12h3m-4-4 4 4-4 4M3 18h3c1.5 0 3-1.7 4.5-4M14 8c1.4-1.3 2.6-2 4-2h3m-4-4 4 4-4 4" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" /></svg></span><span>Randomize</span>
      </button>
    </div>

    <div class="status" role="status">
      {#if loading}Loading music… {loadedAudio}/{audioTotal}{:else if error}<span class="error">{error}</span>{/if}
    </div>

    <aside class="landscape-collage" aria-label="Visual theme">
      <h2 class="theme-heading"><span>{String(theme.id).padStart(2, '0')} —</span> {theme.title}</h2>
      <div class="artwork-frame">
        {#each themes as artwork (artwork.id)}
          <img class="landscape artwork-layer" class:visible={theme.id === artwork.id} src={`${base}${artwork.hero}`} alt={theme.id === artwork.id ? `${artwork.artDirection}; ${artwork.secondaryMotif}.` : ''} aria-hidden={theme.id !== artwork.id} width="1024" height="1536" />
        {/each}
      </div>
      <div class="paper-note" style:background-image={`url('${base}${theme.paper}')`} aria-hidden="true">
        <p>{#each theme.note.split(' / ') as line}{line}<br />{/each}</p><span class="small-rule"></span>
      </div>
      <details class="visual-preview">
        <summary>Explore artwork</summary>
        <div class="theme-options" aria-label="Artwork preview">
          <button class:selected={previewId === null} aria-pressed={previewId === null} onclick={() => previewId = null}>Follow music</button>
          {#each previewThemes as item}
            <button class:selected={previewId === item.id} aria-pressed={previewId === item.id} onclick={() => previewId = item.id}>{String(item.id).padStart(2, '0')} — {item.title}</button>
          {/each}
        </div>
        <p>Artwork only. Your poem stays the same.</p>
      </details>
    </aside>

    <section class="poem" aria-label="Fourteen lines of the poem">
      {#each selections as verseIndex, lineIndex}
        <div class="line-row" class:active={currentLine === lineIndex} aria-current={currentLine === lineIndex ? 'true' : undefined}>
          <span class="line-number" aria-label={`Source poem ${verseIndex + 1}`}>{String(verseIndex + 1).padStart(2, '0')}</span>
          <button class="step" aria-label={`Previous source poem for line ${lineIndex + 1}`} title={`Source poem ${verseIndex + 1} of 12`} onclick={() => changeVerse(lineIndex, -1)} disabled={loading || verseIndex === 0}>
            <svg viewBox="0 0 16 24" aria-hidden="true"><path d="m10 5-4 7 4 7" /></svg>
          </button>
          <span class="line-text">{poems[verseIndex]?.[lineIndex] ?? '…'}</span>
          <button class="step" aria-label={`Next source poem for line ${lineIndex + 1}`} title={`Source poem ${verseIndex + 1} of 12`} onclick={() => changeVerse(lineIndex, 1)} disabled={loading || verseIndex === 11}>
            <svg viewBox="0 0 16 24" aria-hidden="true"><path d="m6 5 4 7-4 7" /></svg>
          </button>
        </div>
      {/each}
    </section>

    <aside class="botanical" aria-hidden="true">
      <p>A constellation<br />of verses,<br />a universe<br />of listening.</p><span class="small-rule"></span>
      <div class="botanical-frame">
        {#each themes as artwork (artwork.id)}
          <img class="artwork-layer" class:visible={theme.id === artwork.id} src={`${base}${artwork.botanicalAsset}`} alt="" width="1024" height="1536" />
        {/each}
      </div>
      <span class="source-caption">{String(theme.id).padStart(2, '0')} / 12<br />{theme.title}</span>
    </aside>

    <details class="about">
      <summary><span>About / Credits</span></summary>
      <div class="about-content">
        <section>
          <h2>About the work</h2>
          <p><i lang="fr">Cent mille milliards de poèmes</i> is a work by Raymond Queneau, first published in 1961. Its ten sonnets each have fourteen interchangeable lines, allowing the reader to construct 10¹⁴ poems — 100,000,000,000,000 possible combinations.</p>
          <p>This interactive musical interpretation gives each line a recorded vocal performance. As the selected lines change, the music continues, creating a changing relationship between language and sound.</p>
          <h2>Visual themes</h2>
          <p>The first ten theme headlines follow Beverley Charles Rowe’s stated themes for the original sonnets. Fashion and Climate &amp; Environment are provisional editorial labels for the two additional English-version sonnets. The collages are visual interpretations of these themes.</p>
          <ol class="theme-index">{#each themes as item}<li>{item.title}</li>{/each}</ol>
          <h2>The English version</h2>
          <p>This edition uses Beverley Charles Rowe’s English translation, including two additional verse sets. Twelve alternatives for each of fourteen lines allow 12¹⁴, or 1,283,918,464,548,864, different poems.</p>
        </section>
        <section>
          <h2>Credits</h2>
          <dl>
            <dt>Original work</dt><dd>Raymond Queneau<br /><i lang="fr">Cent mille milliards de poèmes</i>, 1961</dd>
            <dt>English translation</dt><dd>Beverley Charles Rowe</dd>
            <dt>Musical interpretation, vocals, instruments, recording and programming</dt><dd>Jens Brosbøl-Ravnborg</dd>
            <dt>Project name</dt><dd>Cono</dd>
          </dl>
        </section>
      </div>
    </details>
  </article>
</main>

<style>
  :global(*) { box-sizing: border-box; }
  :global(html) { color-scheme: light; }
  :global(body) { margin: 0; background: #eeece7; color: #343632; font-family: 'Baskerville', 'Times New Roman', serif; -webkit-font-smoothing: antialiased; }
  button { font: inherit; color: inherit; }
  button, summary { -webkit-tap-highlight-color: transparent; }
  button:focus-visible, summary:focus-visible { outline: 2px solid #666f58; outline-offset: 5px; border-radius: 4px; }
  .stage { padding: 28px; min-height: 100svh; }
  .edition { position: relative; isolation: isolate; max-width: 1440px; margin: 0 auto; min-height: calc(100svh - 56px); padding: 34px 0 28px; overflow: hidden; border-radius: 10px; background: #fbfaf6; box-shadow: 0 12px 32px #39332508; }
  header { text-align: center; margin: 0 auto; width: 76%; }
  h1 { margin: 0; color: #171b17; font-size: clamp(32px, 4.2vw, 62px); line-height: 1.12; font-weight: 400; letter-spacing: -.045em; }
  .subtitle { margin: 10px 0 0; font-size: clamp(15px, 1.45vw, 20px); line-height: 1.4; }
  .margin-label { position: absolute; font-size: 10px; letter-spacing: .3em; line-height: 1.9; text-transform: uppercase; }
  .left-label { top: 44px; left: 3.3%; }
  .right-label { top: 44px; right: 3.3%; text-align: right; }
  .small-rule { display: block; width: 32px; height: 1px; margin-top: 22px; background: #92958b; }
  .right-label .small-rule { margin-left: auto; width: 24px; margin-top: 14px; }
  .controls { display: flex; justify-content: center; gap: 38px; margin: 25px 0 0; font-family: Arial, sans-serif; }
  .transport { display: grid; justify-items: center; gap: 10px; background: transparent; border: 0; padding: 0; font-size: 15px; cursor: pointer; }
  .control-disc { display: grid; place-items: center; width: 58px; height: 58px; border-radius: 50%; background: #ebe9e4; transition: background .15s, transform .15s; }
  .control-disc svg { width: 25px; height: 25px; }
  .play .control-disc { background: #303734; color: #fffefa; }
  .transport:hover:not(:disabled) .control-disc { background: #dcded3; transform: translateY(-2px); }
  .play:hover:not(:disabled) .control-disc { background: #4e584d; }
  .transport:disabled { cursor: default; }
  .transport:disabled .control-disc svg { opacity: .38; }
  .status { min-height: 28px; padding: 6px 20px 3px; text-align: center; font: 12px/1.5 Arial, sans-serif; color: #6c7067; }
  .error { color: #963d32; }
  .poem { position: relative; z-index: 1; width: 57%; margin: 0 auto; }
  .line-row { display: grid; grid-template-columns: 36px 30px minmax(0, 1fr) 30px; gap: 10px; align-items: center; min-height: 40px; padding: 3px 16px; border-radius: 5px; transition: background .15s; }
  .line-row.active { background: #f3e8d9; }
  .line-number { font-size: 14px; letter-spacing: .08em; font-variant-numeric: tabular-nums; }
  .line-text { font-size: clamp(18px, 1.65vw, 24px); line-height: 1.45; }
  .step { display: grid; place-items: center; width: 30px; min-height: 32px; border: 0; background: transparent; cursor: pointer; opacity: .65; border-radius: 4px; }
  .step svg { width: 13px; height: 21px; fill: none; stroke: currentColor; stroke-width: 1.4; }
  .step:hover:not(:disabled) { background: #eae6dc; opacity: 1; }
  .step:disabled { opacity: .18; cursor: default; }
  .landscape-collage { position: absolute; left: 2.6%; top: 235px; width: 17%; }
  .theme-heading { margin: 0 0 16px; height: 60px; font-size: 21px; font-weight: 400; line-height: 1.25; text-wrap: balance; }
  .theme-heading span { white-space: nowrap; }
  .artwork-frame { position: relative; aspect-ratio: 2 / 3; overflow: hidden; background: #f0ede5; }
  .landscape { display: block; width: 100%; height: 100%; object-fit: cover; }
  .paper-note { position: relative; margin: -4px 0 0 12%; min-height: 170px; padding: 32px 18px 24px; background-color: #f1eee6; background-size: cover; }
  .visual-preview { position: relative; margin-top: 20px; }
  .visual-preview summary { font: 10px/1.5 Arial, sans-serif; letter-spacing: .12em; text-transform: uppercase; gap: 8px; }
  .visual-preview summary::before { display: none; }
  .theme-options { position: absolute; bottom: 100%; width: 100%; max-height: 360px; overflow-y: auto; overscroll-behavior: contain; z-index: 3; display: grid; gap: 5px; padding: 8px; background: #fbfaf6; border: 1px solid #d6d2c5; box-shadow: 0 6px 20px #34363215; }
  .theme-options button { text-align: left; border: 1px solid transparent; background: transparent; padding: 7px; font-size: 13px; cursor: pointer; }
  .theme-options button.selected { background: #ebe8df; border-color: #d6d2c5; }
  .visual-preview > p { font: 10px/1.5 Arial, sans-serif; color: #62675b; }
  .source-caption { display: block; margin-top: 18px; font: 10px/1.8 Arial, sans-serif; letter-spacing: .12em; text-transform: uppercase; max-width: 120px; }
  .paper-note p, .botanical p { margin: 0; font-style: italic; letter-spacing: .1em; font-size: clamp(14px, 1.25vw, 18px); line-height: 1.4; }
  .artwork-layer { position: absolute; inset: 0; opacity: 0; transition: opacity 240ms ease-in-out; pointer-events: none; }
  .artwork-layer.visible { opacity: 1; }
  .botanical-frame { position: relative; height: 330px; margin: 40px 0 0 -15%; }
  .botanical-frame img { width: 100%; height: 100%; object-fit: contain; }
  .botanical { position: absolute; right: 0; top: 298px; width: 13%; pointer-events: none; }
  .about { position: relative; z-index: 2; width: 66%; margin: 95px auto 0; }
  summary { display: flex; align-items: center; gap: 28px; cursor: pointer; list-style: none; padding: 10px 0; font-size: 12px; letter-spacing: .32em; }
  summary::-webkit-details-marker { display: none; }
  summary::before, summary::after { content: ''; height: 1px; background: #c4c3b9; flex: 1; }
  summary:hover { color: #778064; }
  .about-content { display: grid; grid-template-columns: 1.3fr 1fr; gap: 50px; padding: 35px 0 20px; font-size: 17px; line-height: 1.6; }
  .about-content h2 { margin: 0 0 12px; font-weight: 400; font-size: 25px; }
  .about-content p { margin: 0 0 24px; }
  .theme-index { columns: 2; padding-left: 24px; margin: 0 0 26px; font-size: 15px; }
  .theme-index li { break-inside: avoid; padding: 3px 0; }
  dl { margin: 0; }
  dt { font: 11px/1.6 Arial, sans-serif; text-transform: uppercase; letter-spacing: .07em; color: #666b5f; }
  dd { margin: 4px 0 22px; }
  @media (min-width: 1500px) { .line-text { font-size: 24px; } }
  @media (max-width: 1100px) {
    .stage { padding: 18px; }
    .edition { min-height: calc(100svh - 36px); }
    header { width: 72%; }
    .margin-label { font-size: 8px; }
    .poem { width: 65%; margin-left: 19%; }
    .line-row { grid-template-columns: 27px 24px minmax(0, 1fr) 24px; gap: 5px; padding-inline: 8px; }
    .step { width: 24px; }
    .botanical { width: 11%; }
    .botanical p { font-size: 13px; }
    .paper-note { padding: 28px 12px; }
    .theme-heading { font-size: 18px; height: 68px; }
    .paper-note p { font-size: 13px; }
  }
  @media (max-width: 760px) {
    .stage { padding: 10px; }
    .edition { padding: 32px 16px 20px; min-height: calc(100svh - 20px); }
    header { width: 100%; }
    h1 { font-size: clamp(33px, 6.6vw, 48px); max-width: 560px; margin: auto; }
    .subtitle { max-width: 450px; margin: 14px auto 0; font-size: 16px; }
    .left-label, .right-label, .botanical { display: none; }
    .controls { gap: 30px; margin-top: 24px; }
    .control-disc { width: 50px; height: 50px; }
    .transport { font-size: 13px; }
    .poem { width: 100%; margin: 0; }
    .line-row { grid-template-columns: 22px 28px minmax(0, 1fr) 28px; gap: 4px; min-height: 46px; padding: 3px 0; }
    .step { width: 28px; min-height: 40px; }
    .line-text { font-size: 19px; line-height: 1.4; }
    .line-number { font-size: 11px; }
    .landscape-collage { position: relative; left: auto; top: auto; width: 100%; max-width: 450px; margin: 18px auto 30px; display: grid; grid-template-columns: 1fr 1fr; column-gap: 16px; }
    .theme-heading { grid-column: 1 / -1; height: 60px; margin-bottom: 10px; font-size: 22px; }
    .artwork-frame { grid-column: 1; grid-row: 2; }
    .paper-note { grid-column: 2; grid-row: 2; margin: 20px 0 0; align-self: start; min-height: 140px; padding: 25px 14px; }
    .visual-preview { grid-column: 1 / -1; margin-top: 10px; }
    .theme-options { grid-template-columns: 1fr 1fr; }

    .about { width: 100%; margin-top: 38px; }
    summary { gap: 16px; font-size: 11px; letter-spacing: .22em; }
    .about-content { grid-template-columns: 1fr; gap: 12px; padding: 28px 8px 0; }
  }
  @media (prefers-reduced-motion: reduce) { *, *::before, *::after { transition: none !important; } }
</style>
