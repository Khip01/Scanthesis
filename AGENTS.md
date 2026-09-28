# Agent Rules for Scanthesis

## Project Structure

- `scanthesis_app/` - Flutter desktop application (Dart, Linux/Windows)
- `scanthesis_api/` - Go API backend (Gemini OCR)
- `.github/workflows/release.yml` - Automated release build

## Release Workflow

Pushing any tag triggers GitHub Actions to build and upload all Linux packages automatically.

```bash
git tag v2.0.1
git push origin v2.0.1
```

The workflow runs on `ubuntu-22.04` for Linux and API, and `windows-latest` for the installer, to ensure glibc compatibility (max 2.35). Four jobs run in parallel (linux, windows, api), then a publish job creates the GitHub Release with `gh release create`. If a release for that tag already exists, same-named assets are replaced with `--clobber`.

Artifacts produced per release:
- `scanthesis_<version>_amd64.deb`
- `scanthesis-<version>-1.fc42.x86_64.rpm`
- `scanthesis_<version>-x86_64.AppImage`
- `scanthesis-<version>-linux-x86_64.tar.gz`
- `scanthesis_setup_v<version>.exe`
- `scanthesis_api_v<version>_linux_amd64`
- `scanthesis_api_v<version>.exe`

Arch Linux packages (`.pkg.tar.zst`) and macOS builds are skipped.

## Packaging Conventions

### Version Management

Version is passed dynamically via `--version` flag from the git tag. Do not hardcode versions in scripts when releasing. The `pubspec.yaml`, `.iss`, and build script defaults all carry the same current version (`2.0.1`) for local development only; CI overrides them (`--build-name` for Flutter, `/DMyAppVersion` for Inno Setup). Keep these in sync when bumping.

### AppImage Requirements

The AppImage must be self-contained. `package_linux_distributions.sh` handles this by:
- Using `linuxdeploy` with the GTK plugin
- Bundling `libkeybinder-3.0.so.0`, `libayatana-appindicator3.so.1`, and `libdbusmenu-gtk3.so.4`
- Setting `LD_LIBRARY_PATH` via a custom `AppRun` script
- Using `appimagetool` from the new AppImage/appimagetool repo (not AppImageKit continuous)

Never revert to the old AppImageKit runtime or symlink-based AppRun.

### Dependencies

System dependencies for deb/rpm are declared in `package_linux_distributions.sh`:
- `DEB_DEPENDENCIES` includes `libkeybinder-3.0-0` and `libayatana-appindicator3-1`
- `RPM_DEPENDENCIES` includes `keybinder3` and `libayatana-appindicator-gtk3`

These are required because the native packages do not bundle shared libraries.

### CI Environment Variable

When `CI=true` is set, the packaging script skips Arch Linux package creation. This prevents unreproducible Arch artifacts from appearing in GitHub Releases.

## File Writing Hygiene

After using the write tool to create or overwrite any file, always re-read it with the read tool to verify it is clean. Check for leaked tool artifacts such as XML-like tags, protocol markers, or other non-file text. If contamination is found, rewrite the file immediately.

## Test Build Workflow

`.github/workflows/test-build.yml` runs on every push to main and every PR targeting main. It builds all Linux packages with CI=true and verifies:
- All expected artifacts exist (AppImage, deb, rpm, tar.gz)
- AppImage has no unresolved shared libraries
- deb and rpm contain required dependency metadata

This workflow does not create releases or upload artifacts to GitHub Releases. It only validates that the packaging pipeline works correctly.

## Code Style

- No comments unless explicitly requested
- Follow existing Dart/Go conventions in the codebase
- Use `flutter analyze` and `go vet` before committing changes to app or API code