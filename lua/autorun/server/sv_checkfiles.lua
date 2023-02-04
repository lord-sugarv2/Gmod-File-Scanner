local data = {}
local function AddFile(File, dir)
    local fileSide = string.lower(string.Left(File , 3))
    local newdata = file.Read(dir..File, "GAME")
    if File == "sv_checkfiles.lua" then return end
    table.Add(data, {{dir..File, string.lower(newdata)}})
end

local function IncludeDir(dir)
    dir = dir .. "/"
    local File, Directory = file.Find(dir.."*", "GAME")

    for k, v in ipairs(File) do
        if string.EndsWith(v, ".lua") then
            AddFile(v, dir)
        end
    end
    
    for k, v in ipairs(Directory) do
        IncludeDir(dir..v)
    end
end

local function CacheFiles()
    IncludeDir("addons")
end

local function FindWord(str, ply)
    str = string.lower(str)

    local found, count = false, 1
    local newfile = {}
    for k, v in ipairs(data) do
        local wordStart, wordEnd = string.find(v[2], str)
        if not wordStart then continue end
        table.Add(newfile, {{v[1], wordStart, wordEnd}})
    end

    local newdata = {}
    for k, v in ipairs(newfile) do
        table.insert(newdata, "#"..k..": "..v[1].." at character pos "..v[2].." - "..v[3])
    end
    
    ply = ply or nil
    if IsValid(ply) then
        local senddata = util.Compress(util.TableToJSON(newdata))
        net.Start("FileChecker:ReceiveFiles")
        net.WriteUInt(#senddata, 32)
        net.WriteData(senddata)
        net.WriteString(str)
        net.Send(ply)
    end
    ply.RunningScan = false
end
CacheFiles()

util.AddNetworkString("FileChecker:ReceiveFiles")
util.AddNetworkString("LFileChecker:Request")
net.Receive("LFileChecker:Request", function(len, ply)
    local str = net.ReadString()
    ply.RunningScan = false
    if ply.RunningScan then print("!stop") return end
    ply.RunningScan = true
    FindWord(str, ply)
end)