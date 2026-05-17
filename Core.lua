local ADDON_NAME, ns = ...

local Notesmith = CreateFrame("Frame", "NotesmithCoreFrame")
ns.Notesmith = Notesmith
_G.Notesmith = Notesmith

local DEFAULTS = {
    notes = {},
    nextId = 1,
    settings = {
        soundOnReminder = true,
        autoOpenOnReminder = true,
        autoOpenOnLogin = true,
        windowPoint = { "CENTER", "UIParent", "CENTER", 0, 0 },
    },
    schema = 1,
}

local PREFIX = "|cFF7FFFD4Notesmith:|r "

local function applyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = CopyTable(value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            applyDefaults(target[key], value)
        end
    end
end

function Notesmith:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. tostring(msg))
end

function Notesmith:GetDB()
    return NotesmithDB
end

function Notesmith:CreateNote(title, body, reminder)
    local db = NotesmithDB
    local id = db.nextId or 1
    db.nextId = id + 1
    local now = time()
    local note = {
        id = id,
        title = (title and title ~= "") and title or "Untitled",
        body = body or "",
        created = now,
        modified = now,
        reminder = reminder and true or false,
        origin = (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?"),
    }
    db.notes[id] = note
    return note
end

function Notesmith:UpdateNote(id, fields)
    local note = NotesmithDB.notes[id]
    if not note then return end
    for k, v in pairs(fields) do
        note[k] = v
    end
    note.modified = time()
    return note
end

function Notesmith:DeleteNote(id)
    NotesmithDB.notes[id] = nil
end

function Notesmith:GetNote(id)
    return NotesmithDB.notes[id]
end

function Notesmith:GetSortedNotes()
    local list = {}
    for _, note in pairs(NotesmithDB.notes) do
        list[#list + 1] = note
    end
    table.sort(list, function(a, b)
        if a.reminder ~= b.reminder then
            return a.reminder and not b.reminder
        end
        return (a.modified or 0) > (b.modified or 0)
    end)
    return list
end

function Notesmith:GetPendingReminders()
    local list = {}
    for _, note in pairs(NotesmithDB.notes) do
        if note.reminder then
            list[#list + 1] = note
        end
    end
    table.sort(list, function(a, b) return (a.created or 0) < (b.created or 0) end)
    return list
end

function Notesmith:ClearReminder(id)
    local note = NotesmithDB.notes[id]
    if note then
        note.reminder = false
        note.modified = time()
    end
end

function Notesmith:CountNotes()
    local n = 0
    for _ in pairs(NotesmithDB.notes) do n = n + 1 end
    return n
end

Notesmith:RegisterEvent("ADDON_LOADED")
Notesmith:RegisterEvent("PLAYER_LOGIN")
Notesmith:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        NotesmithDB = NotesmithDB or {}
        applyDefaults(NotesmithDB, DEFAULTS)
        if ns.InitializeUI then
            ns.InitializeUI()
        end
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(3, function()
            if NotesmithDB.settings.autoOpenOnLogin and ns.ShowMainFrame then
                ns.ShowMainFrame()
            end
            local pending = Notesmith:GetPendingReminders()
            if #pending > 0 and ns.ShowReminders then
                ns.ShowReminders(pending)
            end
        end)
    end
end)

local function trim(s)
    return (s and s:gsub("^%s+", ""):gsub("%s+$", "")) or ""
end

local function printHelp()
    Notesmith:Print("commands:")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith|r - toggle the window")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith new|r [title] - create and open a note")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith remind|r <text> - set a reminder for next login")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith list|r - list all notes in chat")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith clear|r - clear all pending reminders")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith auto|r - toggle auto-open on login")
    DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFD700/notesmith help|r - this message")
end

SLASH_NOTESMITH1 = "/notesmith"
SlashCmdList["NOTESMITH"] = function(msg)
    msg = trim(msg)
    if msg == "" then
        if ns.ToggleMainFrame then ns.ToggleMainFrame() end
        return
    end

    local cmd, rest = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""
    rest = trim(rest or "")

    if cmd == "new" or cmd == "add" then
        local note = Notesmith:CreateNote(rest ~= "" and rest or "New note", "", false)
        if ns.OpenEditor then ns.OpenEditor(note.id) end
    elseif cmd == "remind" or cmd == "reminder" then
        if rest == "" then
            Notesmith:Print("usage: /notesmith remind <text>")
        else
            local note = Notesmith:CreateNote(rest, "", true)
            Notesmith:Print("reminder set for next login: " .. note.title)
        end
    elseif cmd == "list" then
        local list = Notesmith:GetSortedNotes()
        Notesmith:Print(#list .. " note(s)")
        for _, n in ipairs(list) do
            local mark = n.reminder and " |cFFFFD700[reminder]|r" or ""
            DEFAULT_CHAT_FRAME:AddMessage(("  [%d] %s%s"):format(n.id, n.title, mark))
        end
    elseif cmd == "clear" then
        local cleared = 0
        for _, n in pairs(NotesmithDB.notes) do
            if n.reminder then
                n.reminder = false
                cleared = cleared + 1
            end
        end
        Notesmith:Print("cleared " .. cleared .. " pending reminder(s)")
    elseif cmd == "auto" then
        NotesmithDB.settings.autoOpenOnLogin = not NotesmithDB.settings.autoOpenOnLogin
        Notesmith:Print("auto-open on login: " .. (NotesmithDB.settings.autoOpenOnLogin and "ON" or "OFF"))
    elseif cmd == "help" or cmd == "?" then
        printHelp()
    else
        if ns.ToggleMainFrame then ns.ToggleMainFrame() end
    end
end
