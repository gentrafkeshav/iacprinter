/*
# IACPrinter — Windows Installer Build Guide
### (Full reference: how we built and shipped the Windows .exe installer)

This is your complete "next time" reference. Everything below is exactly what we did — same account, same repo, same files. Follow top to bottom whenever you need to build a new Windows installer for your client.

---

## Your Project Details (fixed values — don't change unless project changes)

| Item | Value |
|---|---|
| GitHub username | `gentrafkeshav` |
| GitHub repo name | `iacprinter` |
| Repo URL | `https://github.com/gentrafkeshav/iacprinter.git` |
| Repo visibility | Private |
| Flutter project folder (on Mac) | `/Users/mac/Documents/fltrPrjct/ApplicationSquare/IAC_Printer/iacprinter` |
| Windows exe binary name | `iacprinter.exe` |
| Installer output name | `IACPrinter_Setup.exe` |
| GitHub Actions workflow name | `Build Windows Installer` |
| Workflow file path | `.github/workflows/windows-build.yml` |
| Installer script file | `installer.iss` (Inno Setup script, in project root) |

---

## ONE-TIME SETUP (already done — you never need to repeat this)

These are already complete for this project. Documented here only for reference/troubleshooting:

- ✅ GitHub account created (signed in via Google/Gmail)
- ✅ Private repo `iacprinter` created
- ✅ Personal Access Token created with `repo` + `workflow` scopes
- ✅ Project pushed to GitHub for the first time
- ✅ `.github/workflows/windows-build.yml` created (builds Flutter Windows app + packages installer)
- ✅ `installer.iss` created (Inno Setup script — defines how the installer looks/behaves)
- ✅ Windows runner pinned to `windows-2022` (to avoid a compiler bug on the newest runner)
- ✅ Fixed a typo: `recursesubdirs` (not `recursesubdir`) in installer.iss

**You do NOT need to redo any of the above next time.** Skip straight to "EVERY TIME YOU UPDATE THE APP" below.

---

## Reference: How the Personal Access Token was created (only needed if token expires or is lost)

Tokens expire (we set 90 days) or can be revoked. If GitHub ever rejects your push asking for auth and your saved token doesn't work anymore, create a new one:

1. Go to https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. Fill in:
   - **Note**: any label, e.g. `iacprinter-mac-v4`
   - **Expiration**: `90 days` (or longer if you prefer)
   - **Select scopes** — check these two boxes:
     - ☑️ **`repo`** (this auto-checks all sub-boxes under it — leave them all checked)
     - ☑️ **`workflow`** (separate checkbox, listed right below `repo` — REQUIRED because our project has a GitHub Actions workflow file; without this, pushes get rejected)
   - Leave everything else unchecked
4. Scroll down → click **Generate token**
5. Copy the token immediately (starts with `ghp_...`) and save it in your Notes app or a password manager. GitHub shows it only once — if you close the page without copying, you must generate a new one.

If your Mac has an old/expired token cached and keeps failing even after generating a new one, clear the cache first:

```bash
git credential-osxkeychain erase
```
Then type these two lines when prompted, followed by Enter on a blank line:
```
host=github.com
protocol=https
```

---

## EVERY TIME YOU UPDATE THE APP — Full Workflow

Do these steps in order. Assume you're starting fresh (project already exists on your Mac and is connected to GitHub — you don't repeat git init, remote add, etc.).

### STEP 1 — Open Terminal and go to your project folder

```bash
cd /Users/mac/Documents/fltrPrjct/ApplicationSquare/IAC_Printer/iacprinter
```

Confirm you're in the right place:
```bash
pwd
ls
```
You should see `pubspec.yaml`, `lib`, `windows`, `.github` etc.

### STEP 2 — Make your code changes

Edit your Flutter project as needed (in Android Studio, VS Code, or any editor). Test locally with:

```bash
flutter run -d chrome
```

(or your usual way of testing) until you're happy with the changes.

### STEP 3 — (Recommended) Bump the version number

Open `pubspec.yaml`, find this line near the top:

```yaml
version: 1.0.0+1
```

Increase it, e.g. to `1.0.1+2` (format is `versionName+versionCode`). This isn't mandatory, but it's good practice so you and your client can tell versions apart later. Save the file.

### STEP 4 — Check for secrets before committing (IMPORTANT — avoid the mistake we hit before)

Before adding files, quickly scan your changed files for anything that looks like a token, password, or API key hardcoded in code (e.g. `ghp_...`, API keys, passwords). GitHub will block the push if it detects one anyway, but it's faster to catch it yourself. Never hardcode tokens/passwords directly in `.dart` files — use environment variables or config files excluded via `.gitignore` instead.

### STEP 5 — Commit and push your changes

```bash
git add .
git commit -m "describe what you changed here"
git push
```

If it asks for username/password:
- **Username**: `gentrafkeshav`
- **Password**: paste your saved Personal Access Token (NOT your GitHub login password)

If push is rejected for any reason, read the error message carefully — it usually tells you exactly what's wrong (see Troubleshooting section below).

### STEP 6 — Trigger the Windows build on GitHub

1. Go to: https://github.com/gentrafkeshav/iacprinter/actions
2. In the left sidebar, click **Build Windows Installer**
3. Click the **Run workflow** dropdown (top right of the list) → confirm branch is `main` → click the green **Run workflow** button
4. A new run appears in the list (refresh page if it doesn't show immediately)
5. Click into it to watch progress — takes about **5–8 minutes**

### STEP 7 — Download the installer

Once the run shows a green ✅ (Success):

1. Scroll down on that run's page to the **Artifacts** section
2. Click **Windows-Installer** — downloads a `.zip` file to your Mac's Downloads folder
3. Unzip it — inside is **`IACPrinter_Setup.exe`**

### STEP 8 — Send to client

Send `IACPrinter_Setup.exe` to your client via email / Google Drive / WhatsApp / whatever you normally use.

Tell them:
1. Double-click the file to run it
2. If Windows shows a blue "Windows protected your PC" warning, click **More info** → **Run anyway** (this is normal for installers without a paid code-signing certificate — it does not mean anything is broken)
3. Click through the install wizard (Next → Next → Install)
4. The app launches automatically at the end; a Desktop shortcut and Start Menu entry are created
5. To uninstall in future, they can use normal Windows **Add or Remove Programs**

---

## Quick Command Summary (copy-paste block for a normal update)

Once you've made your code changes and tested locally, this is really all you need:

```bash
cd /Users/mac/Documents/fltrPrjct/ApplicationSquare/IAC_Printer/iacprinter
git add .
git commit -m "describe your change"
git push
```

Then go to GitHub → Actions tab → **Build Windows Installer** → **Run workflow** → wait → download from **Artifacts**.

---

## Reference: The two key files (do not delete these from your project)

### `.github/workflows/windows-build.yml`

```yaml
name: Build Windows Installer

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - run: flutter config --enable-windows-desktop
      - run: flutter pub get
      - run: flutter build windows --release

      - name: Install Inno Setup
        run: choco install innosetup -y

      - name: Compile Installer
        run: iscc installer.iss

      - uses: actions/upload-artifact@v4
        with:
          name: Windows-Installer
          path: Output/*.exe
```

### `installer.iss` (Inno Setup script — controls installer branding/behavior)

```ini
[Setup]
AppName=IACPrinter
AppVersion=1.0.0
DefaultDirName={autopf}\IACPrinter
DefaultGroupName=IACPrinter
OutputDir=Output
OutputBaseFilename=IACPrinter_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\IACPrinter"; Filename: "{app}\iacprinter.exe"
Name: "{commondesktop}\IACPrinter"; Filename: "{app}\iacprinter.exe"

[Run]
Filename: "{app}\iacprinter.exe"; Description: "Launch IACPrinter"; Flags: postinstall nowait skipifsilent
```

**If you ever want to change the version number shown to the client**, edit `AppVersion=1.0.0` in `installer.iss` before pushing (optional but tidy — update it alongside your `pubspec.yaml` version bump in Step 3).

**If you ever want a custom installer icon**, you can add a line under `[Setup]`:
```ini
SetupIconFile=assets\icon.ico
```
(You'd need an `.ico` file added to your assets first — ask if you want help generating one.)

---

## Troubleshooting — problems we actually hit, and their fixes

### "Push cannot contain secrets" / GH013 error
Means you accidentally committed a password/token/API key inside your code. Fix:
1. Remove the secret from the actual file
2. `git add .`
3. `git commit --amend -m "first commit"` (only safe if it's the most recent commit and hasn't been shared/merged elsewhere)
4. Revoke the leaked token on GitHub (Settings → Developer settings → Personal access tokens → find it → Delete), then generate a fresh one
5. `git push` again

### "refusing to allow a Personal Access Token ... without `workflow` scope"
Your token wasn't created with the `workflow` checkbox ticked. Fix: generate a new token with both `repo` and `workflow` scopes checked (see the token creation steps above), then:
```bash
git credential-osxkeychain erase
```
(type `host=github.com` then `protocol=https` then blank Enter), then `git push` again and use the new token.

### Build fails with a C++ compiler / coroutine error mentioning MSVC
This happened because GitHub's `windows-latest` runner briefly used a bleeding-edge Visual Studio version incompatible with some Flutter plugins. Fixed by pinning the runner to `windows-2022` in the workflow file (already done — see file above). If it ever recurs, the fix is the same: keep `runs-on: windows-2022` (don't change it to `windows-latest` unless you specifically want to test the newest environment).

### Inno Setup error: "Parameter Flags includes an unknown flag"
Typo in `installer.iss` — the correct flag is `recursesubdirs` (plural), not `recursesubdir`. Already fixed in the file above.

### Client sees "Windows protected your PC" (SmartScreen warning)
Normal behavior for installers without a paid code-signing certificate. Tell the client to click **More info** → **Run anyway**. This does not mean the app is broken or unsafe — it's just Microsoft being cautious about unsigned/new software. To remove this warning permanently, you'd need to purchase a code-signing certificate (a separate, optional upgrade — not required to ship working software).

---

## Good Practices Going Forward

- **Never hardcode tokens, passwords, or API keys directly in `.dart` files.** If you need to store sensitive config, ask for guidance on using environment variables or a `.gitignore`-excluded config file.
- **Keep the repo private.** Never toggle it to Public — it's a client project.
- **Bump your app version** (`pubspec.yaml` and optionally `installer.iss`) before each release so you and the client can track versions.
- **Test locally first** (`flutter run -d chrome` or on an emulator/device) before pushing — the GitHub build takes several minutes, so catching bugs locally saves time.
- **Token expiry**: your tokens are set to expire in 90 days. If a push ever fails with an authentication error out of nowhere, it's likely just an expired token — generate a fresh one following the steps above.

---

*Keep this file safe — save it somewhere easy to find, since it's your complete "how to ship a Windows build" reference for this project.*


 */
 */
