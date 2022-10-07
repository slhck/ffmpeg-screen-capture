# ffmpeg-screen-capture

Capture the screen with ffmpeg, with some extras.

Author: Werner Robitza

Contents:

- [Requirements](#requirements)
- [Usage](#usage)
  - [Changing the recorded display](#changing-the-recorded-display)
  - [Stopping the recording](#stopping-the-recording)
  - [Further options](#further-options)
- [License](#license)

## Requirements

- ffmpeg with x11grab support
- Bash 4.0 or higher

## Usage

```bash
./ffmpeg-screen-capture.sh
```

This will capture the screen with a default framerate of 25 fps and save to `recording-<datetime>.mkv` in your current directory. The capture will have the local timestamp embedded at the bottom left.

By default, the `DISPLAY` environment variable is used to determine the display to capture.

The progress will be printed on stdout; ffmpeg logs are printed on stderr.

**Note:** This is very opinionated and nothing more than a shell script calling ffmpeg with a filter. Many options that you might need are missing. If you need more options, you should probably use ffmpeg directly.

### Changing the recorded display

If you want to record another display, call:

```bash
DISPLAY=:1234 ./ffmpeg-screen-capture.sh
```

### Stopping the recording

When the recording is running, press `q` to stop. You can optionally also pass a time in seconds after which the recording will stop automatically:

```bash
./ffmpeg-screen-capture.sh -t 60
```

### Further options

See `ffmpeg-screen-capture.sh -h` for more options.

## License

MIT License

ffmpeg-screen-capture, Copyright (C) 2022 Werner Robitza

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
