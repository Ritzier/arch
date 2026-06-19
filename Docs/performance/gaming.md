# Setup Gamming Mode On Arch Linux

## CPU Performance Mode

Package:

```
sudo pacman -S cpupower
```

Check available governors:

```sh
cpupower frequency-info
```

Set performance governor:

```sh
sudo cpupower frequency-set -g performance
```

### Service

Edit:

```/etc/default/cpupower
governor='performance'
```

Enable and start service:

```sh
sudo systemctl enable --now cpupower.service
```

## Nvidia Maximum Performance

Power Management:

```sh
nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

Check `nvidia_drm`:

```sh
lsmod | grep nvidia_drm
```

Verify DRM and Modesetting are Active

```sh
sudo cat /sys/module/nvidia_drm/parameters/modeset
```

## GameMode

> ⚠️

> Currently ioprio not work yet

Add to group and verify:

```sh
sudo usermod -aG gamemode $USER
groups $USER
```

Should see `gamemode` listed.

```/etc/security/limits.d/10-gamemode.conf
# Allow GameMode users to renice processes
@gamemode   -   nice       -19

# Allow GameMode users to set I/O priority
# @gamemode   -   ioprio      2:4
```

```~/.config/gamemode.ini
[general]
renice=19
ioprio=4

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
nv_powermizer_mode=1

[cpu]
park_cores=no
pin_cores=no
```

```sh
systemctl --user enable --now gamemoded
```

## Steam Lauch Options

```
MANGOHUD=1 gamemoderun %command%
```

or with Nvidia Environment Variables

```
__GL_THREADED_OPTIMIZATIONS=1 mangohud gamemoderun %command%
```

## CrossHair

Aur Package: `gocrosshair`

```sh
gocrosshair - Lightweight crosshair overlay for X11/XWayland

Usage: gocrosshair [options]

Options:
  -config string
        Path to configuration file (default: ~/.config/gocrosshair/config.toml)
  -list-monitors
        List available monitors and exit
  -setup
        Run interactive setup wizard to create configuration
  -stop
        Stop any running gocrosshair instance
  -version
        Show version and exit

Configuration file location:
  Default: ~/.config/gocrosshair/config.toml
  Override with -config flag or XDG_CONFIG_HOME environment variable
```

```~/.config/gocrosshair/config.toml
[crosshair]
shape = "dot"
color = "#FF00FF"
size = 3
thickness = 2
gap = 0
outline_thickness = 0
outline_color = "#000000"

[position]
monitor = 0
offset_x = 0
offset_y = 0
```
