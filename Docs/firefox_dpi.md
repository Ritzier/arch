# Disable Firefox System DPI Following in i3wm

When using **i3wm** with `Xresource` DPI configuration, `Firefox` may initially start with the configured DPI but later
fall back to the system's original DPI

To prevet `Firefox` from following the system DPI, can disable it through `about:config`

## Configuration

Open `Firefox` and navigate to:

```url
about:config
```

Set the following preferences:

| Preference                         | Value  | Purpose                                                                  |
| ---------------------------------- | ------ | ------------------------------------------------------------------------ |
| `browser.display.os-zoom-behavior` | `0`    | Prevent `Firefox` from following the operating system's zoom/DPI setting |
| `layout.css.devPixelsPerPx`        | `1.75` | Set `Firefox`rs own display scalling factor (`1.75` = `175%`)            |
