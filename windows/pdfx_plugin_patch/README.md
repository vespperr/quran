# pdfx Windows build fix (pdfium download / CMake / NOMINMAX)

Apply these patches to the **pdfx** plugin’s Windows CMake so the Windows build works when:

- The automated pdfium download fails (network, firewall, or DownloadProject).
- CMake or VS 2022 reports a **VERSION** / project() conflict.
- The build fails due to **min/max** macro issues (Windows headers vs `std::min`/`std::max`).

## 1. Where to apply

Patch the **pdfx** plugin’s `windows` folder. Use **one** of these:

- **Option A – Pub cache (recommended after each `flutter pub get`)**  
  `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\pdfx-2.9.2\windows\`

- **Option B – Plugin symlink (ephemeral)**  
  `build\windows\x64\flutter\ephemeral\.plugin_symlinks\pdfx\windows\`  
  (Created during build; path may differ. Prefer Option A so the cache is patched.)

Run **apply_pdfx_patch.ps1** from the repo root (see below); it copies the patched files into the pub-cache path above.

## 2. What the patch does

- **Local pdfium**  
  If the automatic download fails, you can use a pre-downloaded pdfium:
  - Build with:  
    `-DPDFIUM_USE_LOCAL=ON -DPDFIUM_SOURCE_DIR="C:/absolute/path/to/extracted/pdfium"`
  - The directory must contain `PDFiumConfig.cmake` and the `lib/` (and usually `include/`) from the bblanchon archive.

- **CMake VERSION**  
  - `cmake_minimum_required(VERSION 3.14)` in the plugin and in the generated download project.
  - `project(... VERSION 1.0.0 LANGUAGES CXX)` so there is no VERSION/project() conflict with the top-level project or VS 2022.

- **min/max**  
  - `NOMINMAX` is added as a compile definition for the pdfx plugin target so Windows’ `min`/`max` macros do not break `std::min`/`std::max`.

## 3. Manual pdfium (when download fails)

1. Download the Windows x64 archive (match the version in your app’s `windows/CMakeLists.txt` or the plugin default, e.g. 4638 or 4690):
   - **4690+ (new format):**  
     https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/4690/pdfium-win-x64.tgz  
   - **Older (e.g. 4638):**  
     https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/4638/pdfium-windows-x64.zip  

2. Extract to a permanent path, e.g.  
   `C:\pdfium\4690`  
   so that **PDFiumConfig.cmake** and **lib/** (and usually **include/**) are directly under that folder.

3. Configure with local pdfium, then build, e.g.:
   ```bat
   flutter build windows -- -DPDFIUM_USE_LOCAL=ON -DPDFIUM_SOURCE_DIR=C:/pdfium/4690
   ```
   Or in VS: add CMake options  
   `-DPDFIUM_USE_LOCAL=ON -DPDFIUM_SOURCE_DIR=C:/pdfium/4690`.

## 4. Apply the patch (PowerShell)

From the **repository root** (where `windows/pdfx_plugin_patch/` lives):

```powershell
.\windows\pdfx_plugin_patch\apply_pdfx_patch.ps1
```

This copies:

- `windows/pdfx_plugin_patch/CMakeLists.txt`  
- `windows/pdfx_plugin_patch/DownloadProject.CMakeLists.cmake.in`  

into the pdfx plugin’s `windows` folder in the Pub cache (with a fallback path if your pub cache is elsewhere).

After applying, run:

```bat
flutter clean
flutter pub get
flutter build windows
```

If you use local pdfium, add the `-DPDFIUM_USE_LOCAL=ON -DPDFIUM_SOURCE_DIR=...` arguments as above.
