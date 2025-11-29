-- run 'py build.py' on host, run server.bat, and install in-game using 'wget -f http://127.0.0.1:8000/setup.lua && setup'

local os = require("os")
local fs = require("filesystem")
local component = require("component")

local ADDRESS = "127.0.0.1:8000"

local home_dir = "/home/"

-- ==== FILES ====
local files = {
--%REPLACE_ME%
}
-- ====

if not component.isAvailable("internet") then
    io.stderr:write("This program requires an internet card to run.\n")
    return
end

function main()
    for i=1, #files do
        local full_file_name = files[i]
        local folder_name, file_name = full_file_name:match("(.-)/?([^/]+)$")

        if folder_name == nil or folder_name == "" then
            folder_name = ""
        else
            folder_name = home_dir .. folder_name .. "/"

            if not fs.exists(folder_name) then
                local success_directory, error_message = fs.makeDirectory(folder_name)
                if success_directory == nil or not success_directory then
                    print("\27[31mERROR: Failed to create directory: " .. error_message .. "\27[m")
                    goto continue
                end
            end
        end

        local source_url = "http://" .. ADDRESS .. "/" .. full_file_name
        local command = "wget -f " .. source_url .. " " .. folder_name .. file_name
        local success = os.execute(command) 
        
        ::continue::
    end
end

main()