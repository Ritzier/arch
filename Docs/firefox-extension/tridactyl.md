# Tridactyl

## 1. Install Native Messaging

1. Open **Tridactyl Firefox**

2. Run the following command:

```bash
:nativeinstall
```

3. This will copy a bash script to your clipboard

4. Paste and execute it in your terminal

## 2. Apply Catppuccin Mocha CLI Theme

- Theme repository: <https://github.com/devnullvoid/tridactyl>
- Run the following command inside **Tridactyl**:

```bash
:colourscheme --url https://raw.githubusercontent.com/devnullvoid/tridactyl/main/themes/catppuccin-mocha-cli.css catppuccin-mocha-cli
```

## 3. Firefor disable `Alt` popup menu bar

1. `about:config` in url

2. Disable `Alt` popup the menu bar

```
ui.key.menuAccessKeyFocuses = 0
```

3. Disable `Alt` combo key (`Alt+F`, `Alt+E`, etc.)

```
ui.key.menuAccessKey = 0
```
