--[[
    Bordo UI - Modern Damage Numbers (DamageFont.lua)
    World of Warcraft 1.12.1 / Azeroth Survivors
    - Clean, modern, crisp sans-serif font for floating combat damage numbers
    - Compact scaling so numbers don't clutter the screen
]]--

function AZSHelper:ApplyModernDamageText()
    local modernFont = "Interface\\AddOns\\BordoUI\\Media\\modern.ttf";
    local fallbackFont = "Fonts\\ARIALN.TTF";
    
    -- In WoW 1.12 engine, DAMAGE_TEXT_FONT sets the 3D in-world floating combat text font
    DAMAGE_TEXT_FONT = modernFont;
    
    local db = BordoUIDB or AZSHelperDB;
    local scale = (db and db.dmgScale) or 0.75;
    
    if ( CombatText ) then
        CombatText:SetScale(scale);
    end
    
    if ( CombatTextFont ) then
        CombatTextFont:SetFont(modernFont, 18, "OUTLINE");
    end
end

-- Apply immediately on load
AZSHelper:ApplyModernDamageText();

-- Also ensure it is applied on world entry
local fontListener = CreateFrame("Frame", "BordoUI_FontListener");
fontListener:RegisterEvent("PLAYER_ENTERING_WORLD");
fontListener:SetScript("OnEvent", function()
    AZSHelper:ApplyModernDamageText();
end);
