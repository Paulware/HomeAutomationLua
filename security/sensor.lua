-- NOTE:
-- MAC and serverAddress are global variables that are set in init.lua
local waitTime = 10000
local systemOpen = 0

print ("sensor.lua has a serverAddress: "..serverAddress)

-- D3
myInputPin = 3
gpio.mode(myInputPin, gpio.INPUT)
-- Use the internal pull up resistor 
gpio.write(myInputPin,gpio.HIGH)

function sendData(value)
   print("Sending data to "..serverAddress..".")
   sk=net.createConnection(net.TCP, 0)
   conn=net.createConnection(net.TCP, 0) 
   print ("Connect")
   conn:connect(80,serverAddress)
   msg = "GET /Paulware/updateSensor.php?MAC="..MAC.."&value="..value.." HTTP/1.1\r\n"
   print (msg)
   conn:on("receive", function(conn, payload) print(payload) end)
   conn:send(msg)
   conn:send("Host: "..serverAddress.."\r\n") 
   conn:send("Accept: */*\r\n") 
   conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
   conn:send("\r\n")
   conn:on("sent",function(conn)
                   print("Data Sent!")
                   conn:close()
               end)   
   conn:on("disconnection", function(conn)
       print("Got disconnection...")
   end)
end

function readSensor()
  systemOpen = gpio.read (myInputPin)
end
 
function reportValues() 
   readSensor()
   if (systemOpen == 0) then
       print ("Ok security system closed")        
    else
       print ("Alert...security system open")
    end
    sendData(systemOpen)
end

-- Report sensor values periodically
tmr.alarm(1, waitTime, 1, reportValues)

