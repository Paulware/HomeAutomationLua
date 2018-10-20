-- NOTE:
-- MAC and serverAddress are global variables that are set in init.lua
local waitTime = 60000
local systemOpen = 0

print ("sensor.lua has a serverAddress: "..serverAddress)

-- D4
myInputPin = 4

function sendData(value,humidity)
   print("Sending data to "..serverAddress..".")
   sk=net.createConnection(net.TCP, 0)
   conn=net.createConnection(net.TCP, 0) 
   print ("Connect")
   conn:connect(80,serverAddress)
   msg = "GET /Paulware/updateSensor.php?MAC="..MAC.."&value="..humidity..":"..value.." HTTP/1.1\r\n"
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


 
function reportValues() 
   status,temp,humi,temp_dec,humi_dec=dht.read(myInputPin)
   sendData(temp,humi)
end

-- Report sensor values periodically
tmr.alarm(1, waitTime, 1, reportValues)

