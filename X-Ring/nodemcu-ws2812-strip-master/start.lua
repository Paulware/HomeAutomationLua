-- Variables --
led_count         = 330 -- count of
delay_ms          = 15  -- one frame delay, do not set bellow 15 ms
brightness        = 0.6 -- brightness of strip, 0 to 1, at 1 will be absolutely white
saturation        = 1   -- 0 to 1, more for more contrast
lightness         = 100 -- smaller darker and more color difference
reverse_chance    = 0.1 -- chance of reverse (0 to 1)
dead_picel_chance = 5   -- chance of dead pixel (0 to 10)

--dofile('ws2812_functions.lua')
dofile('color_functions.lua')
--dofile('wifi.lua')
dofile('ws2812.lua')
