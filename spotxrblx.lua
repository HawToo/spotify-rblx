
local Radius = 30
local Prefix = "/"

if not game.Loaded then game.Loaded:Wait() end


local HttpService = game:GetService("HttpService")
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Blacklist = {}
local Requests = {
    ["NextSong"] = {
        Url = "https://api.spotify.com/v1/me/player/next",
        Method = "POST",
        Headers = {
            ["Accept"] = "application/json",
            ["Authorization"] = "Bearer " .. APIKey,
            ["Content-Type"] = "application/json"
        }
    },
    ["Pause"] = {
        Url = "https://api.spotify.com/v1/me/player/pause",
        Method = "PUT",
        Headers = {
            ["Accept"] = "application/json",
            ["Authorization"] = "Bearer " .. APIKey,
            ["Content-Type"] = "application/json"
        }
    },
    ["Start"] = {
        Url = "https://api.spotify.com/v1/me/player/play",
        Method = "PUT",
        Headers = {
            ["Accept"] = "application/json",
            ["Authorization"] = "Bearer " .. APIKey,
            ["Content-Type"] = "application/json"
        }
    }
}

local Request = syn and syn.request or request or http_request or http.request

local GetFullName = function(Name)
    for _, CurrentPlayer in ipairs(Players:GetPlayers()) do
        local SubName = string.lower(CurrentPlayer.DisplayName):sub(1, #Name)
        
        if SubName == string.lower(Name) then
            return CurrentPlayer.Name
        end
    end
end

local searchSongs = function(query, limit)
    local resp = Request(
        {
            Url = "https://api.spotify.com/v1/search?q=" ..  HttpService:UrlEncode(query) .. "&type=track&limit=" .. limit,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json",
                ["Authorization"] = "Bearer " .. APIKey,
                ["Content-Type"] = "application/json"
            }
        }
    )
    local Items = HttpService:JSONDecode(resp.Body).tracks.items
    
    for _,Item in ipairs(Items) do
        local artists = Item.artists
        
        for _,Artist in ipairs(artists) do
            if Artist.name == artists[1].name then
                continue;
            end
        end
        print(Item.name)
        return Item.uri
    end
end


local addSong = function(uri)
    local resp = Request({
        Url = "https://api.spotify.com/v1/me/player/queue?uri=" .. HttpService:UrlEncode(uri),
        Method = "POST",
        Headers = {
            ["Accept"] = "application/json",
            ["Authorization"] = "Bearer " .. APIKey,
            ["Content-Type"] = "application/json"
        }
    })
    return resp
end

--[[
local song = searchSongs("holocaust", 1)
addSong(song)
syn.request(requests["NextSong"])
]]

local Commands = {
    play = function(speaker, arguments)
        if speaker ~= LocalPlayer and not table.find(Blacklist, speaker.Name) then
            local Distance = (speaker.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if Distance <= Radius then
                local songName = table.concat(arguments, " ")
                local song = searchSongs(tostring(songName), 1)
                if not song then
                    print("Song not found")
                    return
                end
                local Response = addSong(song)
                if Response.StatusCode ~= 204 then
                    print("Error adding song")
                    return
                end
                Request(Requests["NextSong"])
                print("Song name: " .. songName)
            end
        end
    end,
    pause = function(speaker, arguments)
        if speaker ~= LocalPlayer and not table.find(Blacklist, speaker.Name) then
            Request(Requests["Pause"])
            print("Song has been paused")
        end
    end,
    unpause = function(speaker, arguments)
        if speaker ~= LocalPlayer and not table.find(Blacklist, speaker.Name) then
            Request(Requests["Start"])
            print("Song has been started")
        end
    end,
    bl = function(speaker, arguments)
        if speaker == LocalPlayer then
            local User = GetFullName(arguments[1])
            if not User then
                print("User not found")
                return
            end
            Blacklist[User] = not Blacklist[User]
            print("Player " .. User .. (Blacklist[User] and " blacklisted" or " unblacklisted"))
        end
    end
}

function ProcessCommand(speaker, message)
    if message:sub(1, 1) == Prefix then
        local Arguments = message:sub(2):split(" ")
        local Command = Arguments[1]
        table.remove(Arguments, 1)
        if Commands[Command] then
            Commands[Command](speaker, Arguments)
        end
    end
end

for _,v in pairs(Players:GetPlayers()) do
    v.Chatted:Connect(function(msg)
        ProcessCommand(v, msg)
    end)
end


Players.PlayerAdded:connect(function(plr)
    plr.Chatted:Connect(function(msg)
        ProcessCommand(plr, msg)
    end)
end)
