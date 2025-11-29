local os = require("os")
local fs = require("filesystem")

local home_dir = "/home/"

-- ==== FILES ====
local files = {
--%REPLACE_ME%
}
-- ====

for i=1, #files do
    local full_path = files[i]
    local folder_name, file_name = full_path:match("(.-)/?([^/]+)$")

    if folder_name == nil or folder_name == "" then
        local full_file_name = home_dir .. file_name
        print("removing file " .. full_file_name .. "...")
        os.execute("rm -f " .. full_file_name)
    else
        local full_folder_path = home_dir .. folder_name
        if fs.exists(full_folder_path) then
            print("removing dir " .. full_folder_path .. "/...")
            os.execute("rm -rf " .. full_folder_path)
        end
    end
end

print("\27[32muninstall complete.\27[m")