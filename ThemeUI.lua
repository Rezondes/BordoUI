-- =========================================================================
-- Bordo UI: ThemeUI.lua
-- Centered Combat HUD (SurvivorUI 1:1 Architecture), XP & Kills/Gold Tracker,
-- Player Buffs/Debuffs, Target Debuffs, Action Bar, Minimap & Chat Skinning.
-- Compatible with WoW 1.12.1 (Interface 11200 / Lua 5.0)
-- =========================================================================
AZSHelper = AZSHelper or {}
AZSHelper.UI = AZSHelper.UI or {}
local UI = AZSHelper.UI
local FLAT = "Interface\\ChatFrame\\ChatFrameBackground"
local FONT_PATH = "Fonts\\FRIZQT__.TTF"
local FONT_BUMP = 0
local BAR_BUTTONS = { 1, 2, 3, 4, 5, 6, 12 }     -- 12 is the = key (Racial ability)
local BUTTON_SIZE = 36
local BUTTON_GAP = 2
local ROW_BELOW_CENTER = 150
local SECTION_GAP = 6
local FRAME_WIDTH = 150
local POWER_HEIGHT = 3
local HEALTH_HEIGHT = BUTTON_SIZE - POWER_HEIGHT - 1 -- 32
local ENEMY = { 0.80, 0.22, 0.22 }
local AURA_SIZE = 22
local AURA_MAX = 12
local DEBUFFS = 8
local CLASS_OVERRIDES = {
	["SHAMAN"] = { r = 0.00, g = 0.44, b = 0.87 },
}
local POWER_COLORS = {
	[0] = { 0.25, 0.50, 1.00 },   -- Mana
	[1] = { 0.85, 0.20, 0.20 },   -- Rage
	[2] = { 1.00, 0.55, 0.15 },   -- Focus
	[3] = { 1.00, 0.90, 0.25 },   -- Energy
}
-- =========================================================================
-- UI Helper Functions
-- =========================================================================
local function AddBorder(frame)
	local border = frame:CreateTexture(nil, "BACKGROUND")
	border:SetTexture(FLAT)
	border:SetVertexColor(0, 0, 0, 1)
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
	return border
end
local function AddBacking(frame, layer)
	local backing = frame:CreateTexture(nil, layer or "BORDER")
	backing:SetTexture(FLAT)
	backing:SetVertexColor(0.09, 0.09, 0.11, 1)
	backing:SetAllPoints(frame)
	return backing
end
local function FlatBar(parent, width, height)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetWidth(width)
	bar:SetHeight(height)
	bar:SetStatusBarTexture(FLAT)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	AddBorder(bar)
	AddBacking(bar)
	return bar
end
local function Text(parent, size, point, x, y)
	local text = parent:CreateFontString(nil, "OVERLAY")
	text:SetFont(FONT_PATH, size + FONT_BUMP, "OUTLINE")
	text:SetPoint(point, parent, point, x, y)
	return text
end
local function SafeHide(name)
	local object = type(name) == "string" and getglobal(name) or name
	if object and object.Hide then
		object:Hide()
	end
end
-- Large Number Abbreviation (thousands k, millions M, billions B, trillions T)
local SIZES = { { 1000000000000, "T" }, { 1000000000, "B" }, { 1000000, "M" }, { 1000, "k" } }
local function Figures(scaled, decimals)
	local text = string.format("%."..decimals.."f", scaled)
	text = string.gsub(text, "(%.%d-)0+$", "%1")
	return (string.gsub(text, "%.$", ""))
end
function SurvivorUI_Abbrev(value)
	value = tonumber(value) or 0
	local sign = ""
	if value < 0 then
		sign, value = "-", -value
	end
	for index = 1, table.getn(SIZES) do
		local size = SIZES[index]
		if value >= size[1] then
			local scaled = value / size[1]
			local decimals = scaled < 10 and 2 or 1
			local step = decimals == 2 and 100 or 10
			scaled = math.floor(scaled * step + 0.5) / step
			if scaled >= 1000 and index > 1 then
				size = SIZES[index - 1]
				scaled = math.floor(value / size[1] * 100 + 0.5) / 100
				decimals = 2
			end
			return sign..Figures(scaled, decimals)..size[2]
		end
	end
	return sign..tostring(math.floor(value + 0.5))
end
function SurvivorUI_HealthText(hp, hpm, style)
	hp, hpm = tonumber(hp) or 0, tonumber(hpm) or 0
	if style == "absolute" then
		return SurvivorUI_Abbrev(hp)
	elseif style == "both" then
		return SurvivorUI_Abbrev(hp).." / "..SurvivorUI_Abbrev(hpm)
	elseif style == "absolutePercent" then
		return SurvivorUI_Abbrev(hp).." | "..(hpm > 0 and math.floor(hp / hpm * 100 + 0.5) or 0).."%"
	end
	return (hpm > 0 and math.floor(hp / hpm * 100 + 0.5) or 0).."%"
end
function SurvivorUI_ClassColor(class)
	local color = class and (CLASS_OVERRIDES[class] or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]))
	if color then
		return color.r, color.g, color.b
	end
	return 1, 0.82, 0
end
local function HealthColor(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local color = class and (CLASS_OVERRIDES[class] or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]))
		if color then
			return color.r, color.g, color.b
		end
		return 0.6, 0.6, 0.6
	end
	return ENEMY[1], ENEMY[2], ENEMY[3]
end
local function TimeText(seconds)
	if seconds >= 3600 then
		return math.floor(seconds / 3600 + 0.5).."h"
	elseif seconds >= 60 then
		return math.floor(seconds / 60 + 0.5).."m"
	elseif seconds >= 10 then
		return math.floor(seconds)
	end
	return string.format("%.1f", seconds)
end
-- =========================================================================
-- 1. ACTION BAR ROW (SurvivorUIRow)
-- =========================================================================
local row = CreateFrame("Frame", "SurvivorUIRow", UIParent)
row:SetWidth(table.getn(BAR_BUTTONS) * (BUTTON_SIZE + BUTTON_GAP) - BUTTON_GAP)
row:SetHeight(BUTTON_SIZE)
row:SetPoint("CENTER", UIParent, "CENTER", 0, -ROW_BELOW_CENTER)
row:SetMovable(true)
row:EnableMouse(true)
row:RegisterForDrag("LeftButton")
row:SetClampedToScreen(true)
row:SetFrameStrata("LOW")
UI.skillsContainer = row
local PositionMicroButtons
AZSHelper_SkillsContainer = row
local function SaveHudPosition()
	BordoUIDB = BordoUIDB or {}
	local x = math.floor(row:GetLeft() - UIParent:GetWidth() / 2 + row:GetWidth() / 2 + 0.5)
	local y = math.floor(row:GetBottom() - UIParent:GetHeight() / 2 + row:GetHeight() / 2 + 0.5)
	BordoUIDB.hudPos = { point = "CENTER", x = x, y = y }
	AZSHelperDB = AZSHelperDB or {}
	AZSHelperDB.rowPos = BordoUIDB.hudPos
end
row:SetScript("OnDragStart", function()
	if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
		row:StartMoving()
	end
end)
row:SetScript("OnDragStop", function()
	row:StopMovingOrSizing()
	SaveHudPosition()
end)
row.slots = {}
for position = 1, table.getn(BAR_BUTTONS) do
	local slot = CreateFrame("Frame", nil, row)
	row.slots[position] = slot
	slot:SetWidth(BUTTON_SIZE)
	slot:SetHeight(BUTTON_SIZE)
	slot:SetPoint("LEFT", row, "LEFT", (position - 1) * (BUTTON_SIZE + BUTTON_GAP), 0)
	slot:SetFrameStrata("LOW")
	slot:SetFrameLevel(1)
	slot:EnableMouse(false)
	AddBorder(slot)
	AddBacking(slot)
end
-- Style an Action Button into the flat dark slot look
local function StyleButton(button)
	local name = button:GetName()
	if not name then return end
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(row:GetFrameLevel() + 10)
	local normal = getglobal(name.."NormalTexture")
	if normal then
		normal:SetAlpha(0)
		normal:Hide()
	end
	local icon = getglobal(name.."Icon")
	if icon then
		icon:SetDrawLayer("ARTWORK")
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetAlpha(1)
	end
	local border = getglobal(name.."Border")
	if border then
		border:Hide()
		border.Show = function() end
	end
	local hotkey = getglobal(name.."HotKey")
	if hotkey then
		hotkey:SetAlpha(0)
		hotkey:Hide()
	end
end
-- Synchronize skill icons and ensure buttons are always bright and in front
local function UpdateSkills()
	for position = 1, table.getn(BAR_BUTTONS) do
		local id = BAR_BUTTONS[position]
		local button = getglobal("ActionButton"..id)
		if button then
			button:SetParent(row)
			button:ClearAllPoints()
			button:SetPoint("LEFT", row, "LEFT", (position - 1) * (BUTTON_SIZE + BUTTON_GAP), 0)
			button:SetWidth(BUTTON_SIZE)
			button:SetHeight(BUTTON_SIZE)
			button:SetFrameStrata("MEDIUM")
			button:SetFrameLevel(row:GetFrameLevel() + 10)
			button.survivorKept = true
			button:Show()
			StyleButton(button)
			local icon = getglobal("ActionButton"..id.."Icon")
			if icon then
				local pagedID = ActionButton_GetPagedID and ActionButton_GetPagedID(button) or id
				local texture = GetActionTexture(pagedID)
				if (not texture or texture == "") and AZS_SPELLS then
					local total = table.getn(AZS_SPELLS)
					local entry = (id == 12 and total > 0 and AZS_SPELLS[total]) or AZS_SPELLS[id]
					if entry and (entry.icon or entry[2]) then
						texture = entry.icon or entry[2]
					end
				end
				if texture and texture ~= "" then
					icon:SetTexture(texture)
					icon:SetDrawLayer("ARTWORK")
					icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
					icon:SetAlpha(1)
					icon:Show()
				end
			end
		end
	end
end
-- Keep flat style whenever stock action button updates
local stockActionButtonUpdate = ActionButton_Update
if stockActionButtonUpdate then
	ActionButton_Update = function()
		stockActionButtonUpdate()
		if this and this.survivorKept then
			StyleButton(this)
			local name = this:GetName()
			local icon = name and getglobal(name.."Icon")
			if icon then
				local pagedID = ActionButton_GetPagedID and ActionButton_GetPagedID(this) or this:GetID()
				local texture = GetActionTexture(pagedID)
				if (not texture or texture == "") and AZS_SPELLS then
					local id = this:GetID()
					local total = table.getn(AZS_SPELLS)
					local entry = (id == 12 and total > 0 and AZS_SPELLS[total]) or AZS_SPELLS[id]
					if entry and (entry.icon or entry[2]) then
						texture = entry.icon or entry[2]
					end
				end
				if texture and texture ~= "" then
					icon:SetTexture(texture)
					icon:SetDrawLayer("ARTWORK")
					icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
					icon:SetAlpha(1)
					icon:Show()
				end
			end
		end
	end
end
local function PlaceButton(prefix, id, position)
	local button = getglobal(prefix..id)
	if not button then return end
	button:ClearAllPoints()
	if prefix == "ActionButton" and position then
		button:SetParent(row)
		button:SetPoint("LEFT", row, "LEFT", (position - 1) * (BUTTON_SIZE + BUTTON_GAP), 0)
		button:SetWidth(BUTTON_SIZE)
		button:SetHeight(BUTTON_SIZE)
		button:SetFrameStrata("MEDIUM")
		button:SetFrameLevel(row:GetFrameLevel() + 10)
		button.survivorKept = true
		button:Show()
		StyleButton(button)
	else
		button:SetPoint("TOP", UIParent, "BOTTOM", 0, -600)
		button:Hide()
		button.Show = function() end
	end
end
local function LayoutBar()
	for _, name in pairs({ "ToggleBackpack", "OpenBackpack", "ToggleBag", "OpenBag", "OpenAllBags", "ToggleKeyRing" }) do
		if getglobal(name) then
			setglobal(name, function() end)
		end
	end
	CURRENT_ACTIONBAR_PAGE = 1
	local positions = {}
	for position = 1, table.getn(BAR_BUTTONS) do
		positions[BAR_BUTTONS[position]] = position
	end
	for id = 1, 12 do
		PlaceButton("ActionButton", id, positions[id])
		PlaceButton("BonusActionButton", id, nil)
	end
	if BonusActionBarFrame then
		BonusActionBarFrame:Hide()
		BonusActionBarFrame.Show = function() end
	end
	if ShowBonusActionBar then
		ShowBonusActionBar = function()
			if BonusActionBarFrame then BonusActionBarFrame:Hide() end
		end
	end
	for _, name in pairs({
		"MainMenuBarTexture0", "MainMenuBarTexture1", "MainMenuBarTexture2", "MainMenuBarTexture3",
		"MainMenuBarLeftEndCap", "MainMenuBarRightEndCap",
		"ActionBarUpButton", "ActionBarDownButton", "MainMenuBarPageNumber",
		"MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot",
		"KeyRingButton", "MainMenuBarPerformanceBarFrame",
		"BonusActionBarTexture0", "BonusActionBarTexture1",
		"MainMenuXPBarTexture0", "MainMenuXPBarTexture1", "MainMenuXPBarTexture2", "MainMenuXPBarTexture3",
		"ExhaustionTick", "AZS_MainMenuBarTexture4", "AZS_RacialRim",
	}) do
		SafeHide(name)
	end
	for _, name in pairs({ "MainMenuBar", "MainMenuBarArtFrame" }) do
		local frame = getglobal(name)
		if frame and frame.EnableMouse then
			frame:EnableMouse(false)
		end
	end
	local xpText = getglobal("MainMenuBarExpText")
	if xpText then
		xpText:Hide()
		xpText.Show = function() end
	end
	local expBar = getglobal("MainMenuExpBar")
	if expBar then
		expBar:UnregisterAllEvents()
		expBar:ClearAllPoints()
		expBar:SetPoint("TOP", UIParent, "BOTTOM", 0, -600)
		expBar:SetAlpha(0)
		expBar:Hide()
		expBar.Show = function() end
	end
	if MainMenuExpBar_Update then
		MainMenuExpBar_Update = function() end
	end
	if SurvivorUIXpBar then
		SurvivorUIXpBar:Hide()
		SurvivorUIXpBar.Show = function() end
	end
	for _, name in pairs({ "MainMenuBarMaxLevelBar", "ReputationWatchBar" }) do
		local frame = getglobal(name)
		if frame then
			frame:Hide()
			frame.Show = function() end
		end
	end
	if PositionMicroButtons then PositionMicroButtons() end
	UpdateSkills()
end
-- =========================================================================
-- Cooldown Countdown Overlays
-- =========================================================================
local function CounterUpdate()
	local left = this.start + this.duration - GetTime()
	if left <= 0 then
		this:Hide()
		return
	end
	this.text:SetText(TimeText(left))
	local soon = left <= 2 and this.duration > 1.5
	if soon ~= this.soon then
		this.soon = soon
		if soon then
			this.text:SetTextColor(1, 0.25, 0.25)
		else
			this.text:SetTextColor(1, 0.95, 0.6)
		end
	end
end
if CooldownFrame_SetTimer and not OmniCC_OnUpdate then
	local stockSetTimer = CooldownFrame_SetTimer
	CooldownFrame_SetTimer = function(cooldown, start, duration, enable)
		stockSetTimer(cooldown, start, duration, enable)
		local parent = cooldown and cooldown:GetParent()
		if not parent then return end
		local counter = parent.survivorCounter
		if not counter then
			counter = CreateFrame("Frame", nil, parent)
			counter:SetAllPoints(parent)
			counter:SetFrameLevel(cooldown:GetFrameLevel() + 3)
			counter.dim = counter:CreateTexture(nil, "BACKGROUND")
			counter.dim:SetTexture(FLAT)
			counter.dim:SetVertexColor(0, 0, 0, 0.45)
			counter.dim:SetAllPoints(counter)
			counter.text = Text(counter, 14, "CENTER", 0, 0)
			counter.text:SetTextColor(1, 0.95, 0.6)
			counter:SetScript("OnUpdate", CounterUpdate)
			parent.survivorCounter = counter
		end
		if start and start > 0 and duration and duration > 0 and enable and enable > 0 then
			counter.start, counter.duration = start, duration
			counter:Show()
		else
			counter:Hide()
		end
	end
end
-- =========================================================================
-- 2. UNIT FRAMES (Player & Target)
-- =========================================================================
local SHIELD_LOOKS = {
	light = { fill = { 0.59, 0.82, 1, 0.45 }, stripes = { 1, 1, 1, 1 }, edge = { 0.9, 0.97, 1, 1 } },
	dark  = { fill = { 0.22, 0.5, 1, 0.6 },  stripes = { 0.08, 0.2, 0.55, 0.95 }, edge = { 0.06, 0.22, 0.65, 1 } },
}
local function ShieldLook(shield, look)
	if shield.look == look then return end
	shield.look = look
	local colors = SHIELD_LOOKS[look]
	shield.fill:SetVertexColor(colors.fill[1], colors.fill[2], colors.fill[3], colors.fill[4])
	shield.stripes:SetVertexColor(colors.stripes[1], colors.stripes[2], colors.stripes[3], colors.stripes[4])
	shield.edge:SetVertexColor(colors.edge[1], colors.edge[2], colors.edge[3], colors.edge[4])
end
local function UpdateShield(frame, health, r, g, b)
	local shield = frame.shield
	local run = AZS_RUN or {}
	local most = tonumber(run.hpm) or 0
	local held = most > 0 and (tonumber(run.sh) or 0) / most or 0
	if held <= 0.002 then
		shield:Hide()
		return
	end
	held = math.min(1, held)
	local from, to, edge = health, health + held, health + held
	local over = false
	if to > 1 then
		from, to, edge, over = 1 - held, 1, 1 - held, true
	end
	ShieldLook(shield, over and (0.3 * r + 0.59 * g + 0.11 * b) > 0.75 and "dark" or "light")
	local bar = frame.health
	shield.fill:ClearAllPoints()
	shield.fill:SetPoint("TOPLEFT", bar, "TOPLEFT", FRAME_WIDTH * from, 0)
	shield.fill:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", FRAME_WIDTH * to, 0)
	shield.stripes:ClearAllPoints()
	shield.stripes:SetPoint("TOPLEFT", bar, "TOPLEFT", FRAME_WIDTH * from, 0)
	shield.stripes:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", FRAME_WIDTH * to, 0)
	shield.stripes:SetTexCoord(from, to, 0, 1)
	shield.edge:ClearAllPoints()
	shield.edge:SetPoint("TOPLEFT", bar, "TOPLEFT", FRAME_WIDTH * edge - 1, 0)
	shield.edge:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", FRAME_WIDTH * edge + 1, 0)
	shield:Show()
end
local function UnitFrame(unit, name, side, dropdown)
	local left = (side == "LEFT")
	local frame = CreateFrame("Button", name, UIParent)
	frame:SetWidth(FRAME_WIDTH + 1 + BUTTON_SIZE)
	frame:SetHeight(BUTTON_SIZE)
	if left then
		frame:SetPoint("RIGHT", row, "LEFT", -SECTION_GAP, 0)
	else
		frame:SetPoint("LEFT", row, "RIGHT", SECTION_GAP, 0)
	end
	frame.unit = unit
	frame.portrait = CreateFrame("Frame", nil, frame)
	frame.portrait:SetWidth(BUTTON_SIZE)
	frame.portrait:SetHeight(BUTTON_SIZE)
	frame.portrait:SetPoint(left and "LEFT" or "RIGHT", frame, left and "LEFT" or "RIGHT", 0, 0)
	AddBorder(frame.portrait)
	AddBacking(frame.portrait)
	frame.portrait.texture = frame.portrait:CreateTexture(nil, "ARTWORK")
	frame.portrait.texture:SetAllPoints(frame.portrait)
	frame.portrait.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	frame.health = FlatBar(frame, FRAME_WIDTH, HEALTH_HEIGHT)
	frame.health:SetPoint(left and "TOPRIGHT" or "TOPLEFT", frame, left and "TOPRIGHT" or "TOPLEFT", 0, 0)
	frame.power = FlatBar(frame, FRAME_WIDTH, POWER_HEIGHT)
	frame.power:SetPoint("TOP", frame.health, "BOTTOM", 0, -1)
	if unit == "player" then
		local shield = CreateFrame("Frame", nil, frame.health)
		shield:SetAllPoints(frame.health)
		shield:SetFrameLevel(frame.health:GetFrameLevel() + 1)
		shield.fill = shield:CreateTexture(nil, "BACKGROUND")
		shield.fill:SetTexture(FLAT)
		shield.fill:SetVertexColor(0.59, 0.82, 1, 0.45)
		shield.stripes = shield:CreateTexture(nil, "BORDER")
		shield.stripes:SetTexture("Interface\\AddOns\\BordoUI\\Art\\ShieldStripes")
		shield.edge = shield:CreateTexture(nil, "ARTWORK")
		shield.edge:SetTexture(FLAT)
		shield.edge:SetVertexColor(0.9, 0.97, 1, 1)
		shield:Hide()
		frame.shield = shield
	end
	frame.texts = CreateFrame("Frame", nil, frame.health)
	frame.texts:SetAllPoints(frame.health)
	frame.texts:SetFrameLevel(frame.health:GetFrameLevel() + 2)
	frame.name = Text(frame.texts, 10, "LEFT", 5, 0)
	frame.nameRoom = (unit == "player") and (FRAME_WIDTH - 82) or (FRAME_WIDTH - 44)
	frame.name:SetWidth(frame.nameRoom)
	frame.name:SetHeight(12)
	frame.name:SetJustifyH("LEFT")
	frame.name:SetTextColor(1, 1, 1)
	frame.value = Text(frame.texts, 10, "RIGHT", -5, 0)
	frame.value:SetTextColor(1, 1, 1)
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:SetScript("OnClick", function()
		if arg1 == "RightButton" and dropdown and getglobal(dropdown) then
			ToggleDropDownMenu(1, nil, getglobal(dropdown), "cursor")
		else
			TargetUnit(this.unit)
		end
	end)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function()
		if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
			row:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function()
		row:StopMovingOrSizing()
		SaveHudPosition()
	end)
	return frame
end
local player = UnitFrame("player", "SurvivorUIPlayer", "LEFT", "PlayerFrameDropDown")
local target = UnitFrame("target", "SurvivorUITarget", "RIGHT", "TargetFrameDropDown")
UI.centerPlayer = player
UI.centerBoss = target
target:Hide()
local function UpdatePortrait(frame)
	if UnitExists(frame.unit) then
		SetPortraitTexture(frame.portrait.texture, frame.unit)
	end
end
local function UpdateUnitFrame(frame)
	local unit = frame.unit
	if not UnitExists(unit) then
		frame:Hide()
		return
	end
	frame:Show()
	local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
	local share = healthMax > 0 and health / healthMax or 0
	local r, g, b = HealthColor(unit)
	frame.health:SetValue(share)
	frame.health:SetStatusBarColor(r, g, b, 1)
	if frame.shield then
		UpdateShield(frame, share, r, g, b)
	end
	local hp, hpm, style = health, healthMax, "absolutePercent"
	if unit == "target" then
		if AZS_TARGET and AZS_TARGET.name == UnitName(unit) and (tonumber(AZS_TARGET.hpm) or 0) > 0 then
			hp, hpm = AZS_TARGET.hp, AZS_TARGET.hpm
		elseif healthMax == 100 then
			style = "percent"
		end
	end
	local room = (style == "both" or style == "absolutePercent") and (FRAME_WIDTH - 82) or (FRAME_WIDTH - 44)
	if room ~= frame.nameRoom then
		frame.nameRoom = room
		frame.shownName = nil
	end
	local name = UnitName(unit) or ""
	if name ~= frame.shownName then
		frame.shownName = name
		frame.name:SetWidth(0)
		frame.name:SetText(name)
		if frame.name:GetStringWidth() > frame.nameRoom then
			local _, _, first = string.find(name, "^(%S+)")
			frame.name:SetText(first or name)
		end
		frame.name:SetWidth(frame.nameRoom)
	end
	if UnitIsDead(unit) or UnitIsGhost(unit) then
		frame.value:SetText((unit == "player" and SurvivorUI_IsDown and SurvivorUI_IsDown()) and "Down" or "Dead")
	else
		frame.value:SetText(SurvivorUI_HealthText(hp, hpm, style))
	end
	local powerType = UnitPowerType(unit)
	local power, powerMax = UnitMana(unit), UnitManaMax(unit)
	if powerMax and powerMax > 0 and powerType then
		local colors = POWER_COLORS[powerType] or { 0.25, 0.50, 1.00 }
		frame.power:SetValue(power / powerMax)
		frame.power:SetStatusBarColor(colors[1], colors[2], colors[3], 1)
	else
		frame.power:SetValue(0)
	end
end
-- =========================================================================
-- 3. PLAYER BUFFS & DEBUFFS ROW (SurvivorUIBuffs)
-- =========================================================================
local buffHolder = CreateFrame("Frame", "SurvivorUIBuffs", UIParent)
buffHolder:SetWidth(AURA_MAX * (AURA_SIZE + 3) - 3)
buffHolder:SetHeight(AURA_SIZE)
buffHolder:SetPoint("BOTTOMLEFT", player, "TOPLEFT", 0, 5)
buffHolder:SetMovable(true)
local auras = {}
for index = 1, AURA_MAX do
	local aura = CreateFrame("Button", nil, buffHolder)
	aura:SetWidth(AURA_SIZE)
	aura:SetHeight(AURA_SIZE)
	aura:SetPoint("BOTTOMLEFT", buffHolder, "BOTTOMLEFT", (index - 1) * (AURA_SIZE + 3), 0)
	aura.border = AddBorder(aura)
	aura.texture = aura:CreateTexture(nil, "ARTWORK")
	aura.texture:SetAllPoints(aura)
	aura.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	aura.time = Text(aura, 10, "CENTER", 0, 0)
	aura.time:SetTextColor(1, 0.95, 0.6)
	aura.count = Text(aura, 9, "BOTTOMRIGHT", -1, 1)
	aura:RegisterForClicks("RightButtonUp")
	aura:SetScript("OnClick", function()
		if this.helpful then
			CancelPlayerBuff(this.buffIndex)
		end
	end)
	aura:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
		GameTooltip:SetPlayerBuff(this.buffIndex)
	end)
	aura:SetScript("OnLeave", function() GameTooltip:Hide() end)
	aura:Hide()
	auras[index] = aura
end
local function UpdateAuras()
	local shown = 0
	for pass = 1, 2 do
		local filter = (pass == 1) and "HELPFUL" or "HARMFUL"
		for slot = 0, 15 do
			local buffIndex = GetPlayerBuff(slot, filter)
			if buffIndex and buffIndex >= 0 and shown < AURA_MAX then
				shown = shown + 1
				local aura = auras[shown]
				aura.buffIndex = buffIndex
				aura.helpful = (pass == 1)
				aura.texture:SetTexture(GetPlayerBuffTexture(buffIndex))
				if pass == 1 then
					aura.border:SetVertexColor(0, 0, 0, 1)
				else
					aura.border:SetVertexColor(0.85, 0.10, 0.10, 1)
				end
				local left = GetPlayerBuffTimeLeft(buffIndex)
				aura.time:SetText(left and left > 0 and TimeText(left) or "")
				local count = GetPlayerBuffApplications(buffIndex)
				aura.count:SetText(count and count > 1 and count or "")
				aura:Show()
			end
		end
	end
	for index = shown + 1, AURA_MAX do
		auras[index]:Hide()
	end
end
-- =========================================================================
-- 4. TARGET DEBUFFS ROW
-- =========================================================================
local debuffs = {}
for index = 1, DEBUFFS do
	local icon = CreateFrame("Frame", nil, target)
	icon:SetWidth(18)
	icon:SetHeight(18)
	icon:SetPoint("BOTTOMLEFT", target, "TOPLEFT", (index - 1) * 21, 4)
	AddBorder(icon)
	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetAllPoints(icon)
	icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.count = Text(icon, 9, "BOTTOMRIGHT", -1, 1)
	icon:Hide()
	debuffs[index] = icon
end
local function UpdateDebuffs()
	for index = 1, DEBUFFS do
		local texture, count = UnitDebuff("target", index)
		local icon = debuffs[index]
		if texture then
			icon.texture:SetTexture(texture)
			icon.count:SetText(count and count > 1 and count or "")
			icon:Show()
		else
			icon:Hide()
		end
	end
end
-- =========================================================================
-- 5. STANDALONE BOTTOM XP BAR, CENTERED TALLY FRAME & MICRO BUTTONS DOCK
-- =========================================================================
-- A) STANDALONE FULL-WIDTH XP BAR (Pinned at the very bottom edge)
-- A) HUD XP BAR (Positioned directly under skills, spanning from player HP bar to target HP bar)
local xpWidth = row:GetWidth() + 2 * (SECTION_GAP + FRAME_WIDTH)
UI.xpBar = CreateFrame("StatusBar", "AZSHelper_XPBar", UIParent)
UI.xpBar:ClearAllPoints()
UI.xpBar:SetPoint("TOP", row, "BOTTOM", 0, -4)
UI.xpBar:SetWidth(xpWidth)
UI.xpBar:SetHeight(5)
UI.xpBar:SetStatusBarTexture(FLAT)
UI.xpBar:SetStatusBarColor(0.55, 0.20, 0.85, 1.0)
UI.xpBar:SetMinMaxValues(0, 100)
UI.xpBar:SetFrameStrata("LOW")
UI.xpBar:SetFrameLevel(6)
AddBorder(UI.xpBar)
AddBacking(UI.xpBar)
UI.xpText = UI.xpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
UI.xpText:SetPoint("CENTER", UI.xpBar, "CENTER", 0, 0)
UI.xpText:SetFont("Fonts\\ARIALN.TTF", 8, "OUTLINE")
UI.xpText:SetTextColor(1, 1, 1, 0.85)
UI.xpBar:EnableMouse(true)
UI.xpBar:SetScript("OnEnter", function()
	UI.xpText:SetTextColor(1, 1, 1, 1)
end)
UI.xpBar:SetScript("OnLeave", function()
	UI.xpText:SetTextColor(1, 1, 1, 0.85)
end)
-- B) CENTERED KILLS & GOLD TALLY FRAME (Positioned right under the action bar)
UI.tallyFrame = CreateFrame("Frame", "AZSHelper_TallyFrame", UIParent)
UI.tallyFrame:SetHeight(22)
UI.tallyFrame:SetWidth(180)
UI.tallyFrame:ClearAllPoints()
UI.tallyFrame:SetPoint("TOP", UI.xpBar, "BOTTOM", 0, -4)
UI.tallyFrame:SetFrameStrata("MEDIUM")
UI.tallyFrame:SetFrameLevel(6)
UI.tallyFrame:SetClampedToScreen(true)
UI.tallyFrame:SetMovable(true)
UI.tallyFrame:EnableMouse(true)
UI.tallyFrame:RegisterForDrag("LeftButton")
local tallyBg = UI.tallyFrame:CreateTexture(nil, "BACKGROUND")
tallyBg:SetTexture(FLAT)
tallyBg:SetVertexColor(0.04, 0.04, 0.06, 0.82)
tallyBg:SetAllPoints(UI.tallyFrame)
AddBorder(UI.tallyFrame)
UI.tallyFrame:SetScript("OnDragStart", function()
	if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
		UI.tallyFrame:StartMoving()
	end
end)
UI.tallyFrame:SetScript("OnDragStop", function()
	UI.tallyFrame:StopMovingOrSizing()
	BordoUIDB = BordoUIDB or {}
	local pt, _, relPt, x, y = UI.tallyFrame:GetPoint()
	BordoUIDB.tallyPos = { point = pt, relativePoint = relPt, x = x, y = y }
end)
if ( BordoUI and BordoUI.AttachLockButton ) then
	BordoUI:AttachLockButton(UI.tallyFrame, "LEFT", UI.tallyFrame, "RIGHT", 4, 0)
end
-- Backward compatibility reference for scripts expecting UI.bottomBar
UI.bottomBar = UI.tallyFrame
-- Red Skull Icon for Kills
UI.killsSkull = UI.tallyFrame:CreateTexture(nil, "ARTWORK")
UI.killsSkull:SetTexture("Interface\\AddOns\\BordoUI\\Art\\Kills")
UI.killsSkull:SetWidth(15)
UI.killsSkull:SetHeight(15)
UI.killsSkull:SetPoint("LEFT", UI.tallyFrame, "LEFT", 8, 0)
UI.killsText = UI.tallyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
UI.killsText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
UI.killsText:SetPoint("LEFT", UI.killsSkull, "RIGHT", 4, 0)
UI.killsText:SetTextColor(1, 1, 1)
UI.killsText:SetText("0")
-- Gold Slot
UI.goldSlot = CreateFrame("Frame", nil, UI.tallyFrame)
UI.goldSlot:SetWidth(15)
UI.goldSlot:SetHeight(15)
UI.goldSlot:SetPoint("LEFT", UI.killsText, "RIGHT", 18, 0)
UI.goldGlow = UI.goldSlot:CreateTexture(nil, "BACKGROUND")
UI.goldGlow:SetTexture("Interface\\AddOns\\BordoUI\\Art\\PaceGlow")
UI.goldGlow:SetBlendMode("ADD")
UI.goldGlow:SetVertexColor(1.0, 0.82, 0.20)
UI.goldGlow:SetPoint("CENTER", UI.goldSlot, "CENTER", 0, 0)
UI.goldGlow:Hide()
UI.goldCoin = UI.goldSlot:CreateTexture(nil, "ARTWORK")
UI.goldCoin:SetTexture("Interface\\AddOns\\BordoUI\\Art\\Coin")
UI.goldCoin:SetPoint("CENTER", UI.goldSlot, "CENTER", 0, 0)
UI.goldCoin:SetWidth(15)
UI.goldCoin:SetHeight(15)
UI.goldSpark = UI.goldSlot:CreateTexture(nil, "OVERLAY")
UI.goldSpark:SetTexture("Interface\\AddOns\\BordoUI\\Art\\PaceSpark")
UI.goldSpark:SetBlendMode("ADD")
UI.goldSpark:SetVertexColor(1.0, 0.95, 0.70)
UI.goldSpark:SetPoint("CENTER", UI.goldSlot, "TOPRIGHT", -2, -2)
UI.goldSpark:Hide()
UI.goldText = UI.tallyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
UI.goldText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
UI.goldText:SetPoint("LEFT", UI.goldSlot, "RIGHT", 4, 0)
UI.goldText:SetText("|cffffd24d0|r / |cffb39a5c20|r")
UI.goldSlot:SetScript("OnUpdate", function()
	if not this.pays then
		if UI.goldGlow:IsShown() then UI.goldGlow:Hide() end
		if UI.goldSpark:IsShown() then UI.goldSpark:Hide() end
		UI.goldCoin:SetWidth(15)
		UI.goldCoin:SetHeight(15)
		UI.goldCoin:SetVertexColor(1, 1, 1)
		return
	end
	local now = GetTime()
	local wave = (math.sin(now * 4.5) + 1) / 2
	local size = 15 * (1.8 + 0.5 * wave)
	UI.goldGlow:SetWidth(size)
	UI.goldGlow:SetHeight(size)
	UI.goldGlow:SetAlpha(0.45 + 0.45 * wave)
	UI.goldGlow:Show()
	local cGrow = 15 * (1 + 0.08 * wave)
	UI.goldCoin:SetWidth(cGrow)
	UI.goldCoin:SetHeight(cGrow)
	local bright = 0.85 + 0.15 * wave
	UI.goldCoin:SetVertexColor(bright, bright, bright)
	local turn = math.mod(now, 2.2) / 2.2
	if turn < 0.25 then
		local tw = math.sin(turn / 0.25 * 3.1416)
		UI.goldSpark:SetWidth(15 * (0.6 + 0.6 * tw))
		UI.goldSpark:SetHeight(15 * (0.6 + 0.6 * tw))
		UI.goldSpark:SetAlpha(tw)
		UI.goldSpark:Show()
	else
		UI.goldSpark:Hide()
	end
end)
-- C) MODERN MINIMAP ACTION DOCK (Character, Talents, Damage Meter)
PositionMicroButtons = function()
	for _, name in pairs({
		"CharacterMicroButton", "TalentMicroButton", "SpellbookMicroButton",
		"QuestLogMicroButton", "SocialsMicroButton", "WorldMapMicroButton",
		"MainMenuMicroButton", "HelpMicroButton", "MiniMapBattlefieldFrame"
	}) do
		local btn = getglobal(name)
		if btn then
			btn:ClearAllPoints()
			btn:SetPoint("TOP", UIParent, "BOTTOM", 0, -600)
			btn:Hide()
			btn.Show = function() end
		end
	end
end
PositionMicroButtons()
local minimapDock = CreateFrame("Frame", "BordoUI_MinimapDock", UIParent)
minimapDock:SetWidth(28)
minimapDock:SetHeight(88)
minimapDock:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -6, 0)
minimapDock:SetFrameStrata("LOW")
minimapDock:SetFrameLevel(10)
minimapDock:SetMovable(true)
minimapDock:SetClampedToScreen(true)
minimapDock:EnableMouse(true)
minimapDock:RegisterForDrag("LeftButton")
minimapDock:SetScript("OnDragStart", function()
	if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
		minimapDock:StartMoving()
	end
end)
minimapDock:SetScript("OnDragStop", function()
	minimapDock:StopMovingOrSizing()
	local pt, _, relPt, x, y = minimapDock:GetPoint()
	BordoUIDB = BordoUIDB or {}
	BordoUIDB.minimapDockPos = { point = pt, relativePoint = relPt, x = x, y = y }
end)
UI.minimapDock = minimapDock
local function CreateSquareDockButton(parent, index, iconPath, tooltipTitle, tooltipDesc, onClick)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetWidth(26)
	btn:SetHeight(26)
	btn:SetPoint("TOP", parent, "TOP", 0, -((index - 1) * 29))
	
	btn:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile     = true,
		tileSize = 12,
		edgeSize = 8,
		insets   = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	btn:SetBackdropColor(0.04, 0.04, 0.06, 0.88)
	btn:SetBackdropBorderColor(0.15, 0.15, 0.20, 0.95)
	
	local icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
	icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
	icon:SetTexture(iconPath)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	btn.icon = icon
	
	local hl = btn:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints(icon)
	hl:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	hl:SetBlendMode("ADD")
	hl:SetAlpha(0.35)
	
	btn:SetScript("OnMouseDown", function()
		icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
	end)
	btn:SetScript("OnMouseUp", function()
		icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
	end)
	
	btn:SetScript("OnClick", function()
		PlaySound("igMainMenuOptionCheckBoxOn")
		if onClick then onClick() end
	end)
	
	btn:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:AddLine(tooltipTitle, 1, 0.82, 0)
		GameTooltip:AddLine(tooltipDesc, 0.85, 0.85, 0.85)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	return btn
end
-- 1. Character & Stats Button
CreateSquareDockButton(
	minimapDock, 1, "Interface\\Icons\\INV_Helmet_06",
	"Character & Stats", "Left-Click: Toggle Stats Window\nShift-Click: Open Blizzard Character Info",
	function()
		if IsShiftKeyDown() and ToggleCharacter then
			ToggleCharacter("PaperDollFrame")
		elseif BordoUI_ToggleStatsWindow then
			BordoUI_ToggleStatsWindow()
		elseif ToggleCharacter then
			ToggleCharacter("PaperDollFrame")
		end
	end
)
-- 2. Talents & Build Button
CreateSquareDockButton(
	minimapDock, 2, "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
	"Talents & Build", "Left-Click: Toggle Build & Jewelry List\nShift-Click: Open Blizzard Talent Tree",
	function()
		if IsShiftKeyDown() and ToggleTalentFrame then
			ToggleTalentFrame()
		elseif SurvivorUI_ToggleBuild then
			SurvivorUI_ToggleBuild()
		elseif ToggleTalentFrame then
			ToggleTalentFrame()
		end
	end
)
-- 3. Damage & DPS Meter Button
CreateSquareDockButton(
	minimapDock, 3, "Interface\\Icons\\INV_Sword_27",
	"Damage & DPS Meter", "Left-Click: Toggle Damage Statistics",
	function()
		if AZSHelper_StatsTableFrame then
			if AZSHelper_StatsTableFrame:IsShown() then
				AZSHelper_StatsTableFrame:Hide()
			else
				if AZSHelper.AnchorStatsTableToMultipliers then
					AZSHelper:AnchorStatsTableToMultipliers()
				end
				AZSHelper_StatsTableFrame:Show()
			end
		end
	end
)
if ( BordoUI and BordoUI.AttachLockButton ) then
	BordoUI:AttachLockButton(minimapDock, "BOTTOM", minimapDock, "TOP", 0, 4)
end
local function UpdateBottomBar()
	local xp = (AZS_RUN and AZS_RUN.xp) or 0
	local xpn = (AZS_RUN and AZS_RUN.xpn) or 1
	if xpn <= 0 then xpn = 1 end
	local xpPct = math.floor((xp / xpn) * 100)
	local kills = (AZS_RUN and AZS_RUN.kills) or 0
	local gold = (AZS_RUN and tonumber(AZS_RUN.gold)) or 0
	local chest = (AZS_RUN and tonumber(AZS_RUN.chest)) or 20
	UI.xpBar:SetMinMaxValues(0, xpn)
	UI.xpBar:SetValue(xp)
	UI.xpText:SetText(string.format("%d%%  (%s / %s XP)", xpPct, AZSHelper:FormatNumber(xp), AZSHelper:FormatNumber(xpn)))
	UI.killsText:SetText(string.format("|cffffffff%s|r", AZSHelper:FormatNumber(kills)))
	local pays = (chest > 0 and gold >= chest)
	UI.goldSlot.pays = pays
	local costColor = pays and "|cff33ff33" or "|cffb39a5c"
	UI.goldText:SetText(string.format("|cffffd24d%s|r / %s%s|r", AZSHelper:FormatNumber(gold), costColor, AZSHelper:FormatNumber(chest)))
	local kw = UI.killsText:GetStringWidth() or 20
	local gw = UI.goldText:GetStringWidth() or 40
	local totalW = 8 + 15 + 4 + kw + 18 + 15 + 4 + gw + 8
	UI.tallyFrame:SetWidth(totalW)
end
-- =========================================================================
-- 6. TOP ENCOUNTER BARS (Multi-Boss & Miniboss Bar Container)
-- =========================================================================
UI.encounterContainer = CreateFrame("Frame", "AZSHelper_BossEncounterContainer", UIParent)
UI.encounterContainer:SetWidth(320)
UI.encounterContainer:SetHeight(160)
UI.encounterContainer:SetPoint("TOP", UIParent, "TOP", 0, -55)
UI.encounterContainer:SetFrameStrata("MEDIUM")
UI.encounterContainer:SetFrameLevel(25)
UI.encounterContainer:SetClampedToScreen(true)
AZSHelper:MakeMovable(UI.encounterContainer, "encounterBarsPos")
UI.encounterContainer:Hide()
UI.encounterBars = {}
for i = 1, 6 do
	local bar = CreateFrame("Frame", nil, UI.encounterContainer)
	bar:SetWidth(310)
	bar:SetHeight(22)
	bar:SetPoint("TOP", UI.encounterContainer, "TOP", 0, -(i - 1) * 26 - 2)
	bar:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile     = true,
		tileSize = 12,
		edgeSize = 8,
		insets   = { left = 1, right = 1, top = 1, bottom = 1 }
	})
	bar:SetBackdropColor(0.04, 0.04, 0.06, 0.95)
	bar:SetBackdropBorderColor(0.70, 0.55, 0.20, 0.85)
	local sb = CreateFrame("StatusBar", nil, bar)
	sb:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
	sb:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	sb:SetStatusBarTexture(FLAT)
	sb:SetMinMaxValues(0, 100)
	bar.statusBar = sb
	local nameText = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	nameText:SetPoint("LEFT", sb, "LEFT", 6, 0)
	nameText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
	nameText:SetJustifyH("LEFT")
	bar.nameText = nameText
	local hpText = sb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	hpText:SetPoint("RIGHT", sb, "RIGHT", -6, 0)
	hpText:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
	hpText:SetJustifyH("RIGHT")
	bar.hpText = hpText
	bar:Hide()
	UI.encounterBars[i] = bar
end
local function UpdateEncounterBars()
	local activeEnemies = {}
	local bosses = (AZS_GetBosses and AZS_GetBosses()) or {}
	for i = 1, table.getn(bosses) do
		local b = bosses[i]
		if b and b.hp and b.hp > 0 then
			table.insert(activeEnemies, {
				id      = b.id,
				name    = b.name or "Boss",
				hp      = b.hp,
				hpm     = (b.hpm and b.hpm > 0) and b.hpm or 100,
				kind    = (b.final == 1 or b.final == true) and "final" or "boss",
				enraged = b.enraged or false,
			})
		end
	end
	local guardians = (AZS_GetGuardians and AZS_GetGuardians()) or {}
	for i = 1, table.getn(guardians) do
		local g = guardians[i]
		if g and g.awake and g.hp and g.hp > 0 then
			local found = false
			for k = 1, table.getn(activeEnemies) do
				if activeEnemies[k].name == g.name then found = true break end
			end
			if not found then
				table.insert(activeEnemies, {
					id   = g.id,
					name = g.name or "Guardian",
					hp   = g.hp,
					hpm  = (g.hpm and g.hpm > 0) and g.hpm or 100,
					kind = "guardian",
				})
			end
		end
	end
	local total = table.getn(activeEnemies)
	if total > 0 then
		UI.encounterContainer:Show()
		for i = 1, 6 do
			local bar = UI.encounterBars[i]
			if i <= total then
				local en = activeEnemies[i]
				local hp = en.hp or 1
				local hpm = en.hpm or 1
				if hpm <= 0 then hpm = 1 end
				local pct = math.floor((hp / hpm) * 100)
				bar.statusBar:SetMinMaxValues(0, hpm)
				bar.statusBar:SetValue(hp)
				if en.kind == "final" then
					bar.statusBar:SetStatusBarColor(0.95, 0.25, 0.55, 1.0)
				elseif en.kind == "guardian" then
					bar.statusBar:SetStatusBarColor(0.20, 0.75, 0.95, 1.0)
				else
					bar.statusBar:SetStatusBarColor(0.72, 0.32, 1.00, 1.0)
				end
				bar.nameText:SetText(en.name)
				bar.hpText:SetText(string.format("%d%% (%s)", pct, AZSHelper:FormatNumber(hp)))
				bar:Show()
			else
				bar:Hide()
			end
		end
	else
		UI.encounterContainer:Hide()
	end
end
-- =========================================================================
-- 7. SQUARE MINIMAP & CHAT SKINNING
-- =========================================================================
function AZSHelper:ApplySquareMinimapStyle()
	local mm = Minimap
	if not mm then return end
	mm:SetMaskTexture(FLAT)
	mm:ClearAllPoints()
	mm:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -12, -12)
	mm:SetWidth(140)
	mm:SetHeight(140)
	local border = CreateFrame("Frame", "AZSHelper_MinimapSquareFrame", mm)
	border:SetPoint("TOPLEFT", mm, "TOPLEFT", -2, 2)
	border:SetPoint("BOTTOMRIGHT", mm, "BOTTOMRIGHT", 2, -2)
	border:SetFrameLevel(mm:GetFrameLevel() + 5)
	border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile     = true,
		tileSize = 8,
		edgeSize = 8,
		insets   = { left = 1, right = 1, top = 1, bottom = 1 }
	})
	border:SetBackdropBorderColor(0.20, 0.20, 0.25, 0.95)
	for _, name in pairs({
		"MinimapBorder", "MinimapBorderTop", "MinimapZoneTextButton",
		"MinimapZoomIn", "MinimapZoomOut", "GameTimeFrame", "MinimapToggleButton"
	}) do
		SafeHide(name)
	end
	mm:EnableMouseWheel(true)
	mm:SetScript("OnMouseWheel", function()
		if arg1 > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)
end
local function SkinChatButton(btn, symbol)
	if not btn then return end
	btn:SetWidth(16)
	btn:SetHeight(16)
	btn:SetNormalTexture("")
	btn:SetPushedTexture("")
	btn:SetDisabledTexture("")
	btn:SetHighlightTexture("")
	if btn.GetNormalTexture and btn:GetNormalTexture() then btn:GetNormalTexture():SetAlpha(0) end
	if btn.GetPushedTexture and btn:GetPushedTexture() then btn:GetPushedTexture():SetAlpha(0) end
	if btn.GetDisabledTexture and btn:GetDisabledTexture() then btn:GetDisabledTexture():SetAlpha(0) end
	if btn.GetHighlightTexture and btn:GetHighlightTexture() then btn:GetHighlightTexture():SetAlpha(0) end

	btn:SetBackdrop({
		bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile     = true,
		tileSize = 8,
		edgeSize = 8,
		insets   = { left = 1, right = 1, top = 1, bottom = 1 }
	})
	btn:SetBackdropColor(0.06, 0.06, 0.09, 0.90)
	btn:SetBackdropBorderColor(0.20, 0.20, 0.26, 0.95)

	if not btn.sText then
		local txt = btn:CreateFontString(nil, "OVERLAY")
		txt:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
		txt:SetPoint("CENTER", btn, "CENTER", 0, 0)
		txt:SetTextColor(0.85, 0.85, 0.90)
		txt:SetText(symbol)
		btn.sText = txt
	else
		btn.sText:SetText(symbol)
	end

	btn:SetScript("OnEnter", function()
		this:SetBackdropBorderColor(1, 0.82, 0, 1)
		if this.sText then this.sText:SetTextColor(1, 0.82, 0) end
	end)
	btn:SetScript("OnLeave", function()
		this:SetBackdropBorderColor(0.20, 0.20, 0.26, 0.95)
		if this.sText then this.sText:SetTextColor(0.85, 0.85, 0.90) end
	end)
end

function AZSHelper:SkinChatWindow()
	local chat = ChatFrame1
	if not chat or BordoUI_ChatBox then return end

	-- Modern Styled Container Box (Single Singleton Instance)
	local chatBox = CreateFrame("Frame", "BordoUI_ChatBox", UIParent)
	chatBox:SetWidth(380)
	chatBox:SetHeight(145)
	chatBox:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 14, 20)
	chatBox:SetFrameStrata("BACKGROUND")
	chatBox:SetFrameLevel(1)
	chatBox:SetClampedToScreen(true)
	chatBox:SetMovable(true)
	chatBox:EnableMouse(true)
	chatBox:RegisterForDrag("LeftButton")
	chatBox:SetBackdrop({
		bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile     = true,
		tileSize = 12,
		edgeSize = 8,
		insets   = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	chatBox:SetBackdropColor(0.04, 0.04, 0.06, 0.75) -- Translucent modern dark box
	chatBox:SetBackdropBorderColor(0.12, 0.12, 0.16, 0.95)

	-- Header Bar with Title, Drag Handle & Lock Button
	local chatHeader = CreateFrame("Frame", nil, chatBox)
	chatHeader:SetPoint("TOPLEFT", chatBox, "TOPLEFT", 0, 0)
	chatHeader:SetPoint("TOPRIGHT", chatBox, "TOPRIGHT", 0, 0)
	chatHeader:SetHeight(22)
	chatHeader:EnableMouse(true)
	chatHeader:RegisterForDrag("LeftButton")

	local chatTitle = chatHeader:CreateFontString(nil, "OVERLAY")
	chatTitle:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
	chatTitle:SetPoint("LEFT", chatHeader, "LEFT", 8, 0)
	chatTitle:SetTextColor(0.85, 0.85, 0.88)
	chatTitle:SetText("Chat")

	local function SaveChatPos()
		local pt, _, relPt, x, y = chatBox:GetPoint()
		BordoUIDB = BordoUIDB or {}
		BordoUIDB.chatPos = { point = pt, relativePoint = relPt, x = x, y = y }
	end

	chatHeader:SetScript("OnDragStart", function()
		if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
			chatBox:StartMoving()
		end
	end)
	chatHeader:SetScript("OnDragStop", function()
		chatBox:StopMovingOrSizing()
		SaveChatPos()
	end)

	chatBox:SetScript("OnDragStart", function()
		if (not (BordoUIDB and BordoUIDB.locked)) or IsAltKeyDown() or IsShiftKeyDown() then
			chatBox:StartMoving()
		end
	end)
	chatBox:SetScript("OnDragStop", function()
		chatBox:StopMovingOrSizing()
		SaveChatPos()
	end)

	if ( BordoUI and BordoUI.AttachLockButton ) then
		BordoUI:AttachLockButton(chatBox, "TOPRIGHT", chatHeader, "TOPRIGHT", -4, -3)
	end

	-- Restore Saved Position
	if BordoUIDB and BordoUIDB.chatPos and BordoUIDB.chatPos.point then
		AZSHelper:RestorePosition(chatBox, BordoUIDB.chatPos)
	end

	-- Bind ChatFrame1 cleanly inside chatBox
	chat:SetParent(chatBox)
	chat:SetFrameLevel(chatBox:GetFrameLevel() + 2)
	chat:SetMovable(false)
	chat:SetClampedToScreen(true)
	chat:ClearAllPoints()
	chat:SetPoint("TOPLEFT", chatBox, "TOPLEFT", 28, -24)
	chat:SetPoint("BOTTOMRIGHT", chatBox, "BOTTOMRIGHT", -6, 6)

	if FCF_SetLocked then
		FCF_SetLocked(chat, nil)
	end

	-- Modern Scroll Buttons docked inside left margin of chatBox
	local upBtn = getglobal("ChatFrame1UpButton")
	local downBtn = getglobal("ChatFrame1DownButton")
	local bottomBtn = getglobal("ChatFrame1BottomButton")
	local menuBtn = getglobal("ChatFrameMenuButton")
	if menuBtn then menuBtn:Hide() end

	if upBtn then
		SkinChatButton(upBtn, "^")
		upBtn:SetParent(chatBox)
		upBtn:SetFrameLevel(chatBox:GetFrameLevel() + 5)
		upBtn:ClearAllPoints()
		upBtn:SetPoint("TOPLEFT", chatBox, "TOPLEFT", 6, -26)
	end
	if downBtn then
		SkinChatButton(downBtn, "v")
		downBtn:SetParent(chatBox)
		downBtn:SetFrameLevel(chatBox:GetFrameLevel() + 5)
		downBtn:ClearAllPoints()
		downBtn:SetPoint("TOP", upBtn or chatBox, upBtn and "BOTTOM" or "TOPLEFT", 0, upBtn and -3 or -45)
	end
	if bottomBtn then
		SkinChatButton(bottomBtn, ">>")
		bottomBtn:SetParent(chatBox)
		bottomBtn:SetFrameLevel(chatBox:GetFrameLevel() + 5)
		bottomBtn:ClearAllPoints()
		bottomBtn:SetPoint("TOP", downBtn or chatBox, downBtn and "BOTTOM" or "TOPLEFT", 0, downBtn and -3 or -64)
	end

	-- Flatten and Style Tabs
	for i = 1, 7 do
		local tab = getglobal("ChatFrame"..i.."Tab")
		if tab then
			local tLeft = getglobal("ChatFrame"..i.."TabLeft")
			local tMid = getglobal("ChatFrame"..i.."TabMiddle")
			local tRight = getglobal("ChatFrame"..i.."TabRight")
			if tLeft then tLeft:SetAlpha(0) end
			if tMid then tMid:SetAlpha(0) end
			if tRight then tRight:SetAlpha(0) end
		end
	end
	if ChatFrame1Tab then
		ChatFrame1Tab:ClearAllPoints()
		ChatFrame1Tab:SetPoint("LEFT", chatTitle, "RIGHT", 8, 0)
	end

	for i = 1, 7 do
		local cf = getglobal("ChatFrame"..i)
		if cf then
			cf:EnableMouseWheel(true)
			cf:SetScript("OnMouseWheel", function()
				if arg1 > 0 then
					if IsShiftKeyDown() then this:ScrollToTop() else this:ScrollUp() end
				else
					if IsShiftKeyDown() then this:ScrollToBottom() else this:ScrollDown() end
				end
			end)
		end
	end
end
-- =========================================================================
-- 8. MAIN UPDATE LOOPS & EVENT HANDLING
-- =========================================================================
local function HideDefaultBlizzardFrames()
	for _, name in pairs({
		"PlayerFrame", "TargetFrame", "BuffFrame", "TemporaryEnchantFrame"
	}) do
		local frame = getglobal(name)
		if frame then
			if frame.UnregisterAllEvents then frame:UnregisterAllEvents() end
			frame:Hide()
		end
	end
end
local unitElapsed = 0
local auraElapsed = 0
local tallyElapsed = 0
local skillElapsed = 0
local mainWatcher = CreateFrame("Frame")
mainWatcher:SetScript("OnUpdate", function()
	unitElapsed = unitElapsed + arg1
	if unitElapsed >= 0.05 then
		unitElapsed = 0
		UpdateUnitFrame(player)
		UpdateUnitFrame(target)
		if UnitExists("target") then
			UpdateDebuffs()
		end
	end
	auraElapsed = auraElapsed + arg1
	if auraElapsed >= 0.1 then
		auraElapsed = 0
		UpdateAuras()
	end
	tallyElapsed = tallyElapsed + arg1
	if tallyElapsed >= 0.25 then
		tallyElapsed = 0
		UpdateBottomBar()
		UpdateEncounterBars()
	end
	skillElapsed = skillElapsed + arg1
	if skillElapsed >= 0.2 then
		skillElapsed = 0
		UpdateSkills()
	end
end)
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
eventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
eventHandler:RegisterEvent("UNIT_PORTRAIT_UPDATE")
eventHandler:RegisterEvent("VARIABLES_LOADED")
eventHandler:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
eventHandler:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
eventHandler:RegisterEvent("ACTIONBAR_UPDATE_STATE")
eventHandler:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
eventHandler:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
eventHandler:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
eventHandler:SetScript("OnEvent", function()
	if event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
		LayoutBar()
		HideDefaultBlizzardFrames()
		AZSHelper:ApplySquareMinimapStyle()
		AZSHelper:SkinChatWindow()
		UpdatePortrait(player)
		UpdateUnitFrame(player)
		if BordoUIDB and BordoUIDB.hudPos and BordoUIDB.hudPos.point then
			AZSHelper:RestorePosition(row, BordoUIDB.hudPos)
		elseif AZSHelperDB and AZSHelperDB.rowPos and AZSHelperDB.rowPos.point then
			AZSHelper:RestorePosition(row, AZSHelperDB.rowPos)
		else
			row:ClearAllPoints()
			row:SetPoint("CENTER", UIParent, "CENTER", 0, -170)
		end
		UI.xpBar:ClearAllPoints()
		UI.xpBar:SetPoint("TOP", row, "BOTTOM", 0, -4)
		UI.xpBar:SetWidth(row:GetWidth() + 2 * (SECTION_GAP + FRAME_WIDTH))
		UI.xpBar:SetHeight(5)
		if BordoUIDB and BordoUIDB.tallyPos and BordoUIDB.tallyPos.point then
			AZSHelper:RestorePosition(UI.tallyFrame, BordoUIDB.tallyPos)
		elseif AZSHelperDB and AZSHelperDB.tallyPos and AZSHelperDB.tallyPos.point then
			AZSHelper:RestorePosition(UI.tallyFrame, AZSHelperDB.tallyPos)
		else
			UI.tallyFrame:ClearAllPoints()
			UI.tallyFrame:SetPoint("TOP", UI.xpBar, "BOTTOM", 0, -4)
		end
		if UI.minimapDock then
			if BordoUIDB and BordoUIDB.minimapDockPos and BordoUIDB.minimapDockPos.point then
				AZSHelper:RestorePosition(UI.minimapDock, BordoUIDB.minimapDockPos)
			elseif AZSHelperDB and AZSHelperDB.minimapDockPos and AZSHelperDB.minimapDockPos.point then
				AZSHelper:RestorePosition(UI.minimapDock, AZSHelperDB.minimapDockPos)
			else
				UI.minimapDock:ClearAllPoints()
				UI.minimapDock:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -6, 0)
			end
		end
		if PositionMicroButtons then PositionMicroButtons() end
	elseif event == "ACTIONBAR_PAGE_CHANGED" then
		if CURRENT_ACTIONBAR_PAGE ~= 1 then
			CURRENT_ACTIONBAR_PAGE = 1
			if ChangeActionBarPage then ChangeActionBarPage(1) end
		end
		UpdateSkills()
	elseif event == "ACTIONBAR_SLOT_CHANGED" or event == "ACTIONBAR_UPDATE_STATE"
		or event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_BONUS_ACTIONBAR"
		or event == "UPDATE_SHAPESHIFT_FORMS" then
		UpdateSkills()
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdatePortrait(target)
		UpdateUnitFrame(target)
		if UnitExists("target") then
			UpdateDebuffs()
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		if arg1 == "player" then
			UpdatePortrait(player)
		elseif arg1 == "target" then
			UpdatePortrait(target)
		end
	end
end)
function BordoUI_ResetThemeUI()
	row:ClearAllPoints()
	row:SetPoint("CENTER", UIParent, "CENTER", 0, -170)
	UI.xpBar:ClearAllPoints()
	UI.xpBar:SetPoint("TOP", row, "BOTTOM", 0, -4)
		UI.xpBar:SetWidth(row:GetWidth() + 2 * (SECTION_GAP + FRAME_WIDTH))
		UI.xpBar:SetHeight(5)
	UI.tallyFrame:ClearAllPoints()
	UI.tallyFrame:SetPoint("TOP", UI.xpBar, "BOTTOM", 0, -4)
	if UI.minimapDock then
		UI.minimapDock:ClearAllPoints()
		UI.minimapDock:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -6, 0)
	end
	if BordoUI_ChatBox then
		BordoUI_ChatBox:ClearAllPoints()
		BordoUI_ChatBox:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 14, 20)
	end
	if PositionMicroButtons then PositionMicroButtons() end
	if BordoUIDB then
		BordoUIDB.hudPos = nil
		BordoUIDB.bottomBarPos = nil
		BordoUIDB.tallyPos = nil
		BordoUIDB.microDockPos = nil
	end
	if AZSHelperDB then
		AZSHelperDB.rowPos = nil
		AZSHelperDB.bottomBarPos = nil
		AZSHelperDB.tallyPos = nil
		AZSHelperDB.microDockPos = nil
	end
end
