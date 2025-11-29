local os = require("os")
local component = require("component")
local term = require("term")
local sides = require("sides")
local event = require("event")

local config = require("mainmon/config")

-- Check if a tier 2 redstone card is installed
local redstone_error = false
local rs = nil
if not component.isAvailable("redstone") then
    redstone_error = true
else
    rs = component.redstone
    local available_methods = component.methods(rs.address)

    local tier2 = false
    for k,_ in pairs(available_methods) do
        if k == "getWirelessFrequency" then
            tier2 = true
            break
        end
    end

    redstone_error = not tier2
end

if redstone_error then
    io.stderr:write("This program requires a tier 2 redstone card to run.\n")
    return
end

local SIDE_ALARM = sides.north
local OUTPUT_HEADER = "\27[m======== MAINTENANCE STATUS MONITOR v0.2 ========\n"
local PROGRESS_BAR_LENGTH = 32

local exit_flag = false
local function interruptedHandler(event_id, ...)
    exit_flag = true
    component.computer.beep(1500, 1)
    return false -- unbind event listener
end

local function renderProgressBar(progress, max_length)
    local discreet_progress = math.floor(progress * max_length)
    local progress_bar = string.rep("=", discreet_progress) .. string.rep("-", max_length - discreet_progress)
    return "[" .. progress_bar .. "]"
end

term.clear()
print("\27[mLoading...")
local init = false

event.listen("interrupted", interruptedHandler)

local freq_keys = {}
for k,_ in pairs(config) do table.insert(freq_keys, k) end
table.sort(freq_keys)

while not exit_flag do
    local output = OUTPUT_HEADER
    local maintenance_needed = false
    local index = 0
    local loading_cursor_frames = {"|", "/", "-", "\\", "|", "/", "-", "\\"}

    for _, freq in pairs(freq_keys) do
        if init then
        -- refresh indicator
            local loading_cursor = loading_cursor_frames[(index % #loading_cursor_frames) + 1]
            local progress = (index + 1) / #freq_keys
            io.write("\rRefreshing: " .. loading_cursor .. " " .. renderProgressBar(progress, PROGRESS_BAR_LENGTH))
        end

        -- maintenance monitoring
        local machine = config[freq]
        rs.setWirelessFrequency(freq)
        if rs.getWirelessInput() then
            maintenance_needed = true
            output = output .. "\n\27[31mALERT: \27[33m" .. machine .. " \27[35m#" .. freq .. "\27[m"
        end

        index = index + 1
    end

    if not maintenance_needed then
        output = output .. "\n\27[32mAll systems nominal\27[m"
    end

    rs.setOutput(SIDE_ALARM, (maintenance_needed and 15) or 0)

    term.clear()
    print(output .. "\n\nPress 'Ctrl-C' to quit\n")
    io.write("Refreshing: | " .. renderProgressBar(1, PROGRESS_BAR_LENGTH))
    init = true
    os.sleep(0.1)
end

rs.setOutput(SIDE_ALARM, 0)
term.clear()
print("\27[mExiting...")