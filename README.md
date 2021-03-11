# android-boot-preview
A Powershell/WPF program for viewing Android bootanimation.zip

I am developing this program because it is time-consuming to manually update `/system/media` and check out how boot animations look, and also because there are only few desktop-based previewers.

---
## Operation Mode
**1. WPF Mode**\
  If you do not provide any arugments to ABP.ps1, a GUI will guide you through the process.

**2. CLI Mode**\
  By passing `InPath`, `ScreenW`, `ScreenH`, `BootTime`, and `Repeat`, ABP automatically generates the preview.

---
## Dependencies
- `ffmpeg`

You can download it from [here](https://tracker.debian.org/pkg/ffmpeg), or [here](https://www.deb-multimedia.org/), or [here](https://launchpad.net/ubuntu/+source/ffmpeg) or [here](https://rpmfusion.org/), or [here](https://johnvansickle.com/ffmpeg/), or [here](https://www.gyan.dev/ffmpeg/builds/), or [here](https://github.com/BtbN/FFmpeg-Builds/releases), or [here](https://evermeet.cx/ffmpeg/), or [here](https://evermeet.cx/ffmpeg/#sExtLib-ffmpeg), or [here](https://evermeet.cx/ffmpeg/#rExtLib-ffmpeg), or [here](https://sourceforge.net/projects/ffmpeg/), or [here](https://lame.buanzo.org/#lamewindl), or [here](https://sourceforge.net/projects/ffmpeg-windows-builds/), or [here](https://synocommunity.com/package/ffmpeg), or [here](https://github.com/FFmpeg/FFmpeg/releases) or [here](http://myffmpeg.com/download.html), or [here](https://ffbinaries.com/downloads), or [here](https://www.nuget.org/packages/FFmpeg.Win64.Static/), or [here](https://git.ffmpeg.org/ffmpeg.git), or [here](https://github.com/q3aql/ffmpeg-install), or [here](https://github.com/feixiao/ffmpeg).

Downloading FFMPEG is a pain; avoiding its Hall of Shame is a bigger one. So please download it yourself. Good luck.

---

## Supported Features (So Far)
**Header**
- Width
- Height
- FPS

**Animation Definition**
- Type (C and P only)
- Count
- Pause
- Path
- RGB Hex

## Features on Prority List
- Support for `audio.wav`
- `CLOCK1`, `CLOCK2`

## Features I might add
- Type F
- Fade for F type
- Support for
  - `clock_font.png`
  - `progress_font.png`
  - `trim.txt`
