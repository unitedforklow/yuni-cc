local HttpService = game:GetService("HttpService")

repeat task.wait() until shared.YuniSettings and shared.YuniSettings.Loaded

shared.YuniActions = shared.YuniActions or {}

local function serializeTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = serializeTable(v)
        elseif typeof(v) == "EnumItem" then
            copy[k] = {__enum = tostring(v.EnumType), value = v.Name}
        else
            copy[k] = v
        end
    end
    return copy
end

local function deserializeTable(tbl)
    local restored = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if v.__enum and v.value then
                pcall(function()
                    local enumType = v.__enum:gsub("Enum.", "")
                    restored[k] = Enum[enumType][v.value]
                end)
            else
                restored[k] = deserializeTable(v)
            end
        else
            restored[k] = v
        end
    end
    return restored
end

local function mergeSettings(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            mergeSettings(target[k], v)
        else
            target[k] = v
        end
    end
end

local function saveConfig()
    local success, err = pcall(function()
        if not writefile then return error("writefile is not supported by executor") end
        
        local serialized = serializeTable(shared.YuniSettings)
        local rawJson = HttpService:JSONEncode(serialized)
        
        writefile("yuni_config.json", rawJson)
    end)
    
    if success then
        print("[yuni.cc] Config successfully saved to workspace/yuni_config.json")
    else
        warn("[yuni.cc] Config save failed: " .. tostring(err))
    end
end

local function loadConfig()
    local success, err = pcall(function()
        if not readfile or not isfile then return error("readfile/isfile not supported by executor") end
        if not isfile("yuni_config.json") then return error("No saved config found") end
        
        local rawJson = readfile("yuni_config.json")
        local serialized = HttpService:JSONDecode(rawJson)
        local deserialized = deserializeTable(serialized)
        
        mergeSettings(shared.YuniSettings, deserialized)
    end)
    
    if success then
        print("[yuni.cc] Config successfully loaded!")
    else
        warn("[yuni.cc] Config load failed: " .. tostring(err))
    end
end

shared.YuniActions.SaveConfig = saveConfig
shared.YuniActions.LoadConfig = loadConfig

print("[yuni.cc] Module Configs is loaded.")
