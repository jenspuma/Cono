# Editorial / Literary redesign

Reference: `design/mockups/concept-1-editorial-clean-final.png`, supplied in
`cono-mockups-originals.zip`. The other four supplied mockups are retained for context.
The archive did not contain the previously generated standalone assets.

The page uses a warm off-white surface, a centered French title and short subtitle,
three round playback controls, fourteen independently editable lines, and a native
About / Credits disclosure. Combination counts and historical context appear only
inside the disclosure. The poem and all controls remain live HTML, not image text.
Decorative margin content is hidden from assistive technology; touch layouts remove
side decorations, wrap full poem lines, and retain visible line controls. Keyboard
focus and reduced-motion preferences are supported.

## Assets

Generated with the built-in ImageGen tool using the clean final mockup as reference
for the landscape and olive sprig. Full prompts are in `prompts.md`.

- `web/static/assets/editorial/landscape.png`: straight rectangular matte landscape.
- `web/static/assets/editorial/paper-note.png`: separate subtle ivory paper texture.
- `web/static/assets/editorial/botanical-sprig.png`: olive sprig with an alpha channel.

The original media and lyrics are unchanged. The title is set in the system's
Baskerville when available, with Times New Roman as fallback; no remote font service.

## Validation and remaining review

Local working tree: Svelte check passed with zero errors or warnings; seven audio
regression tests passed; production build passed. Existing uncommitted audio-loop
work was present before this redesign and is preserved independently.

Browser visual and interaction review is **not completed**: the app browser refused
access to the local preview because its admin policy check was unavailable (two
attempts). Do not treat the CSS implementation as a verified pixel match. Desktop,
mobile, long-line wrapping, asset transparency/compositing and playback controls
still need visual review against the supplied clean final mockup.

The isolated commit candidate was also checked against the committed audio engine:
Svelte check passed with zero diagnostics, all six committed audio tests passed,
and the static production build passed with the three new assets included.

## Owner acceptance — 2026-09-19

The owner tested the updated edition and approved it as releasable. This supersedes
the pending visual review above; it is manual owner acceptance, not an automated
browser verification. The previously local audio-loop changes are now included
in the release candidate together with their seven passing tests.
