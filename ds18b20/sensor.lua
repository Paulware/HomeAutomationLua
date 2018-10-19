-- Global Variables
fahrenheit = nil
port = 3333
serverAddress = nil
networkJoined = 0
ip = nil
MAC=wifi.sta.getmac() 
Password = nil
SSID = nil
filename = "ssidPassword.txt"
t = require("ds18b20")
gpio2 = 4
t.setup(gpio2)
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function getInfo() 
   handle = file.open (filename, "r")
   SSID = trim(file.readline())
   Password = trim(file.readline())
   file.close()
   print ("SSID:"..SSID.." Password:"..Password )
end

function readSensor(pin)
   addrs = t.addrs()
   numModules = 0
   if (addrs ~= nil) then
     numModules = table.getn(addrs)
     print("Total DS18B20 sensors: "..numModules)
   end

   if numModules > 0 then
      temperature = t.read()
      print("Ds18b20 Temperature:"..temperature)
   else
      temperature = nil
   end
end

function sendData()
   sk=net.createConnection(net.TCP, 0)
   sk:on("receive", function(sk, c) print(c) end )  
   -- When the connection is established, send the data
   sk:on("connection", function(sck) 
                          msg = "GET /Paulware/updateSensor.php?MAC="..MAC.."&value="..fahrenheit.." HTTP/1.1\r\nHost: Paulware\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n"
                          print (msg)
                          sck:send(msg) 
                       end )
   
   -- When the data is sent, close the connection   
   sk:on("sent",function(sk)
                   print("Data Sent!")
                   sk:close()
                end ) 
                
   -- Connect to the server            
   sk:connect(80,serverAddress)
end

-- Listen for the server ip address
function listenForServer()
  port = 3333
  srv=net.createServer(net.UDP)
  srv:on("receive", function(connection, pl)
     print("Command Received "..pl)
     
     -- Get server address
     if string.sub (pl,0,6) == "server" then
         print ("Server address received.")       
         serverAddress = string.sub (pl, 8) 
         print ("Address:"..serverAddress.."." )
     end
   end)
  srv:listen(port)   
end   
 
function getReady() 
   handle = file.open (filename, "r")
   if handle == nil then
      print ("SSID file does not exist yet, use the command: login (SSID,password)" )
      tmr.stop(1)
      tmr.alarm (1,60000,1,getReady)      
   else
      if (SSID == nil) or (Password == nil) then 
         getInfo()
      end     
      if SSID == nil then 
         print ("SSID == nil, use the command: login (SSID,Password)" )
      else 
         if Password == nil then
            print ("Password == nil, use the command: login (SSID,Password)" )                
         else            
            ip = wifi.sta.getip()                      
            if ip == nil then 
               print("v1.2, Waiting for router to assign address...Connecting to AP...") 
               print("SSID"..SSID.." Password:"..Password..".")
               wifi.sta.config(SSID, Password)
            else 
               if serverAddress == nil then
                  print (ip.." waiting to receive server ip address")
               else
                  print ("Ready, reading sensor, my address is:"..ip..".") 
                  readSensor(4) -- D4=GPIO2
                  if temperature == nil then
                     print ("Error, reading temperature")
                  else
                     fahrenheit = (temperature * 180 / 100 ) + 32
                     print("temp:"..temperature.."C "..fahrenheit.."F ".."%")
                     sendData()
                  end  
               end
            end               
         end
      end   
   end   
end

function login (ssid,password) 
  print ("ssid: "..ssid.." password: "..password) 
  print ("Save SSID/Password to text.txt" )
  file.open (filename, "w")
  file.writeline (ssid)
  file.writeline (password)
  file.close()
  tmr.stop(1)
  tmr.alarm (1,10000,1,getReady)        
  getInfo()
  getReady()
end
MAC = wifi.sta.getmac()
listenForServer()
getReady()
tmr.alarm(1, 10000, 1, getReady)
