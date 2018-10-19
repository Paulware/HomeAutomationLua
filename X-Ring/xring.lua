---------------------------------------------------------------------
-- File: ws2812_demo.lua
-- Author: RSP @ Embedded Systems Lab (ESL), KMUTNB, BKK/Thailand
-- Date: 2015-06-01
-- NodeMCU v2 + WS2812B RGB LED strip
---------------------------------------------------------------------
-- a table of predefined RGB colors
colors = {"FF0000","00FF00","0000FF","FFFF00","00FFFF","FF00FF","FFFFFF"} 

ws2812_pin=3 -- use NodeMCU D3 pin
num_leds=5   -- number of RGB LEDs used
index=0
offset=tmr.now()%num_leds
print ('running xring.lua')
function show_rgb()
  local hex_str=''
  local num_colors=#colors
  print ('show_rgb')
  for i=1,num_leds do
    local j=(i+offset)%num_colors+1
    hex_str=hex_str..colors[j]
  end
  offset = (offset+1)%1000
  local str=''
  for i=1,#hex_str,2 do
    local t=string.sub( hex_str, i, i+1 )
    str=str..string.char( tonumber(t,16) )
  end
  print ('wdclr')
  tmr.wdclr()                        -- clear WDT  
  print ('writergb')
  ws2812.writergb( ws2812_pin, str ) -- send data to WS2812
  print ('done')
  if (index > 1000) then             -- after 1000 iterations
    tmr.stop(1)                      -- stop timer 1
  end
end

tmr.alarm( 1, 1000, 1, show_rgb ) -- setup timer 1