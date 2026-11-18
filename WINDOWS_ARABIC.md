# CouchSubs Arabic — Windows 11 / PS5 / LG webOS

This is the **experimental** English-to-Arabic Windows build in branch `feature/arabic-windows`.
It is separate from the Mac branch `feature/arabic-gemini-webos`; do not merge the branches just to install either application.

## What changed

- Adds **Subtitle language → العربية (Arabic)** under Settings → Language.
- For Arabic, cloud AI models (Gemini, OpenAI, Claude) or a compatible local AI model translate English game subtitles. The Turkish offline Marian translation model is *not* an Arabic fallback.
- Arabic and Turkish Gemini prompts and translation cache entries are separated. Game subtitle names and line breaks are preserved.
- Disables Turkish game packs and Turkish crowd-sourced text contributions while Arabic is selected.
- Keeps LG/webOS RTL subtitle handling from the existing Arabic branch.
- Disables the original application's auto-updater on Windows to prevent replacing the Arabic fork with the upstream Turkish release.

## Install and configure (once a Windows build is available)

1. On the Windows 11 laptop, install a trusted Windows build produced from **this exact branch**. Never enter GitHub passwords in the app.
2. In **Settings → Language**, choose English for **Game language** and **العربية (Arabic)** for **Subtitle language**.
3. In **Settings → Translation**, choose Google Gemini and add/test **the laptop owner's own** Gemini API key. Do not share or embed another person's API key in an installer.
4. Pair the laptop's CouchSubs with the owner's PS5 using a second PSN account, following the normal CouchSubs Remote Play setup.
5. Enable LG webOS Developer Mode if required, pair the TV and install the Arabic RTL TV overlay package. Confirm the TV displays Arabic with the built-in test subtitle.
6. Test a real game with English dialogue subtitles enabled. Turn off sound-effect/closed-caption descriptions in the game when separate controls are available.

## Windows build

The existing `.github/workflows/windows.yml` GitHub Actions workflow now includes this branch in its `push` triggers. If GitHub Actions is enabled on the fork and the workflow succeeds, the run uploads an artifact named **couchsubs-windows-installer** containing **CouchSubs-windows-Setup.exe**.

You can get artifacts from the repository's **Actions → windows → latest successful run for feature/arabic-windows → Artifacts**.
Do not distribute the installer until a successful Windows build, test run, and on-device Arabic/TV smoke test are confirmed. You can share the artifact privately as a ZIP or publish a signed/verifiable fork-specific GitHub Release later.

## Limitations

- **This source update has not yet been validated on an actual Windows 11 laptop**, PS5, or LG TV.
- Arabic currently needs an operational AI engine (typically Gemini). The original offline Windows model only supports Turkish; an offline Arabic fallback is not bundled.
- UI remains mainly English. Voice dubbing, Turkish translation packs, and other Turkish-only features are not translated to Arabic.
- GitHub Actions may need to be enabled on this fork. Pushing source does not itself prove the installer was built.
- Project license remains AGPL-3.0-only. Preserve its license and attribution when distributing copies.
