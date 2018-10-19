local SSID
local Password
local filename = "ssidPassword.txt"
serverAddress = "172.24.1.1"
MAC = wifi.sta.getmac()
uart.setup (0,9600,8,0,1) -- Setup to read from usb port 
print("\r\r\rinit.lua")
wifi.setmode(wifi.STATION)
print("set mode=STATION (mode="..wifi.getmode()..")")
print("MAC: "..MAC)

function trim(s)
  return s:match "^%s*(.-)%s*$"
end

function readInfo() 
   f = file.open (filename, "r")
   if (f == nil) then 
      print (filename.." not created yet" )
   else 
      SSID = trim(file.readline())
      Password = trim(file.readline())
      print ( "Read [SSID,Password]: ["..SSID..","..Password.."]" )
      file.close()
   end    
end

function init() 
  print ("Create "..filename.."\n")
  file.open (filename, "w")
  file.writeline ("MySSID")
  file.writeline ("MyPassword")
  file.close()
end

function getServerAddress () 
   tmr.stop(1)
   if serverAddress == nil then 
      print ("No server address heard yet..." )
      print ("Try again in 10 seconds" )
      tmr.alarm(1, 10000, 1, getServerAddress)
   else
      print ("Server address: "..serverAddress..".  Call sensor.lua" )
      dofile ("sensor.lua")
   end
      
   
end 

function joinNetwork()
   tmr.stop(1)
   print ("[SSID,Password]: ["..SSID..","..Password.."] logging in..." )
   print ("system will now try to join network" )
   local ipAddress  
   ipAddress = wifi.sta.getip()
      
   if ipAddress == nil then
      print ("Try again in 10 seconds...")
      tmr.alarm(1, 10000, 1, joinNetwork)
   else
      print ("Got an ipAddress: "..ipAddress )
      dofile ("sensor.lua") -- ready
   end
end

function writeInfo() 
  print ("Writing info to "..filename )
  file.open (filename, "w")
  file.writeline (SSID)
  file.writeline (Password)
  file.close()
end 

function login (ssid,password) 
  SSID = ssid
  Password = password
  print ("ssid: "..ssid.." password: "..password) 
  print ("Save SSID/Password to text.txt" )
  writeInfo()
  tmr.alarm(1, 2000, 1, loginNetwork) -- wait 2 seconds then login
end

function loginNetwork()
   tmr.stop(1)
   if SSID == nil then 
      print ("type: login (\"MySSID\", \"MyPassword\" ) to login to network\r" )
      tmr.alarm(1, 20000, 1, loginNetwork)
   else
      --connect to Access Point (DO save config to flash)
      station_cfg={}
      station_cfg.ssid=SSID
      station_cfg.pwd=Password
      station_cfg.save=true   
      wifi.sta.config(station_cfg)    
      tmr.alarm(1, 2000, 1, joinNetwork) -- wait 2 seconds then login
   end
end


readInfo()
wifi.setmode(wifi.STATION)
loginNetwork()
