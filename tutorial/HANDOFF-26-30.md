# Handoff — tutorial videos 26–30

Updated 2026-10-11. All five videos have audio, production capture, final MP4,
poster, captions, timeline and render receipts. The upload ledger now records
these as `rendered`, ready for later upload. No upload or Guide publication was
performed during this completion pass.

## Videos

| Folder | Run ID | Duration |
| --- | --- | --- |
| 26-courier-connections | 2026-10-11T07-36-56-855Z-synchronized | 63.79 s |
| 27-courier-delivery-options | 2026-10-11T07-37-56-803Z-synchronized | 59.92 s |
| 28-courier-assignment-rules | 2026-10-11T07-38-20-679Z-synchronized | 62.49 s |
| 29-courier-shipments | 2026-10-11T07-38-39-378Z-synchronized | 60.82 s |
| 30-courier-returns | 2026-10-11T07-38-51-469Z-synchronized | 62.19 s |

For each folder, the current final file is
`artifacts/<Run ID>/render/video.mp4`; use `artifacts/last-render.json` as the
canonical pointer. Media and local receipts are gitignored and remain on this PC;
a clone of the committed repository does not contain the videos.

## Checks

- Actual video hashes match the saved render receipts and current plans match
  the ledger's checks.
- All five videos contain H.264 video and AAC audio.
- Full ffmpeg decoding passed for all five without errors.
- Captured frames were visually inspected; saved boundary SSIM scores are above
  0.9995.
- `bun run tutorial:check` passed all 43 focused packages and the legacy workflow.
- Per-video upload metadata was prepared without contacting YouTube.

Full listening/playback review is still pending. `watchedWithAudio`,
`actionsMatchNarration`, `captionsChecked` and `approved` remain false. These videos
can be uploaded unlisted for review; Guide publication requires user acceptance.
Automated checks and screenshots do not constitute that acceptance.

## Upload later

From the repository root, to upload specifically these five:

```bash
for id in courier-connections courier-delivery-options courier-assignment-rules courier-shipments courier-returns; do
  bun --env-file=apps/server/.env tutorial/shared/youtube-upload.ts "$id" --visibility=unlisted --upload || break
done
bun run tutorial:guides:sync
```

Existing receipts prevent duplicate uploads. Stop on a YouTube error and inspect
its saved attempt before retrying. The stored YouTube authorization and Redis
must be available; Voicebox, browser, API/web servers and recording fixtures are
not required for upload. Do not remove upload locks without checking for an
active upload.

Alternatively `bun run tutorial:uploads:batch --max=5 --upload` uploads the next
five pending videos in catalog order. Tutorials 22–25 are also pending, so this
command does not start at 26 until earlier pending uploads are complete.

## Capture corrections and fixture limitations

27–30 target unique section `h2` elements instead of ambiguous duplicate headings.
Canonical recording plans and production instructions include these corrections.

The previous agent used the isolated test database, disabled courier workers and
Polar, and fictional marker `tutorial-courier-lab`. Courier health was set directly
for prepared examples; no real connection-health check or successful provider
booking is established. Do not call live provider endpoints to validate these
examples. Some fixture records remain in the isolated database according to the
previous handoff; this completion pass did not query or modify that database.

The previous capture used a built AirShop UI under `NODE_ENV=test`; that is capture
configuration, not a production deployment instruction. Future capture requires
matching build/runtime brand and validated isolated environment. Use the shared
synchronized producer and guarded fixture preparation. No regeneration is needed
to upload the existing files.
