for this .bin file, use baud rate 115200 in lua loader or 9600 baud after cycle power.
also there is a lua class that is used...

Note: 
   D4 on Wemos is connected to D3 on X-Ring!
   
   stop tmr 
   
   
   load setLed.lua 
   dofile ("setLed.lua")
   xring = XRing
   xring.green(3)
   xring.blue(4)
   
   This functionality was moved to the arduino because the ws2812 os would not run on the smaller esp8266