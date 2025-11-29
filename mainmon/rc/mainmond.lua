-- move this file to /etc/rc.d/ and enable it with 'rc mainmond enable'

shell = require("shell")
os = require("os")
fs = require("filesystem")

local log = nil

local function print_log(msg)
  if log == nil then return end
  local entry = "[" .. os.date() .. "] " .. msg .. "\n"
  log:write(entry)
end

function start()
  local tmp = os.tmpname()
  log = fs.open("/tmp/mainmond.log", "a")
  print_log("mainmon started")

  shell.setWorkingDirectory("/home")
  shell.execute("/home/mainmon/mainmon.lua 2> " .. tmp)
  local err = nil

  if fs.exists(tmp) then
    err_log = io.open(tmp, "r")
    err = err_log:read("*all")
    err_log:close()
    fs.remove(tmp)
  end
  
  if err ~= nil and err ~= "" then
    print_log(err)
    print_log("mainmon exited with errors")
  else
    print_log("mainmon exited successfully")
  end

  log:close()
end