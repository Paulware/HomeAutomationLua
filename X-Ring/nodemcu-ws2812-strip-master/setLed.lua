ws2812.init()

local i, buffer = 0, ws2812.newBuffer(12, 3)
method = 0

-- h, s, l = math.random(), saturation, brightness

buffer:fill(3, 0, 0)
ws2812.write(buffer)

XRing = {health=12}
function XRing:new (o)
  o = o or {}
  setmetatable (o,self)
  self.__index = self
  return o
end

function XRing.clear()
  buf = ws2812.newBuffer(12, 3)
  for i=1,12 do
     buf:set(i, string.char(0, 0, 0))
  end
  ws2812.write (buf)  
end

function XRing.green (numLeds)
  XRing.clear()
  buf = ws2812.newBuffer(12, 3)
  for i=1,numLeds do
     buf:set(i, string.char(70, 0, 0))
  end
  ws2812.write (buf)
end

function XRing.red (numLeds)
  buf = ws2812.newBuffer(numLeds, 3)
  for i=1,numLeds do
     buf:set(i, string.char(0, 100, 0))
  end
  ws2812.write (buf)
end

function XRing.blue(numLeds)
  buf = ws2812.newBuffer(numLeds, 3)
  for i=1,numLeds do
     buf:set(i, string.char(0, 0, 100))
  end
  ws2812.write (buf)
end

