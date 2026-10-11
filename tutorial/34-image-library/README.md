# Upload, find and reuse images

- Configured isolated file server and approved fictional image assets.

## Generation files

- `production.json`: sentence-aligned narration, exact screen setup, spotlight and evidence checks.
- `production.md`: readable version of those sections, for reviewing before production.
- `produce.ts`: shared synchronized producer, following the accepted tutorial 01 approach.
- `tutorial.json`, `narration.txt`: canonical narration and scene grouping.
- `fixtures.example.json`: fictional data contract; copy to ignored `fixtures.local.json` and supply isolated values/checks.
- `record.ts`, `render.ts`: entry points for synchronized capture/render, also used by the root CLI.

## Commands (run later, separately authorized)

```bash
# Offline plan inspection only; creates no audio or video:
bun tutorial/34-image-library/produce.ts prepare

# Future production, after reviewing the plan and prerequisites:
TUTORIAL_AUDIO_APPROVED=true bun tutorial/34-image-library/produce.ts audio
TUTORIAL_RECORD_APPROVED=true bun run tutorial:record image-library
TUTORIAL_RENDER_APPROVED=true bun run tutorial:render image-library
```

The capture command expects the existing production app, the correct `BRAND`, isolated environment variables, disabled integrations and the fictional owner session. It never builds, starts a server, provisions fixtures or installs tools. See [shared production instructions](../synchronized-production.readme.md).

Mode: **walkthrough**. Business writes are blocked. Saving, refunding, booking, inviting or other state changes are explained through their controls and pre-existing fictional records. A walkthrough does not claim to prove an unsubmitted operation.

Before production, review `production.md` and `recording-checklist.md`, prepare the required fictional state and check every target against the running app. After generation, watch the entire video with audio and review captions before marking its artifact approved. Source inspection cannot establish runtime accuracy.

## Read-only image fixture used for recording

`bun tutorial/34-image-library/file-fixture.ts` serves one fictional image at
`127.0.0.1:4300`. It supports GET only and never uploads files. Start the isolated
API with `FILE_SERVER_URL` and `FILE_SERVER_PUBLIC_URL` set to that local origin,
and `FILE_SERVER_API_KEY=tutorial-local-only`; disable integrations and retain the
validated test environment. Stop this fixture service after capture. The producer
blocks browser business writes, so selecting a file demonstrates its preview
without submitting an upload. This fixture does not establish real file-server
upload success.
