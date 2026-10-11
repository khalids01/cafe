# Handoff — tutorial videos 31–43

Updated 2026-10-11. All 13 videos have Heart/Kokoro audio, synchronized capture,
final MP4, captions, poster, timeline and render receipts. Upload metadata is
prepared, and the upload ledger records them as rendered. No YouTube uploads,
Guide publication or commits were performed during this run.

## Final videos

| Folder | Run ID | Duration |
| --- | --- | --- |
| 31-courier-cod-collections | 2026-10-11T09-52-27-392Z-synchronized | 62.65 s |
| 32-store-settings | 2026-10-11T09-50-33-382Z-synchronized | 62.25 s |
| 33-store-page-seo | 2026-10-11T09-51-18-117Z-synchronized | 62.22 s |
| 34-image-library | 2026-10-11T09-53-09-642Z-synchronized | 61.35 s |
| 35-customer-records | 2026-10-11T09-54-24-603Z-synchronized | 58.02 s |
| 36-users-invitations | 2026-10-11T09-55-18-759Z-synchronized | 66.39 s |
| 37-roles-permissions | 2026-10-11T09-58-36-769Z-synchronized | 64.52 s |
| 38-feedback-moderation | 2026-10-11T09-59-50-255Z-synchronized | 60.95 s |
| 39-visitor-analytics | 2026-10-11T10-12-21-191Z-synchronized | 64.09 s |
| 40-activity-audit | 2026-10-11T10-03-59-520Z-synchronized | 63.39 s |
| 41-rate-limit-settings | 2026-10-11T10-05-19-968Z-synchronized | 67.25 s |
| 42-webhook-events | 2026-10-11T10-06-37-442Z-synchronized | 65.19 s |
| 43-discount-codes | 2026-10-11T10-08-49-323Z-synchronized | 61.12 s |

For each folder, use `artifacts/last-render.json` to locate the current final
`artifacts/<Run ID>/render/video.mp4`. Media and local receipts are gitignored:
a Git clone does not contain these videos. Keep a separate backup of artifacts.

## Checks and review

- All 13 video hashes match their receipts and current canonical plan hashes.
- Audio and video streams are present; durations match render receipts.
- Full ffmpeg decode passed for every video without errors.
- All 244 encoded boundary comparisons passed; minimum SSIM 0.999264.
- Captured frames were visually inspected, including the full chart in 39.
- `bun run tutorial:check` passed all 43 focused packages and the retained workflow.
- Unlisted upload metadata was prepared without contacting YouTube.

Full listening/playback review remains pending. Review acceptance flags remain
false; automated checks and screenshot inspection do not approve publication.
Only tutorials 01–02 currently have accepted Guide publication.

## Production details

Voicebox was reached through the existing SSH tunnel at localhost:17493. Audio
requests were processed one section at a time, waiting for generation and download
before the next request. Cached audio was reused for capture retries.

Captures used built AirShop assets under NODE_ENV=test, the isolated local
recording database/Redis, disabled courier workers and disabled Polar. The web
was rebuilt after fixing the roles parent route to render its detail outlet;
previously the permissions page stayed on the roles list. That application fix
is included in the source changes.

Plans now target unique COD section headings (31), the complete visitor chart
(39), the actual event filter (40), and the actual Discount code button (43).
Production Markdown and storyboard JSON were regenerated from these plans.

Fictional records supplied customer, role, feedback, activity, webhook and COD
examples. The COD delivery state was prepared locally; no live courier booking
or provider acceptance is claimed. The image library used a local GET-only
fictional SVG fixture service, not a real file provider. These walkthroughs
explain controls and prepared records; they do not execute all narrated business
writes. Tutorial 35 intentionally shows an empty fictional customer history.

Marker-owned fixtures created during this run were removed and checked for
remaining records. Existing courier-lab fixtures from prior work were preserved.
Our API/web/image fixture servers were stopped; ports 3000, 3001 and 4300 were
free afterward. The Voicebox tunnel and existing DB/Redis were left running.
No dependencies were installed.

Reusable fixture helpers: `31-courier-cod-collections/fixtures.ts`,
`shared/admin-fixtures.ts` and `34-image-library/file-fixture.ts`.
Run only against the guarded isolated test environment; see folder instructions.

## Upload later

To upload specifically 31–43, sequentially:

```bash
for id in courier-cod-collections store-settings store-page-seo image-library customer-records users-invitations roles-permissions feedback-moderation visitor-analytics activity-audit rate-limit-settings webhook-events discount-codes; do
  bun --env-file=apps/server/.env tutorial/shared/youtube-upload.ts "$id" --visibility=unlisted --upload || break
done
bun run tutorial:uploads:status
bun run tutorial:guides:sync
```

Stop on quota or upload errors and inspect saved receipts before retrying. Existing
receipts prevent duplicate uploads. Stored YouTube authorization and Redis must
be available; recording servers, fixtures and Voicebox are not needed to upload.
Guide sync preserves pending playback review.

Alternatively, `bun run tutorial:uploads:batch --max=5 --upload` chooses the next
pending videos in catalog order. Tutorials 22–30 are still pending, so a batch
will start there before 31. Current totals: 21 uploaded and 22 ready for upload.
