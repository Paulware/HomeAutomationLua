local SSID
local Password
local filename = "ssidPassword.txt"
serverAddress = nil
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

function getServerAddress(ipAddress)
   address = ""
   print ("Get server address my ip address: "..ipAddress )
   len = string.len (ipAddress)
   for i = 1, len do 
      if (string.byte (ipAddress,i) == 46) then
         address = string.sub (ipAddress,1,i)
         address = address .. "1"
      end    
   end 
   print ("Got server address:"..address )
   return address
end

function joinNetwork()
   tmr.stop(1)
   print ("[SSID,Password]: ["..SSID..","..Password.."] logging in..." )
   print ("system will now try to join network" )
   -- wifi.sta.config(SSID, Password)
   ip = wifi.sta.getip()
      
   if ip == nil then
      print ("Try again in 10 seconds...")
      tmr.alarm(1, 10000, 1, joinNetwork)
   else
      serverAddress = getServerAddress (ip)
      print ("I have been assigned an ip address: "..ip)       
      print ("serverAddress ="..serverAddress)      
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
