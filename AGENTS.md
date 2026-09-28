# Agent Rules for Scanthesis

## Project Structure

- `scanthesis_app/` - Flutter desktop application (Dart, Linux/Windows)
- `scanthesis_api/` - Go API backend (Gemini OCR)
- `.github/workflows/release.yml` - Automated release build

## Release Workflow

Pushing any tag triggers GitHub Actions to build and upload all Linux packages automatically.

```bash
git tag v1.1.0
git push origin v1.1.0
```

The workflow runs on `ubuntu-22.04` to ensure glibc compatibility (max 2.35). It builds Flutter, runs the packaging script with `CI=true`, and uploads artifacts via `gh release create`.

Artifacts produced per release:
- `scanthesis_<version>_amd64.deb`
- `scanthesis-<version>-1.fc42.x86_64.rpm`
- `scanthesis_<version>-x86_64.AppImage`
- `scanthesis-<version>-linux-x86_64.tar.gz`

Arch Linux packages (`.pkg.tar.zst`) are skipped in CI.

## Packaging Conventions

### Version Management

Version is passed dynamically via `--version` flag from the git tag. Do not hardcode versions in scripts when releasing. The `pubspec.yaml` and `.iss` files retain their base version for local development only.

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

## Code Style

- No comments unless explicitly requested
- Follow existing Dart/Go conventions in the codebase
- Use `flutter analyze` and `go vet` before committing changes to app or API code
