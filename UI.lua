local ADDON_NAME, ns = ...
local Notesmith = ns.Notesmith

local ROW_HEIGHT = 32
local LIST_WIDTH = 220
local FRAME_WIDTH = 680
local FRAME_HEIGHT = 480

local mainFrame
local listScroll, listChild
local rowPool = {}
local titleBox, bodyScroll, bodyBox, reminderCheck, charLabel
local selectedId
local reminderFrame

local function FormatDate(stamp)
    if not stamp or stamp == 0 then return "" end
    return date("%Y-%m-%d %H:%M", stamp)
end

local function ApplyDialogBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
end

local function ApplyInsetBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
end

local function SaveWindowPoint()
    if not mainFrame then return end
    local point, _, relPoint, x, y = mainFrame:GetPoint(1)
    if point then
        NotesmithDB.settings.windowPoint = { point, "UIParent", relPoint, x, y }
    end
end

local function RestoreWindowPoint()
    if not mainFrame then return end
    local pt = NotesmithDB.settings.windowPoint
    mainFrame:ClearAllPoints()
    if pt and pt[1] then
        mainFrame:SetPoint(pt[1], UIParent, pt[3] or pt[1], pt[4] or 0, pt[5] or 0)
    else
        mainFrame:SetPoint("CENTER")
    end
end

local function AcquireRow(index)
    local row = rowPool[index]
    if row then return row end

    row = CreateFrame("Button", nil, listChild, "BackdropTemplate")
    row:SetSize(LIST_WIDTH - 32, ROW_HEIGHT - 4)
    row:SetPoint("TOPLEFT", 4, -((index - 1) * ROW_HEIGHT) - 4)

    ApplyInsetBackdrop(row)
    row:SetBackdropColor(0, 0, 0, 0.25)

    row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(1, 1, 1, 0.08)

    row.bell = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.bell:SetPoint("LEFT", 6, 0)
    row.bell:SetWidth(14)
    row.bell:SetText("")

    row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.title:SetPoint("LEFT", row.bell, "RIGHT", 4, 6)
    row.title:SetPoint("RIGHT", -6, 0)
    row.title:SetJustifyH("LEFT")
    row.title:SetWordWrap(false)

    row.date = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.date:SetPoint("LEFT", row.bell, "RIGHT", 4, -7)
    row.date:SetPoint("RIGHT", -6, 0)
    row.date:SetJustifyH("LEFT")
    row.date:SetWordWrap(false)

    row:SetScript("OnClick", function(self)
        ns.OpenEditor(self.noteId)
    end)

    rowPool[index] = row
    return row
end

local function HideRowsFrom(index)
    for i = index, #rowPool do
        if rowPool[i] then rowPool[i]:Hide() end
    end
end

local function HighlightSelectedRow()
    for _, row in ipairs(rowPool) do
        if row:IsShown() then
            if row.noteId == selectedId then
                row:SetBackdropColor(0.2, 0.4, 0.6, 0.55)
            else
                row:SetBackdropColor(0, 0, 0, 0.25)
            end
        end
    end
end

local function RefreshList()
    if not listChild then return end
    local notes = Notesmith:GetSortedNotes()
    for i, note in ipairs(notes) do
        local row = AcquireRow(i)
        row.noteId = note.id
        row.title:SetText(note.title ~= "" and note.title or "Untitled")
        row.date:SetText(FormatDate(note.modified))
        row.bell:SetText(note.reminder and "|cFFFFD700!|r" or "")
        row:Show()
    end
    HideRowsFrom(#notes + 1)
    listChild:SetHeight(math.max(1, #notes * ROW_HEIGHT + 8))
    HighlightSelectedRow()
end

local function ClearEditor()
    selectedId = nil
    titleBox:SetText("")
    bodyBox:SetText("")
    reminderCheck:SetChecked(false)
    charLabel:SetText("")
    titleBox:ClearFocus()
    bodyBox:ClearFocus()
    HighlightSelectedRow()
end

local function LoadEditor(id)
    local note = Notesmith:GetNote(id)
    if not note then ClearEditor() return end
    selectedId = id
    titleBox:SetText(note.title or "")
    bodyBox:SetText(note.body or "")
    reminderCheck:SetChecked(note.reminder and true or false)
    charLabel:SetText(("created %s by %s"):format(FormatDate(note.created), note.origin or "?"))
    HighlightSelectedRow()
end

local function CommitEditor()
    if not selectedId then return end
    Notesmith:UpdateNote(selectedId, {
        title = titleBox:GetText() ~= "" and titleBox:GetText() or "Untitled",
        body = bodyBox:GetText() or "",
        reminder = reminderCheck:GetChecked() and true or false,
    })
    RefreshList()
end

local function BuildMainFrame()
    mainFrame = CreateFrame("Frame", "NotesmithMainFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    ApplyDialogBackdrop(mainFrame)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetToplevel(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveWindowPoint()
    end)
    mainFrame:SetScript("OnHide", function() CommitEditor() end)
    mainFrame:Hide()

    tinsert(UISpecialFrames, "NotesmithMainFrame")

    local titleBg = mainFrame:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetPoint("TOP", 0, 12)
    titleBg:SetSize(320, 64)

    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", titleBg, "TOP", 0, -14)
    title:SetText("Notesmith")

    local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local newBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    newBtn:SetSize(110, 22)
    newBtn:SetPoint("TOPLEFT", 18, -36)
    newBtn:SetText("New Note")
    newBtn:SetScript("OnClick", function()
        CommitEditor()
        local note = Notesmith:CreateNote("New note", "", false)
        RefreshList()
        LoadEditor(note.id)
        titleBox:HighlightText()
        titleBox:SetFocus()
    end)

    local listBg = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    listBg:SetPoint("TOPLEFT", 16, -64)
    listBg:SetPoint("BOTTOMLEFT", 16, 20)
    listBg:SetWidth(LIST_WIDTH)
    ApplyInsetBackdrop(listBg)

    listScroll = CreateFrame("ScrollFrame", "NotesmithListScroll", listBg, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 6, -6)
    listScroll:SetPoint("BOTTOMRIGHT", -26, 6)

    listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetSize(LIST_WIDTH - 32, 1)
    listScroll:SetScrollChild(listChild)

    local editorBg = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    editorBg:SetPoint("TOPLEFT", listBg, "TOPRIGHT", 8, 0)
    editorBg:SetPoint("BOTTOMRIGHT", -16, 56)
    ApplyInsetBackdrop(editorBg)

    local titleLabel = editorBg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    titleLabel:SetPoint("TOPLEFT", 10, -10)
    titleLabel:SetText("Title")

    titleBox = CreateFrame("EditBox", nil, editorBg, "InputBoxTemplate")
    titleBox:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 6, -4)
    titleBox:SetPoint("RIGHT", -16, 0)
    titleBox:SetHeight(20)
    titleBox:SetAutoFocus(false)
    titleBox:SetMaxLetters(120)
    titleBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        CommitEditor()
    end)
    titleBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    titleBox:SetScript("OnEditFocusLost", function() CommitEditor() end)

    local bodyLabel = editorBg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bodyLabel:SetPoint("TOPLEFT", titleBox, "BOTTOMLEFT", -6, -10)
    bodyLabel:SetText("Body")

    local bodyBg = CreateFrame("Frame", nil, editorBg, "BackdropTemplate")
    bodyBg:SetPoint("TOPLEFT", bodyLabel, "BOTTOMLEFT", 0, -4)
    bodyBg:SetPoint("BOTTOMRIGHT", -10, 56)
    ApplyInsetBackdrop(bodyBg)
    bodyBg:SetBackdropColor(0, 0, 0, 0.4)

    bodyScroll = CreateFrame("ScrollFrame", "NotesmithBodyScroll", bodyBg, "UIPanelScrollFrameTemplate")
    bodyScroll:SetPoint("TOPLEFT", 6, -6)
    bodyScroll:SetPoint("BOTTOMRIGHT", -26, 6)

    bodyBox = CreateFrame("EditBox", nil, bodyScroll)
    bodyBox:SetMultiLine(true)
    bodyBox:SetFontObject(ChatFontNormal)
    bodyBox:SetAutoFocus(false)
    bodyBox:SetWidth(1)
    bodyBox:SetMaxLetters(4000)
    bodyBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    bodyBox:SetScript("OnEditFocusLost", function() CommitEditor() end)
    bodyScroll:SetScrollChild(bodyBox)
    bodyScroll:SetScript("OnSizeChanged", function(self, w, h)
        bodyBox:SetWidth(w)
    end)

    reminderCheck = CreateFrame("CheckButton", "NotesmithReminderCheck", editorBg, "UICheckButtonTemplate")
    reminderCheck:SetPoint("BOTTOMLEFT", 8, 8)
    local reminderLabel = reminderCheck.text or reminderCheck.Text or _G["NotesmithReminderCheckText"]
    if reminderLabel then reminderLabel:SetText("Remind me on my next login") end
    reminderCheck:SetScript("OnClick", function() CommitEditor() end)

    charLabel = editorBg:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    charLabel:SetPoint("BOTTOMRIGHT", -10, 12)
    charLabel:SetJustifyH("RIGHT")

    local deleteBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    deleteBtn:SetSize(110, 22)
    deleteBtn:SetPoint("BOTTOMRIGHT", -16, 24)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        if not selectedId then return end
        local id = selectedId
        StaticPopup_Show("NOTESMITH_CONFIRM_DELETE", nil, nil, id)
    end)

    local saveBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    saveBtn:SetSize(110, 22)
    saveBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -8, 0)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function() CommitEditor() end)

    local hintLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hintLabel:SetPoint("BOTTOMLEFT", 20, 28)
    hintLabel:SetText("/notes remind <text>  -  quick reminder")
end

StaticPopupDialogs["NOTESMITH_CONFIRM_DELETE"] = {
    text = "Delete this note?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, id)
        Notesmith:DeleteNote(id)
        if selectedId == id then ClearEditor() end
        RefreshList()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function ns.ShowMainFrame()
    if not mainFrame then return end
    if not mainFrame:IsShown() then
        RestoreWindowPoint()
        RefreshList()
        mainFrame:Show()
    end
end

function ns.ToggleMainFrame()
    if not mainFrame then return end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        ns.ShowMainFrame()
    end
end

function ns.OpenEditor(id)
    if not mainFrame then return end
    if not mainFrame:IsShown() then
        RestoreWindowPoint()
        mainFrame:Show()
    end
    CommitEditor()
    RefreshList()
    LoadEditor(id)
end

local function BuildReminderFrame()
    reminderFrame = CreateFrame("Frame", "NotesmithReminderFrame", UIParent, "BackdropTemplate")
    reminderFrame:SetSize(460, 280)
    reminderFrame:SetPoint("CENTER", 0, 80)
    ApplyDialogBackdrop(reminderFrame)
    reminderFrame:SetFrameStrata("DIALOG")
    reminderFrame:SetToplevel(true)
    reminderFrame:EnableMouse(true)
    reminderFrame:SetMovable(true)
    reminderFrame:RegisterForDrag("LeftButton")
    reminderFrame:SetScript("OnDragStart", reminderFrame.StartMoving)
    reminderFrame:SetScript("OnDragStop", reminderFrame.StopMovingOrSizing)
    reminderFrame:SetClampedToScreen(true)
    reminderFrame:Hide()

    local titleBg = reminderFrame:CreateTexture(nil, "ARTWORK")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetPoint("TOP", 0, 12)
    titleBg:SetSize(280, 64)

    local header = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOP", titleBg, "TOP", 0, -14)
    header:SetText("Notesmith Reminder")

    reminderFrame.counter = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reminderFrame.counter:SetPoint("TOP", 0, -34)

    reminderFrame.title = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    reminderFrame.title:SetPoint("TOPLEFT", 24, -60)
    reminderFrame.title:SetPoint("TOPRIGHT", -24, -60)
    reminderFrame.title:SetJustifyH("LEFT")
    reminderFrame.title:SetWordWrap(true)

    local bodyBg = CreateFrame("Frame", nil, reminderFrame, "BackdropTemplate")
    bodyBg:SetPoint("TOPLEFT", 20, -92)
    bodyBg:SetPoint("BOTTOMRIGHT", -20, 56)
    ApplyInsetBackdrop(bodyBg)
    bodyBg:SetBackdropColor(0, 0, 0, 0.4)

    local bodyScrollR = CreateFrame("ScrollFrame", "NotesmithReminderBodyScroll", bodyBg, "UIPanelScrollFrameTemplate")
    bodyScrollR:SetPoint("TOPLEFT", 6, -6)
    bodyScrollR:SetPoint("BOTTOMRIGHT", -26, 6)

    local bodyText = CreateFrame("EditBox", nil, bodyScrollR)
    bodyText:SetMultiLine(true)
    bodyText:SetFontObject(ChatFontNormal)
    bodyText:SetAutoFocus(false)
    bodyText:EnableMouse(true)
    bodyText:SetWidth(1)
    bodyText:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    bodyScrollR:SetScrollChild(bodyText)
    bodyScrollR:SetScript("OnSizeChanged", function(self, w, h) bodyText:SetWidth(w) end)
    reminderFrame.body = bodyText

    local dismiss = CreateFrame("Button", nil, reminderFrame, "UIPanelButtonTemplate")
    dismiss:SetSize(120, 22)
    dismiss:SetPoint("BOTTOMRIGHT", -20, 20)
    dismiss:SetText("Dismiss")

    local snooze = CreateFrame("Button", nil, reminderFrame, "UIPanelButtonTemplate")
    snooze:SetSize(120, 22)
    snooze:SetPoint("RIGHT", dismiss, "LEFT", -8, 0)
    snooze:SetText("Keep for Next Login")

    local openBtn = CreateFrame("Button", nil, reminderFrame, "UIPanelButtonTemplate")
    openBtn:SetSize(120, 22)
    openBtn:SetPoint("BOTTOMLEFT", 20, 20)
    openBtn:SetText("Open in Notesmith")

    reminderFrame.dismissBtn = dismiss
    reminderFrame.snoozeBtn = snooze
    reminderFrame.openBtn = openBtn
end

local function ShowNext()
    local queue = reminderFrame.queue
    local index = reminderFrame.index
    if not queue or index > #queue then
        reminderFrame:Hide()
        return
    end
    local note = queue[index]
    reminderFrame.currentId = note.id
    reminderFrame.counter:SetText(("Reminder %d of %d"):format(index, #queue))
    reminderFrame.title:SetText(note.title ~= "" and note.title or "Untitled")
    reminderFrame.body:SetText(note.body ~= "" and note.body or "(no body)")
    if not reminderFrame:IsShown() then reminderFrame:Show() end
    if NotesmithDB.settings.soundOnReminder then
        local soundId = (SOUNDKIT and SOUNDKIT.READY_CHECK) or 8960
        PlaySound(soundId)
    end
end

function ns.ShowReminders(list)
    if not reminderFrame then return end
    reminderFrame.queue = list
    reminderFrame.index = 1

    reminderFrame.dismissBtn:SetScript("OnClick", function()
        Notesmith:ClearReminder(reminderFrame.currentId)
        reminderFrame.index = reminderFrame.index + 1
        if listChild then RefreshList() end
        ShowNext()
    end)
    reminderFrame.snoozeBtn:SetScript("OnClick", function()
        reminderFrame.index = reminderFrame.index + 1
        ShowNext()
    end)
    reminderFrame.openBtn:SetScript("OnClick", function()
        local id = reminderFrame.currentId
        Notesmith:ClearReminder(id)
        reminderFrame.index = reminderFrame.index + 1
        if listChild then RefreshList() end
        ns.OpenEditor(id)
        ShowNext()
    end)

    ShowNext()
end

function ns.InitializeUI()
    if mainFrame then return end
    BuildMainFrame()
    BuildReminderFrame()
end
