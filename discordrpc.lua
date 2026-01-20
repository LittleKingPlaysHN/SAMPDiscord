local ffi = require("ffi")
local encoding = require("encoding")
encoding.default = "CP1251"

local DISCORD_APP_ID = "1458923064891801805" -- // AQUI PUEDEN PONER EL ID DE SU APP DE DISCORD
local startTimestamp = os.time()
local PLAYER_PED = PLAYER_PED 

ffi.cdef[[
typedef struct DiscordRichPresence {
    const char* state;
    const char* details;
    int64_t startTimestamp;
    int64_t endTimestamp;
    const char* largeImageKey;
    const char* largeImageText;
    const char* smallImageKey;
    const char* smallImageText;
    const char* partyId;
    const char* button1_label;
    const char* button1_url;
    const char* button2_label;
    const char* button2_url;
    int partySize;
    int partyMax;
    int partyPrivacy;
    const char* matchSecret;
    const char* joinSecret;
    const char* spectateSecret;
    int8_t instance;
} DiscordRichPresence;

void Discord_Initialize(const char* applicationId, int handlers, int autoRegister, const char* optionalSteamId);
void Discord_UpdatePresence(const DiscordRichPresence* presence);
void Discord_Shutdown(void);
]]

local discord = ffi.load("moonloader/lib/discord-rpc.dll") -- // TENER OBLIGADO ESTE PARA QUE FUNCIONE

local function initDiscord()
    discord.Discord_Initialize(DISCORD_APP_ID, 0, 1, nil)
    sampAddChatMessage("{00D8FF}[DISCORD-RPC] {CFCFCF}Activado correctamente {FFDD00}By @LittleKingPlays", -1)
end -- // DEJAR CREDITOS RATA NO VAYAS A PONER TU NOMBRE AQUI MMGVO.

local function getServerIP()
    local ip = sampGetCurrentServerAddress()
    if not ip then
        return "IP desconocida"
    end
    return ip
end

local function getStateText()
    local serverIP = getServerIP()

    if not isSampAvailable() then
        return serverIP.." | [???] Desconocido"
    end

    local success, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not success or type(playerId) ~= "number" then
        return serverIP.." | [???] Desconocido"
    end

    local playerName = sampGetPlayerNickname(playerId)
    if not playerName then
        playerName = "Desconocido"
    end

    return serverIP.." | ["..playerId.."] "..playerName
end

local function updateDiscord(serverName, largeImg, smallImg)
    local presence = ffi.new("DiscordRichPresence")

    local stateText = getStateText()
    local success, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not success or type(playerId) ~= "number" then
        playerId = 1
    end

    presence.state = stateText
    presence.details = serverName or "Servidor desconocido"
    presence.startTimestamp = startTimestamp

    presence.largeImageKey = largeImg or "sampking" -- // IMAGEN 1
    presence.largeImageText = "Grand Theft Auto: San Andreas" -- // TEXTO 1
    presence.smallImageKey = smallImg or "sampking" -- // IMAGEN 2
    presence.smallImageText = "Jugando GTA San Andreas Multiplayers" -- // TEXTO 2

    presence.button1_label = "Unirse al servidor"
    presence.button1_url = "https://discord.gg/aportesking-1206772406983721010" -- PONER TU LINK AQUI

    presence.button2_label = "Visitar web"
    presence.button2_url = "https://sampking.vercel.app" -- // PONER TU LINK AQUI

    presence.partySize = playerId
    presence.partyMax = 1000
    presence.instance = 0

    discord.Discord_UpdatePresence(presence)
end

function main()
    wait(5000)

    if not isSampAvailable() then
        sampAddChatMessage("{00D8FF}[DISCORD-RPC] {FFA000}SAMP {FFFFFF}no está disponible", -1)
        return
    end

    initDiscord()

    while true do
        wait(15000)
        local serverName = sampGetCurrentServerName() or "Servidor desconocido"
        updateDiscord(serverName, "logo", "smalllogo")
    end
end

function onScriptTerminate(script, quitGame)
    discord.Discord_Shutdown()
end