# About
It is NodeMcu and WS2812 LED Strip "hello world" project.

After power on strip shows some different effects in random order:

Each cycle (length of LED strip) changeing fill method.

### Fill methods
- rainbow (smooth color change)
- waterfall (random color for each led)
- solid (one random color)

### Other random effects
- sometimes runs "dead pixels" (about 1 time for cycle)
- sometimes strip flow revercing


# How to use

## Setup your LoLin V3 NodeMcu
1. Install drivers for CH340. For macos sierra use [this driver](https://github.com/adrianmihalko/ch340g-ch34g-ch34x-mac-os-x-driver)
2. Go to https://nodemcu-build.com and build firmware with modules: file, gpio, net, node, timer, uart, wifi, ws2801
   You can build firmware with Docker (see above):
3. Flash float version of binary. Crossplatform way (replace port and path to firmware to yours):
```
pip install esptool
esptool.py --port /dev/tty.wchusbserial1450 write_flash 0x00000 ~/projects/esp8266/nodemcu-firmware/bin/nodemcu_float_master_20161210-1855.bin
```

### Build firmware with Docker
At step 2 from setup NodeMcu, if you build firmwares frequently, more faster way to do it is build you own.
1. Clone nodemcu-firmware:
```
git clone https://github.com/nodemcu/nodemcu-firmware.git
```
2. Go to `nodemcu-firmware/app/include/user_modules.h` and comment/uncomment needed modules
3. Build firmware (replace path to nodemcu-firmware):
```
docker run --rm -ti -v /Users/popstas/projects/esp8266/nodemcu-firmware:/opt/nodemcu-firmware marcelstoer/nodemcu-build
```

Firmwares integer and float will be placed at nodemcu-firmware/app/bin, flash float version.

## Configure
Ajust some variables at start.lua

## Upload files to nodemcu
Easiest way: use [ESPlorer](https://esp8266.ru/esplorer/#download), open each file and press "Save to ESP"

# Details
## Files:
- init.lua - proxy file, need for disable script execution if needed.
  Just send any data to serial port in first 1 second for stop script.
- start.lua - main file, just includes other scripts.
- color_functions.lua - rgb <--> hsl convert
- ws2812_functions.lua - clean functions for ws2812
- ws2812.lua - led strip scripts
