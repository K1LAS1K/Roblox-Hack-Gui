-- KILASIK Loader Script
local function loadPart(number)
    return game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Roblox-Hack-Gui/main/part" .. number .. ".lua")
end

-- Load and run all parts sequentially
local fullScript = loadPart(1) .. loadPart(2) .. loadPart(3) .. loadPart(4) .. loadPart(5)
loadstring(fullScript)()
