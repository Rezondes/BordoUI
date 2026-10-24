-- =========================================================================
-- Bordo UI: Party Unit Frames (PartyFrames.lua)
-- Ported 1:1 from SurvivorUI (Copyright (C) 2026 morderous - GPL-3.0)
-- Optimized for Azeroth Survivors (Interface 11200 / Lua 5.0)
--
-- Features:
-- - Sleek, flat unit row for each party member (party1 to party4)
-- - Class icon on the left with leader crown overlay
-- - Class-colored health bar with teammate name and health percentage
-- - Co-op states: DOWN (crimson red fill/text), Reviving % (gold rescue bar),
--   Reviving you (gold text when teammate rescues you), Offline (gray)
-- - Hover tooltip: Live damage this run, DPS, and top damage spell
-- - Click to target teammate
-- - Anchored directly to the left of the player frame (SurvivorUIPlayer),
--   stacked upwards from bottom to top (party1 at bottom)
-- - Revive Bar: Shows rescue progress while down or reviving a friend
-- - Alt-drag or Shift-drag to move party frames freely
-- - Live test mode: /bordo party test toggles sample party frames
-- =========================================================================

BordoUI = BordoUI or {}
BordoUI.Party = BordoUI.Party or {}

local FLAT = "Interface\\ChatFrame\\ChatFrameBackground"
local FONT_PATH = "Fonts\\FRIZQT__.TTF"
local FONT_BUMP = 0

local ICON = 24                  -- Class icon: 24x24 square matching row height
local BAR_WIDTH = 140
local ROW_HEIGHT = 24
local ROW_GAP = 5
local MOST = 4                   -- party1 to party4
local ROW_WIDTH = ICON + 1 + BAR_WIDTH
local REVIVE_WIDTH, REVIVE_HEIGHT = 240, 16
local LEADER_ICON = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
local CLASS_ICONS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"

local DOWN_FILL   = { 0.30, 0.07, 0.07 }
local DOWN_TEXT   = { 1.00, 0.36, 0.30 }
local GOLD        = { 1.00, 0.82, 0.00 }
local REVIVE_FILL = { 1.00, 0.76, 0.18 }
local RESCUE_FILL = { 0.36, 0.90, 0.42 }

local CLASS_ICON_COORDS = {
	["WARRIOR"] = { 0,    0.25, 0,    0.25 },
	["MAGE"]    = { 0.25, 0.50, 0,    0.25 },
	["ROGUE"]   = { 0.50, 0.75, 0,    0.25 },
	["DRUID"]   = { 0.75, 1.00, 0,    0.25 },
	["HUNTER"]  = { 0,    0.25, 0.25, 0.50 },
	["SHAMAN"]  = { 0.25, 0.50, 0.25, 0.50 },
	["PRIEST"]  = { 0.50, 0.75, 0.25, 0.50 },
	["WARLOCK"] = { 0.75, 1.00, 0.25, 0.50 },
	["PALADIN"] = { 0,    0.25, 0.50, 0.75 },
}

local CLASS_COLORS = {
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43 },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73 },
	["HUNTER"]  = { r = 0.67, g = 0.83, b = 0.45 },
	["ROGUE"]   = { r = 1.00, g = 0.96, b = 0.41 },
	["PRIEST"]  = { r = 0.90, g = 0.90, b = 0.90 },
	["SHAMAN"]  = { r = 0.00, g = 0.44, b = 0.87 },
	["MAGE"]    = { r = 0.41, g = 0.80, b = 0.94 },
	["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79 },
	["DRUID"]   = { r = 1.00, g = 0.49, b = 0.04 },
}

local function Num(value)
	return tonumber(value) or 0
end

local function Short(value)
	if SurvivorUI_Abbrev then
		return SurvivorUI_Abbrev(value)
	end
	value = Num(value)
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fk", value / 1000)
	end
	return tostring(math.floor(value + 0.5))
end

local function Percent(share)
	return math.floor(Num(share) * 100 + 0.5).."%"
end

local function Named(value)
	if value ~= nil and value ~= "" and value ~= 0 then
		return tostring(value)
	end
	return nil
end

local function Safe(call, unit)
	if not call then
		return nil
	end
	local ok, value = pcall(call, unit)
	if ok then
		return value
	end
	return nil
end

local function ClassColor(class)
	if SurvivorUI_ClassColor then
		return SurvivorUI_ClassColor(class)
	end
	if class then
		local c = CLASS_COLORS[class] or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class])
		if c then
			return c.r, c.g, c.b
		end
	end
	return 0.6, 0.6, 0.6
end

local function SetClassIcon(texture, class)
	local coords = class and CLASS_ICON_COORDS[class]
	if coords then
		local cutX = (coords[2] - coords[1]) * 0.1
		local cutY = (coords[4] - coords[3]) * 0.1
		texture:SetTexture(CLASS_ICONS)
		texture:SetTexCoord(coords[1] + cutX, coords[2] - cutX, coords[3] + cutY, coords[4] - cutY)
	else
		texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end
end

-- Party lines from Azeroth Survivors party meter API
local lastLines, lastLinesAt

local function PartyLines()
	if AZS_PARTY and table.getn(AZS_PARTY) > 0 then
		return AZS_PARTY
	end
	if lastLines and lastLinesAt and (GetTime() - lastLinesAt < 60) then
		return lastLines
	end
	return nil
end

local function LineOf(name)
	local lines = PartyLines()
	if not (lines and name) then
		return nil
	end
	for index = 1, table.getn(lines) do
		if lines[index].name == name then
			return lines[index]
		end
	end
	return nil
end

local function Revive()
	return (AZS_GetRevive and AZS_GetRevive()) or {}
end

local function Members()
	local count = Safe(GetNumPartyMembers) or 0
	return math.min(MOST, Num(count))
end

local function Text(parent, size, point, x, y)
	local text = parent:CreateFontString(nil, "OVERLAY")
	text:SetFont(FONT_PATH, size + FONT_BUMP, "OUTLINE")
	text:SetPoint(point, parent, point, x, y)
	return text
end

local function Border(frame)
	local border = frame:CreateTexture(nil, "BACKGROUND")
	border:SetTexture(FLAT)
	border:SetVertexColor(0, 0, 0, 1)
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
	local backing = frame:CreateTexture(nil, "BORDER")
	backing:SetTexture(FLAT)
	backing:SetVertexColor(0.09, 0.09, 0.11, 1)
	backing:SetAllPoints(frame)
end

local function FlatBar(parent, width, height)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetWidth(width)
	bar:SetHeight(height)
	bar:SetStatusBarTexture(FLAT)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	return bar
end

-- =========================================================================
-- Party Container Frame
-- =========================================================================
local holder = CreateFrame("Frame", "SurvivorUIParty", UIParent)
holder:SetWidth(ROW_WIDTH)
holder:SetHeight(ROW_HEIGHT)
holder:SetMovable(true)
holder:EnableMouse(true)
holder:RegisterForDrag("LeftButton")
holder:SetClampedToScreen(true)
holder:Hide()
BordoUIParty = holder
BordoUI.Party.holder = holder

local function PlaceFrames()
	holder:ClearAllPoints()
	local db = BordoUIDB or SurvivorUIDB
	if db and db.partyLeft and db.partyBottom then
		holder:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.partyLeft, db.partyBottom)
		return
	end
	local player = getglobal("SurvivorUIPlayer")
	if player and player:IsVisible() then
		holder:SetPoint("BOTTOMRIGHT", player, "BOTTOMLEFT", -14, 0)
	else
		holder:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 12, 260)
	end
end

local function SaveFrames()
	BordoUIDB = BordoUIDB or {}
	BordoUIDB.partyLeft = math.floor(holder:GetLeft() + 0.5)
	BordoUIDB.partyBottom = math.floor(holder:GetBottom() + 0.5)
	PlaceFrames()
end

-- Global export to prevent any nil call errors
SaveFrames = SaveFrames
PlaceFrames = PlaceFrames

holder:SetScript("OnDragStart", function()
	if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
		holder:StartMoving()
	end
end)
holder:SetScript("OnDragStop", function()
	holder:StopMovingOrSizing()
	SaveFrames()
end)
local rows = {}

local function Tip(row)
	local unit = row.unit
	local name, class, race = row.sample and row.sample.name, row.sample and row.sample.class, nil
	if not row.sample then
		if not UnitExists(unit) then
			return
		end
		name, race = UnitName(unit), UnitRace(unit)
		local _, token = UnitClass(unit)
		class = token
	end
	local r, g, b = ClassColor(class)
	GameTooltip:SetOwner(row, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", row, "TOPLEFT", 0, 6)
	GameTooltip:SetText(name or "?", r, g, b)
	local kind = (race and (race.." ") or "")..(row.className or "")
	if kind ~= "" then
		GameTooltip:AddLine(kind, 0.8, 0.8, 0.8)
	end
	if not row.sample then
		GameTooltip:AddDoubleLine("Health", Short(UnitHealth(unit)).." / "..Short(UnitHealthMax(unit)), 0.8, 0.8, 0.8, 1, 1, 1)
	end
	local line = row.sample or LineOf(name)
	if line and line.dmg then
		GameTooltip:AddDoubleLine("Damage this run", Short(line.dmg).."  ("..Percent(line.share)..")", 0.8, 0.8, 0.8, 1, 1, 1)
		GameTooltip:AddDoubleLine("Damage per second", Short(line.dps), 0.8, 0.8, 0.8, 1, 1, 1)
		if Named(line.top) then
			GameTooltip:AddDoubleLine("Top spell", line.top.."  ("..Short(line.topdps).." dps)", 0.8, 0.8, 0.8, 1, 0.82, 0)
		end
	end
	if row.sample then
		GameTooltip:AddLine("A sample: your friends show here in a party.", 0.6, 0.6, 0.65, 1)
	else
		GameTooltip:AddLine("Click to target.", 0.6, 0.6, 0.65)
	end
	GameTooltip:Show()
end

local function Row(index)
	if rows[index] then
		return rows[index]
	end
	local row = CreateFrame("Button", nil, holder)
	row:SetWidth(ROW_WIDTH)
	row:SetHeight(ROW_HEIGHT)
	-- Stacks from the bottom up: party1 at bottom, party2..4 above
	row:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 0, (index - 1) * (ROW_HEIGHT + ROW_GAP))
	row.unit = "party"..index

	row.icon = CreateFrame("Frame", nil, row)
	row.icon:SetWidth(ICON)
	row.icon:SetHeight(ICON)
	row.icon:SetPoint("LEFT", row, "LEFT", 0, 0)
	Border(row.icon)
	row.icon.texture = row.icon:CreateTexture(nil, "ARTWORK")
	row.icon.texture:SetAllPoints(row.icon)

	-- Leader crown icon
	row.leader = row.icon:CreateTexture(nil, "OVERLAY")
	row.leader:SetTexture(LEADER_ICON)
	row.leader:SetWidth(13)
	row.leader:SetHeight(13)
	row.leader:SetPoint("TOPLEFT", row.icon, "TOPLEFT", -5, 6)
	row.leader:Hide()

	-- Health bar
	row.health = FlatBar(row, BAR_WIDTH, ROW_HEIGHT)
	row.health:SetPoint("LEFT", row.icon, "RIGHT", 1, 0)
	Border(row.health)

	-- Revive bar fill
	row.revive = FlatBar(row.health, BAR_WIDTH, ROW_HEIGHT)
	row.revive:SetAllPoints(row.health)
	row.revive:SetFrameLevel(row.health:GetFrameLevel() + 1)
	row.revive:SetStatusBarColor(REVIVE_FILL[1], REVIVE_FILL[2], REVIVE_FILL[3], 0.85)
	row.revive:Hide()

	row.texts = CreateFrame("Frame", nil, row.health)
	row.texts:SetAllPoints(row.health)
	row.texts:SetFrameLevel(row.health:GetFrameLevel() + 2)
	row.name = Text(row.texts, 10, "LEFT", 5, 0)
	row.name:SetHeight(12)
	row.name:SetJustifyH("LEFT")
	row.value = Text(row.texts, 10, "RIGHT", -5, 0)

	row:RegisterForClicks("LeftButtonUp")
	row:SetScript("OnClick", function()
		if not this.sample and UnitExists(this.unit) then
			TargetUnit(this.unit)
		end
	end)
	row:SetScript("OnEnter", function() Tip(this) end)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)

	-- Movable dragging support: Left-drag or Alt-drag moves entire holder
	row:RegisterForDrag("LeftButton")
	row:SetScript("OnDragStart", function()
		if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
			holder:StartMoving()
		end
	end)
	row:SetScript("OnDragStop", function()
		holder:StopMovingOrSizing()
		SaveFrames()
	end)

	rows[index] = row
	return row
end

local function SetName(row, name, room)
	if row.shownName == name and row.nameRoom == room then
		return
	end
	row.shownName, row.nameRoom = name, room
	row.name:SetWidth(0)
	row.name:SetText(name)
	if row.name:GetStringWidth() > room then
		local _, _, first = string.find(name, "^(%S+)")
		row.name:SetText(first or name)
	end
	row.name:SetWidth(room)
end

local function Paint(row, friend)
	row.className = friend.className
	if row.classShown ~= friend.class then
		row.classShown = friend.class
		SetClassIcon(row.icon.texture, friend.class)
	end
	local r, g, b = ClassColor(friend.class)
	local share = friend.most > 0 and (friend.health / friend.most) or 0
	local value, color = Percent(share), { 1, 1, 1 }
	if friend.offline then
		row.health:SetValue(1)
		row.health:SetStatusBarColor(0.25, 0.25, 0.28, 1)
		value, color = "Offline", { 0.6, 0.6, 0.65 }
	elseif friend.down then
		row.health:SetValue(1)
		row.health:SetStatusBarColor(DOWN_FILL[1], DOWN_FILL[2], DOWN_FILL[3], 1)
		value, color = "DOWN", DOWN_TEXT
	else
		row.health:SetValue(share)
		row.health:SetStatusBarColor(r, g, b, 1)
	end
	if friend.down and friend.rescue then
		row.revive:SetValue(friend.rescue)
		row.revive:Show()
		value, color = "Reviving "..Percent(friend.rescue), { 1, 1, 1 }
	else
		row.revive:Hide()
	end
	if friend.saving then
		value, color = "Reviving you", GOLD
	end
	row.value:SetText(value)
	row.value:SetTextColor(color[1], color[2], color[3])
	SetName(row, friend.name or "?", BAR_WIDTH - 14 - row.value:GetStringWidth())
	if friend.down then
		if friend.rescue then
			row.name:SetTextColor(1, 1, 1)
		else
			row.name:SetTextColor(DOWN_TEXT[1], DOWN_TEXT[2], DOWN_TEXT[3])
		end
		row.icon.texture:SetVertexColor(0.55, 0.4, 0.4)
	else
		row.name:SetTextColor(1, 1, 1)
		row.icon.texture:SetVertexColor(1, 1, 1)
	end
	if friend.leader then
		row.leader:Show()
	else
		row.leader:Hide()
	end
	row:Show()
end

local function Friend(index, revive)
	local unit = "party"..index
	if not UnitExists(unit) then
		return nil
	end
	local name = UnitName(unit)
	local className, class = UnitClass(unit)
	local friend = {
		name = name, class = class, className = className,
		health = Num(UnitHealth(unit)), most = Num(UnitHealthMax(unit)),
		leader = Safe(UnitIsPartyLeader, unit) and true or false,
	}
	local ok, connected = pcall(UnitIsConnected, unit)
	friend.offline = ok and not connected
	local rescuing = Named(revive.reviving)
	friend.down = (friend.most > 0 and friend.health <= 0) or (Safe(UnitIsDead, unit) and true)
		or (rescuing ~= nil and rescuing == name)
	if rescuing and rescuing == name then
		friend.rescue = math.max(0, math.min(1, Num(revive.rshare)))
	end
	local by = Named(revive.by)
	friend.saving = (by ~= nil and by == name and Num(revive.down) == 1)
	return friend
end

local SAMPLES = {
	{ name = "Friend", class = "WARRIOR", className = "Warrior", health = 820, most = 1000, leader = true,
		dmg = 182000, dps = 640, share = 0.36, top = "Whirlwind", topdps = 310 },
	{ name = "Another", class = "MAGE", className = "Mage", health = 0, most = 700, down = true, rescue = 0.45,
		dmg = 151000, dps = 530, share = 0.30, top = "Frostbolt", topdps = 280 },
	{ name = "Healer", class = "PRIEST", className = "Priest", health = 350, most = 760,
		dmg = 64000, dps = 225, share = 0.13, top = "Holy Fire", topdps = 120 },
}

local function DrawFrames(revive)
	local count = Members()
	local samples = (count == 0 and BordoUI.Party.testMode)
	local shown = 0
	if samples then
		for index = 1, table.getn(SAMPLES) do
			local row = Row(index)
			row.sample = SAMPLES[index]
			Paint(row, SAMPLES[index])
			shown = index
		end
	else
		for index = 1, count do
			local friend = Friend(index, revive)
			if friend then
				shown = shown + 1
				local row = Row(shown)
				row.sample = nil
				row.unit = "party"..index
				Paint(row, friend)
			end
		end
	end
	for index = shown + 1, table.getn(rows) do
		rows[index]:Hide()
	end
	if shown > 0 then
		holder:SetHeight(shown * (ROW_HEIGHT + ROW_GAP) - ROW_GAP)
		holder:Show()
	else
		holder:SetHeight(ROW_HEIGHT)
		holder:Hide()
	end
end

-- Suppress default Blizzard party frames
local stockAway = CreateFrame("Frame")
stockAway:Hide()
local stockHidden

local function StockFrames(away)
	if stockHidden == away then
		if away then
			for index = 1, MOST do
				local frame = getglobal("PartyMemberFrame"..index)
				if frame and frame:IsVisible() then
					frame:Hide()
				end
			end
		end
		return
	end
	stockHidden = away
	for index = 1, MOST do
		local frame = getglobal("PartyMemberFrame"..index)
		if frame and frame.SetParent then
			if away then
				frame:SetParent(stockAway)
			else
				frame:SetParent(UIParent)
				if UnitExists("party"..index) then
					frame:Show()
				end
			end
		end
	end
end

-- =========================================================================
-- Revive Bar Module
-- =========================================================================
local bar = CreateFrame("Frame", "SurvivorUIRevive", UIParent)
bar:SetWidth(REVIVE_WIDTH)
bar:SetHeight(REVIVE_HEIGHT)
bar:SetMovable(true)
bar:SetClampedToScreen(true)
bar:Hide()
bar.fill = FlatBar(bar, REVIVE_WIDTH, REVIVE_HEIGHT)
bar.fill:SetAllPoints(bar)
Border(bar.fill)
bar.texts = CreateFrame("Frame", nil, bar.fill)
bar.texts:SetAllPoints(bar.fill)
bar.texts:SetFrameLevel(bar.fill:GetFrameLevel() + 2)
bar.text = Text(bar.texts, 9, "CENTER", 0, 0)
bar.text:SetTextColor(1, 1, 1)
bar.title = bar:CreateFontString(nil, "OVERLAY")
bar.title:SetFont(FONT_PATH, 12 + FONT_BUMP, "OUTLINE")
bar.title:SetPoint("BOTTOM", bar, "TOP", 0, 4)

local function DrawBar(revive)
	local down = Num(revive.down) == 1
	local rescuing = Named(revive.reviving)
	local share, title, text, fill, titleColor
	if not (down or rescuing) and BordoUI.Party.testMode then
		down, revive = true, { by = "Friend", share = 0.6 }
	end
	if down then
		share = Num(revive.share)
		local by = Named(revive.by)
		title, titleColor, fill = "YOU ARE DOWN", DOWN_TEXT, REVIVE_FILL
		if by then
			text = by.." is bringing you back  "..Percent(share)
		elseif share > 0 then
			text = "Being brought back  "..Percent(share)
		else
			text = "A friend must stand next to you"
		end
	elseif rescuing then
		share = Num(revive.rshare)
		title, titleColor, fill = "BRINGING "..string.upper(rescuing).." BACK", RESCUE_FILL, RESCUE_FILL
		text = Percent(share)
	else
		bar:Hide()
		return
	end
	bar.title:SetText(title)
	bar.title:SetTextColor(titleColor[1], titleColor[2], titleColor[3])
	bar.fill:SetValue(math.max(0, math.min(1, share)))
	bar.fill:SetStatusBarColor(fill[1], fill[2], fill[3], 0.9)
	bar.text:SetText(text)
	bar:Show()
end

local function PlaceBar()
	bar:ClearAllPoints()
	local db = BordoUIDB or SurvivorUIDB
	if db and db.reviveX and db.reviveTop then
		bar:SetPoint("TOP", UIParent, "BOTTOMLEFT", db.reviveX, db.reviveTop)
	else
		bar:SetPoint("TOP", UIParent, "CENTER", 0, -62)
	end
end

-- =========================================================================
-- Global Export Helpers
-- =========================================================================
function SurvivorUI_IsDown()
	return Num(Revive().down) == 1
end

function SurvivorUI_InParty()
	return Members() > 0 or (AZS_PARTY ~= nil and table.getn(AZS_PARTY) > 0) or SurvivorUI_IsDown()
end

function BordoUI:TogglePartyFrames(val)
	if val == "test" or val == "preview" then
		BordoUI.Party.testMode = not BordoUI.Party.testMode
		local st = BordoUI.Party.testMode and "enabled (sample friends shown)" or "disabled"
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party test mode " .. st .. ".")
	elseif val == "reset" then
		BordoUIDB = BordoUIDB or {}
		BordoUIDB.partyLeft, BordoUIDB.partyBottom = nil, nil
		PlaceFrames()
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party frame position reset to default.")
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffBordo UI|r: Party commands: /bordo party test | /bordo party reset")
	end
end

-- =========================================================================
-- Main Update Loop
-- =========================================================================
local elapsed = 0
local partyWatcher = CreateFrame("Frame")
partyWatcher:SetScript("OnUpdate", function()
	elapsed = elapsed + arg1
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	if AZS_PARTY and table.getn(AZS_PARTY) > 0 then
		lastLines, lastLinesAt = AZS_PARTY, GetTime()
	end
	local revive = Revive()
	StockFrames(true)
	DrawFrames(revive)
	if SurvivorUIDB and SurvivorUIDB.reviveBar == true then
		DrawBar(revive)
	elseif bar:IsShown() then
		bar:Hide()
	end
end)

local partyLoader = CreateFrame("Frame")
partyLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
partyLoader:SetScript("OnEvent", function()
	PlaceFrames()
	PlaceBar()
end)

function BordoUI_ResetPartyPosition()
	if BordoUIDB then
		BordoUIDB.partyLeft = nil
		BordoUIDB.partyBottom = nil
		BordoUIDB.partyPos = nil
	end
	PlaceFrames()
end
