ws2812.init()

local i, buffer = 0, ws2812.newBuffer(12, 3)
method = 0

-- h, s, l = math.random(), saturation, brightness
--          g  r? b?
buffer:fill(0, 0, 3)
ws2812.write(buffer)

XRing = {health=12}
xring = XRing

-- Format of command: sensorName command param
function listenForServer(port)
  print ("Listening for server..." )
  srv=net.createServer(net.UDP)
  srv:on("receive", function(connection, pl)     
     -- Get server address
     if string.sub (pl,0,6) == "health" then
         print ("Server address received.")       
         health = string.sub (pl, 8) 
         hlth = tonumber(health)
         print ("health ["..hlth.."]" )
         xring.green(hlth)
     else 
         print ("could not handle message: ["..pl.."]")
     end
   end)
  srv:listen(port)   
end 

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

function urlEncode(str)
  if (str) then 
     str = string.gsub (str, "\n", "\r\n")
     str = string.gsub (str, " ", "+")
  end
  return str
end

-- Send a message from esp8266 to the raspberry pi server
function sendMsg(Message)   
   -- Create a TCP connection to the apache web server on port 80 (http) and send the message
   conn=net.createConnection(net.TCP, 0) 
   conn:connect(80,serverAddress) -- Connect to server
   conn:on("receive", function(conn, payload) print(payload) end)
   conn:on("sent",function(conn)
                   conn:close()
                  end)   
   conn:on("disconnection", function(conn)
                              end)

   -- Only send when the connection is established.                              
   conn:on("connection", function(sck) 
                           sck:send("GET /Pipboy/updatePipboy.php?MAC="..MAC.."&Message="..urlEncode(Message).." HTTP/1.1\r\n")
                           sck:send("Host: "..serverAddress.."\r\n") 
                           sck:send("Accept: */*\r\n") 
                           sck:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
                           sck:send("\r\n")
                       end )     
   
   -- PostponeHeartbeat   
   tmr.stop(1)
   tmr.alarm (1,60000,1,sendHeartbeat) 
   
   print ("sent "..Message.." to "..serverAddress)
end

-- Tell the server I am alive 
function sendHeartbeat() 
   sendMsg ("Hello")
end

listenForServer(3333)

sendHeartbeat()
