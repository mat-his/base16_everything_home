# Base16 Everything

**Transform every website to match your color scheme.**

Base16 Everything is a browser extension that remaps website colors to any [base16/base24](https://github.com/tinted-theming/home) palette in real time. Your browser finally matches your terminal, editor, and desktop.

[Install for Chrome](https://chrome.google.com/webstore/detail/base16-everything) | [Install for Firefox](https://addons.mozilla.org/en-US/firefox/addon/base16-everything) | [Website](https://base16everything.com)

## How it works

1. Install the extension
2. Pick a color scheme (or let it sync from your system)
3. Every website is instantly recolored to your palette

Color mapping is powered by Rust compiled to WebAssembly — it runs entirely in the browser with no external requests.

## Features

**Free tier** — no account needed:

- Two built-in themes (Gruvbox Light Hard + Google Dark)
- Automatic light/dark mode switching based on system preference
- WASM-powered color mapping with smooth transitions
- Per-page activation toggle

**Premium** ($8 one-time purchase):

- 200+ color schemes from [tinted-theming/schemes](https://github.com/tinted-theming/schemes)
- Search and download any tinted-theming scheme directly from the popup
- Native config sync — read your palette from `~/.config/base16-everything/config.yaml`
- Lifetime updates, use on up to 3 devices

## System theme sync with tinty

Premium users can sync their browser theme with their system using [tinty](https://github.com/tinted-theming/tinty). When you run `tinty apply`, your terminal, editor, desktop, and browser all switch together.

This works through [tinted-web](https://github.com/mat-his/tinted-web), a tinted-theming adapter that ships 184 pre-built base24 themes.

### Setup

1. Install the [native messaging host](native-host/) so the extension can read your local config:

   **Chrome / Chromium:**

   ```bash
   cd native-host
   ./install.sh <your-extension-id>
   ```

   To find your extension ID:

   1. Open `chrome://extensions`
   2. Find 'Base16 Everything'
   3. Copy the ID (looks like: `mlmhenlobfodphglalpgjpinfidhcbio`)

   **Firefox:**

   Firefox uses the add-on ID (`base16-everything@base16everything.com`) instead of a per-install extension UUID, so no argument is needed:

   ```bash
   cd native-host
   ./install.sh --firefox
   ```

   This installs the manifest to `~/.mozilla/native-messaging-hosts/` (Linux) or `~/Library/Application Support/Mozilla/NativeMessagingHosts/` (macOS).

   > If you installed Firefox from a non-standard location (e.g. Flatpak, Snap), the host directory may differ. See [MDN: Native manifests](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_manifests#manifest_location) for the full list.

2. Add tinted-web to your tinty config (`~/.config/tinted-theming/tinty/config.toml`):

   ```toml
   [[items]]
   name = "base16-everything"
   path = "https://github.com/mat-his/tinted-web"
   themes-dir = "themes"
   supported-systems = ["base24"]
   hook = "cp $TINTY_THEME_FILE_PATH ~/.config/base16-everything/config.yaml"
   ```

3. Sync and apply:

   ```bash
   tinty install
   tinty apply base24-gruvbox-dark
   ```

The extension picks up the new palette on the next page load. No restart needed.

## Account management

After purchasing a license, you can manage your account at [base16everything.com/devices](https://base16everything.com/devices). Log in with your email to:

- View and revoke registered devices
- Reveal your license key

You can also access this from the extension popup via **Settings > Manage Devices**.

## Links

- [Chrome Web Store](https://chrome.google.com/webstore/detail/base16-everything)
- [Firefox Add-ons](https://addons.mozilla.org/en-US/firefox/addon/base16-everything)
- [Website & Pricing](https://base16everything.com)
- [tinted-web adapter](https://github.com/mat-his/tinted-web) — tinty integration with 184 pre-built themes
- [tinted-theming](https://github.com/tinted-theming/home) — the base16/base24 ecosystem

## License

[MIT](LICENSE)
