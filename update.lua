local os = require("os")
local fs = require("filesystem")
local shell = require("shell")
local component = require("component")

-- manually tracked for now...
local configs = {
    "mainmon/config.lua"
}

local _, options = shell.parse(...)
local overwrite_configs = options.o or false
local show_help = options.h or false

if show_help then
    print("Usage: update [-oh]")
    print(" -o: Overwrites configs")
    print(" -h: Show this message")
    return
end

if not component.isAvailable("internet") then
    io.stderr:write("This program requires an internet card to run.\n")
    return
end

local tmp_folder = os.tmpname() .. "/"
if not overwrite_configs then
    print("Backing up configs...")

    fs.makeDirectory(tmp_folder)
    for _, config_file in ipairs(configs) do
        local config_dir, _ = config_file:match("(.-)/?([^/]+)$")
        config_dir = tmp_folder .. config_dir
        if not fs.exists(config_dir) then
            fs.makeDirectory(config_dir)
        end

        local from = "/home/" .. config_file
        local to = tmp_folder .. config_file
        local success, reason = fs.copy(from, to)
        if success then
            print(from .. " -> " .. to)
        else
            io.stderr:write("Skipping '".. from .."': " .. tostring(reason) .. "\n")
        end
    end
    print("\27[32mBacked up configs.\27[m\n")
end

print("Updating tools...")
os.execute("wget -f http://127.0.0.1:8000/setup.lua && setup")
print("\27[32mTools updated.\27[m")

if not overwrite_configs then
    print("")
    print("Restoring configs...")
    for _, config_file in ipairs(configs) do
        local from = tmp_folder .. config_file
        local to = "/home/" .. config_file
        local success, reason = fs.copy(from, to)
        if success then
            print(from .. " -> " .. to)
        else
            io.stderr:write("Skipping '".. from .."': " .. tostring(reason) .. "\n")
        end
    end
    print("\27[32mConfigs restored.\27[m")
    fs.remove(tmp_folder)
end