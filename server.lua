local logs = "Change this to your webhook"
local communityname = "Big Yoda"
local communtiylogo = "https://i.imgur.com/e8VsdLL.jpg" --Must end with .png or .jpg

function hexToDecimalColor(hex)
    hex = hex:gsub("#","")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local decimalColor = (r * 256 + g) * 256 + b
    return decimalColor;
end

local function sendWebhook(content)
    embed = {
        {
            ["color"] = hexToDecimalColor(Config.color or '#014468'),
            ["title"] = content.title,
            ["description"] = content.description
        }
    }
    PerformHttpRequest(Config.webhook, function(err, text, headers) 
        print(err)
        print(text)
        print(table.concat(headers))
    end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' });
end

local function getUserDetails(src)
    local steamid  = ''
    local discord  = ''
    for k,v in pairs(GetPlayerIdentifiers(src))do            
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v:gsub("steam:", "")
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v:gsub("discord:", "")
        end
    end
    return steamid, discord;
end
local function hexToDecimal(hexValue)
    if not hexValue then return '' end;
    if not type(hexValue)=="string" then return '' end
    if hexValue == '' then return '' end;
    local decimalValue = tonumber(hexValue, 16)
    return decimalValue
end
-- The below function is from txAdmin
local function getLogPlayerName(src) if type(src) == 'number' then local name = sub(GetPlayerName(src) or "unknown", 1, 75) return '[#'..src..'] '..name else return '[??] '.. (src or "unknown") end end

if Config.logs.playerConnecting then
    AddEventHandler('playerConnecting', function()
        if source == 0 or not source then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        local ip = GetPlayerEndpoint(source);
        local discordString = ''
        if discord then
            discordString = "\n\n- Discord ID: ["..discord.."](https://discordlookup.com/user/"..discord..")"
        end
        sendWebhook({
            ["title"] = "Player Connecting",
            ["description"] = "Player [".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") is connecting to the server." ..  discordString .. "\n\nIP: ||`"..ip.."`||",
        })
    end)
end
if Config.logs.playerDropped then
    AddEventHandler('playerDropped', function(reason)
        if source == 0 or not source then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        local ip = GetPlayerEndpoint(source);
        local discordString = ''
        if discord then
            discordString = "\n\n- Discord ID: ["..discord.."](https://discordlookup.com/user/"..discord..")"
        end
        sendWebhook({
            ["title"] = "Player Disconnected",
            ["description"] = "Player [".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has disconnected from the server." .. discordString .. "\n\n- IP: ||`"..ip.."`||",
        })
    end)
end
if Config.logs.playerDeath then
    AddEventHandler('txsv:logger:deathEvent', function(killer, deathReason)
        if source == 0 or not source then return end
        local vName = GetPlayerName(source);
        local vSteam,vDiscord = getUserDetails(source);
        if killer then
            local kName = GetPlayerName(killer);
            local kSteam,kDiscord = getUserDetails(killer);
            sendWebhook({
                ["title"] = "Player Killed",
                ["description"] = "[".. vName .."](https://steamcommunity.com/profiles/".. hexToDecimal(vSteam) ..") has been killed by [".. kName .."](https://steamcommunity.com/profiles/".. hexToDecimal(kSteam) ..")\nCause: " .. deathReason,
            })
        else
            sendWebhook({
                ["title"] = "Player Killed",
                ["description"] = "[".. vName .."](https://steamcommunity.com/profiles/".. hexToDecimal(vSteam) ..") has died from " .. deathReason,
            })
        end
    end)
end
if Config.logs.menuEvent then
    AddEventHandler('txsv:logger:menuEvent', function(source, action, allowed, data)
        if source == 0 or not source then return end
        if not allowed then return end
        local message
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        local discordString = ''
        if discord then
            discordString = "\n\n- Discord ID: ["..discord.."](https://discordlookup.com/user/"..discord..")"
        end
        if action == 'playerModeChanged' then
            if data == 'godmode' then
                message = "enabled god mode"
            elseif data == 'noclip' then
                message = "enabled noclip"
            elseif data == 'superjump' then
                message = "enabled super jump"
            elseif data == 'none' then
                message = "became mortal (standard mode)"
            else
                message = "changed playermode to unknown"
            end
        elseif action == 'teleportWaypoint' then
            message = "teleported to a waypoint"
        elseif action == 'teleportCoords' then
            if type(data) ~= 'table' then return end
            local x = data.x
            local y = data.y
            local z = data.z
            message = ("teleported to coordinates (x=%.3f, y=%0.3f, z=%0.3f)"):format(x or 0.0, y or 0.0, z or 0.0)
        elseif action == 'spawnVehicle' then
            if type(data) ~= 'string' then return end
            message = "spawned a vehicle (model: " .. data .. ")"
        elseif action == 'deleteVehicle' then
            message = "deleted a vehicle"
        elseif action == 'vehicleRepair' then
            message = "repaired their vehicle"
        elseif action == 'vehicleBoost' then
            message = "boosted their vehicle"
        elseif action == 'healSelf' then
            message = "healed themself"
        elseif action == 'healAll' then
            message = "healed all players!"
        elseif action == 'announcement' then
            if type(data) ~= 'string' then return end
            message = "made a server-wide announcement: " .. data
        elseif action == 'clearArea' then
            if type(data) ~= 'number' then return end
            message = "cleared an area with ".. data .."m radius"
        elseif action == 'spectatePlayer' then
            message = 'started spectating player ' .. getLogPlayerName(data)
        elseif action == 'freezePlayer' then
            message = 'toggled freeze on player ' .. getLogPlayerName(data)
        elseif action == 'teleportPlayer' then
            if type(data) ~= 'table' then return end
            local playerName = getLogPlayerName(data.target)
            local x = data.x or 0.0
            local y = data.y or 0.0
            local z = data.z or 0.0
            message = ("teleported to player %s (x=%.3f, y=%.3f, z=%.3f)"):format(playerName, x, y, z)
        elseif action == 'healPlayer' then
            message = "healed player " .. getLogPlayerName(data)
        elseif action == 'summonPlayer' then
            message = "summoned player " .. getLogPlayerName(data)
        elseif action == 'drunkEffect' then
            message = "triggered drunk effect on " .. getLogPlayerName(data)
        elseif action == 'setOnFire' then
            message = "set ".. getLogPlayerName(data) .." on fire" 
        elseif action == 'wildAttack' then
            message = "triggered wild attack on " .. getLogPlayerName(data)
        elseif action == 'showPlayerIDs' then
            if type(data) ~= 'boolean' then return end
            if data then
                message = "turned show player IDs on"
            else
                message = "turned show player IDs off"
            end
        else
            sendWebhook({
                ["title"] = "Menu Event",
                ["description"] = "Player [".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has used the TxAdmin menu." .. discordString .. "\n\n- **Action:** " .. action .. "\n- **Details:** unknown menu event",
            });
            return
        end
        sendWebhook({
            ["title"] = "Menu Event",
            ["description"] = "Player [".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has used the TxAdmin menu." .. discordString .. "\n\n- **Action:** " .. action .. "\n- **Details:** " .. message,
        });
    end)
end
if Config.logs.CommandExecuted then
    RegisterNetEvent('txaLogger:CommandExecuted', function(data)
        if source == 0 or not source then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        local discordString = ''
        if discord then
            discordString = "\n\n- Discord ID: ["..discord.."](https://discordlookup.com/user/"..discord..")"
        end
        sendWebhook({
            ["title"] = "Command Executed",
            ["description"] = "[".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has used a command." .. discordString .. "\n\n- **Details:**\n```".. tostring(data) .. "```",
        });
    end)
end
if Config.logs.resourceStarted then
    AddEventHandler('onResourceStart', function(resource)
        if source == 0 or source == '' then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        sendWebhook({
            ["title"] = "Resource Started",
            ["description"] = "[".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has started `" .. resource .. "`.",
        });
    end)
end
if Config.logs.resourceStopped then
    AddEventHandler('onResourceListRefresh', function(resource)
        if source == 0 or source == '' then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        sendWebhook({
            ["title"] = "Resource List Refresh",
            ["description"] = "[".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has refreshed the resource list.",
        });
    end)
end
if Config.logs.resourceRefreshed then
    AddEventHandler('onResourceStop', function(resource)
        if source == 0 or source == '' then return end
        local name = GetPlayerName(source);
        local steam,discord = getUserDetails(source);
        sendWebhook({
            ["title"] = "Resource Stopped",
            ["description"] = "[".. name .."](https://steamcommunity.com/profiles/".. hexToDecimal(steam) ..") has stopped `" .. resource .. "`.",
        });
    end)
end