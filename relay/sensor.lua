
relayValue = 0
-- Sonoff momentary depress switch can be read at gpio 3
-- Sonoff Relay is at gpio 6

-- Send a message from esp8266 to the raspberry pi server
function sendValue() 
  value = relayValue
  sk=net.createConnection(net.TCP, 0)
  sk:on("receive", function(sk, c) print(c) end )  
  -- When the connection is established, send the data
  sk:on("connection", function(sck) 
                        print ("Connected,sending"..msg)
                        sck:send(msg) 
                      end )
   
  -- When the data is sent 
  sk:on("sent",function(sk)
            print("Data Sent!")
            sk:close()
            sk=nil
          end )    
   
  msg = "GET /Paulware/updateSensor.php?MAC="..MAC.."&value="..value.." HTTP/1.1\r\nHost: Paulware\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n"
  sk:connect(80,serverAddress) 
end

-- Format of command: turn (on,off) (0..7)
function startListening()
  port = 3333
  srv=net.createServer(net.UDP)
  srv:on("receive", function(connection, pl)
     print("Command Received "..pl)     
     -- Get server address
     if string.sub (pl,1,6) == "server" then
         print ("Server address received.")       
         serverAddress = string.sub (pl, 8) 
         print ("Address:"..serverAddress.."." )
     elseif string.sub(pl,1,8) == "turn off" then
         tens = string.sub(pl,9,9)
         ones = string.sub(pl,10,10)
         gpioNumber = (string.byte (tens) - 48 ) * 10 + string.byte (ones) - 48 
         print ("Set gpio:"..gpioNumber.." LOW" )
         gpio.mode(gpioNumber, gpio.OUTPUT)
         gpio.write (gpioNumber,gpio.LOW)
         print ("gpio "..gpioNumber.." turned low")
     elseif string.sub(pl,1,7) == "turn on" then
         tens = string.sub(pl,9,9)
         ones = string.sub(pl,10,10)
         gpioNumber = (string.byte (tens) - 48 ) * 10 + string.byte (ones) - 48 
         gpio.mode(gpioNumber, gpio.OUTPUT)
         gpio.write (gpioNumber,gpio.HIGH)
         print ("gpio "..gpioNumber.." turned high")
     else
         print ("Cannot handle command:"..pl)
     end
   end)
  srv:listen(port)   
end   

gpio.mode(0, gpio.OUTPUT)
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)
gpio.mode(5, gpio.OUTPUT)
gpio.mode(6, gpio.OUTPUT)
gpio.mode(7, gpio.OUTPUT) 
         
startListening()
tmr.stop(1)
tmr.alarm(1, 30000, 1, sendValue) -- Send update twice a minute 