local _G = getfenv(0)

SLASH_UNITPLATES1 = "/unitplates"
SLASH_UNITPLATES2 = "/up"

SlashCmdList["UNITPLATES"] = function(msg)
	--print("UnitPlates config is not available yet")
	UnitPlatesOptionsFrame:Show()
end

UnitPlatesOptionsFrame = CreateFrame("Frame", "UnitPlatesOptionsFrame", UIParent)

local UPMinimapButton = CreateFrame('Button', "UPMainMenuBarToggler", Minimap)
function LoadUPMinimapButton()
    UPMinimapButton:SetFrameStrata('MEDIUM')
    UPMinimapButton:SetWidth(31)
    UPMinimapButton:SetHeight(31)
    UPMinimapButton:SetFrameLevel(8)
    --UPMinimapButton:RegisterForClicks('anyUp')
    UPMinimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
	UPMinimapButton:SetMovable(true)
	UPMinimapButton:EnableMouse(true)

    local UPMinimapButtonOverlay = UPMinimapButton:CreateTexture(nil, 'OVERLAY')
    UPMinimapButtonOverlay:SetWidth(53)
    UPMinimapButtonOverlay:SetHeight(53)
    UPMinimapButtonOverlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
    UPMinimapButtonOverlay:SetPoint('TOPLEFT', 0, 0)

    local icon = UPMinimapButton:CreateTexture(nil, 'BACKGROUND')
    icon:SetWidth(20)
    icon:SetHeight(20)
    --icon:SetTexture('Interface\\Icons\\Spell_ChargeNegative')
	icon:SetTexture('Interface\\AddOns\\UnitPlates\\img\\minimap\\minimap_icon')
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint('TOPLEFT', 7, -5)
    UPMinimapButton.icon = icon

    UPMinimapButton:SetScript("OnClick", function()
		if arg1 == "LeftButton" then
			if not UnitPlatesOptionsFrame:IsShown() then
				UnitPlatesOptionsFrame:Show()
			else
				UnitPlatesOptionsFrame:Hide()
			end
		elseif arg1 == "RightButton" then
			-- nothing
		end
	end)
	
	UPMinimapButton:RegisterForDrag("RightButton")
	UPMinimapButton:SetScript("OnDragStart", function()
		UPMinimapButton:StartMoving()
		UPMinimapButton:SetScript("OnUpdate", function()
			local Xpoa, Ypoa = GetCursorPosition()
			local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
			Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
			Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
			UnitPlatesSettings.minimapIconPos = math.deg(math.atan2(Ypoa, Xpoa))
			UPMinimapButton:ClearAllPoints()
			UPMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(UnitPlatesSettings.minimapIconPos)), (80 * sin(UnitPlatesSettings.minimapIconPos)) - 52)
		end)
	end)
	 
	UPMinimapButton:SetScript("OnDragStop", function()
		UPMinimapButton:StopMovingOrSizing()
		UPMinimapButton:SetScript("OnUpdate", nil)
		--CHBUpdateMapBtn()
	end)
	
	UPMinimapButton:SetScript("OnEnter", function()			
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		local scale = GameTooltip:GetEffectiveScale()
		local x, y = GetCursorPosition()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
		GameTooltip:SetText("UnitPlates")
		GameTooltip:AddLine("\n")
		GameTooltip:AddLine("Left-click to show options", 1, 1, 1)
		GameTooltip:AddLine("Right-click and drag to move the button", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	UPMinimapButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

    
	if UnitPlatesSettings.minimapIconPos ~= 0 then
		UPMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(UnitPlatesSettings.minimapIconPos)), (80 * sin(UnitPlatesSettings.minimapIconPos)) - 52)
	else
		UPMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -2, 2)
	end
end

--UnitPlatesSettings = UnitPlatesSettings or {}

function UPConfigLoadUnitPlatesDefaultSettings()
	UnitPlatesSettings = {
		minimapIconPos = 0,
		smallerAuras = true,
		additionalAuraPollingDelaySeconds = "0.2",
		showBuffs=true,
		onlyYourBuffs=false,
		ignoredBuffNames = "name1,name2",
		showDebuffs=true,
		onlyYourDebuffs=false,
		ignoredDebuffNames = "name1,name2",
		enableWoWTranslateSupport = true,
		enableChatBubbleHandling = true,
		scale = "1.0"
	}
end

function UPConfigLoadUnitPlatesSettings() 
	if UnitPlatesSettings == nil then
		UPConfigLoadUnitPlatesDefaultSettings()
		print("unable to load UnitPlates saved data, backing up to defaults")
	else
		if UnitPlatesSettings.minimapIconPos == nil then
			UnitPlatesSettings.minimapIconPos=0
		end
		if UnitPlatesSettings.smallerAuras == nil then
			UnitPlatesSettings.smallerAuras=true
		end
		if UnitPlatesSettings.additionalAuraPollingDelaySeconds == nil then
			UnitPlatesSettings.additionalAuraPollingDelaySeconds="0.2"
		end
		if UnitPlatesSettings.showBuffs == nil then
			UnitPlatesSettings.showBuffs=true
		end
		if UnitPlatesSettings.onlyYourBuffs == nil then
			UnitPlatesSettings.onlyYourBuffs=false
		end
		if UnitPlatesSettings.ignoredBuffNames == nil then
			UnitPlatesSettings.ignoredBuffNames="name1,name2"
		end
		if UnitPlatesSettings.showDebuffs == nil then
			UnitPlatesSettings.showDebuffs=true
		end
		if UnitPlatesSettings.onlyYourDebuffs == nil then
			UnitPlatesSettings.onlyYourDebuffs=false
		end
		if UnitPlatesSettings.ignoredDebuffNames == nil then
			UnitPlatesSettings.ignoredDebuffNames="name1,name2"
		end
		if UnitPlatesSettings.enableWoWTranslateSupport == nil then
			UnitPlatesSettings.enableWoWTranslateSupport=true
		end
		if UnitPlatesSettings.enableChatBubbleHandling == nil then
			UnitPlatesSettings.enableChatBubbleHandling=true
		end
		if UnitPlatesSettings.scale == nil or (not tonumber(UnitPlatesSettings.scale)) then
			UnitPlatesSettings.scale="1.0"
		end
		print("UnitPlates saved data loaded")
	end
end

function UPConfigInitUnitPlatesSettings()
	UPConfigLoadUnitPlatesSettings() 

	UnitPlatesOptionsFrame:SetMovable(true)
	UnitPlatesOptionsFrame:EnableMouse(true)
	
	UnitPlatesOptionsFrame:SetScript("OnMouseDown", function()
	  if arg1 == "LeftButton" and not UnitPlatesOptionsFrame.isMoving then
	   UnitPlatesOptionsFrame:StartMoving()
	   UnitPlatesOptionsFrame.isMoving = true
	  end
	end)
	UnitPlatesOptionsFrame:SetScript("OnMouseUp", function()
	  if arg1 == "LeftButton" and UnitPlatesOptionsFrame.isMoving then
	   UnitPlatesOptionsFrame:StopMovingOrSizing()
	   UnitPlatesOptionsFrame.isMoving = false
	  end
	end)
	UnitPlatesOptionsFrame:SetScript("OnHide", function()
	  if ( UnitPlatesOptionsFrame.isMoving ) then
	   UnitPlatesOptionsFrame:StopMovingOrSizing()
	   UnitPlatesOptionsFrame.isMoving = false
	  end
	end)
	
	UnitPlatesOptionsFrame:SetWidth(500)
	UnitPlatesOptionsFrame:SetHeight(500)
	UnitPlatesOptionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	
	UnitPlatesOptionsFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	UnitPlatesOptionsFrame:SetBackdropColor(0,0,0,.5)
	
	UnitPlatesOptionsFrame.title = UnitPlatesOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--nameplate.health.text:SetAllPoints()
	UnitPlatesOptionsFrame.title:SetPoint("TOP", UnitPlatesOptionsFrame, "TOP", 0, -8)
	UnitPlatesOptionsFrame.title:SetTextColor(1,1,1,barAlpha)
	UnitPlatesOptionsFrame.title:SetFont("Interface\\AddOns\\UnitPlates\\fonts\\francois.ttf", 12, "OUTLINE")
	UnitPlatesOptionsFrame.title:SetJustifyH("LEFT")
	UnitPlatesOptionsFrame.title:SetText("UnitPlates options")
	
	local closeButton = CreateFrame("Button", nil, UnitPlatesOptionsFrame, "UIPanelButtonTemplate")
	closeButton:SetPoint("TOPRIGHT",0,0)
	closeButton:SetWidth(50)
	closeButton:SetHeight(25)
	closeButton:SetText("Close")
	closeButton:SetScript("OnClick", function()
		UnitPlatesOptionsFrame:Hide()
	end)
	
	local setDefaultsButton = CreateFrame("Button", nil, UnitPlatesOptionsFrame, "UIPanelButtonTemplate")
	setDefaultsButton:SetPoint("BOTTOMLEFT",UnitPlatesOptionsFrame,"BOTTOMLEFT",0,0)
	setDefaultsButton:SetWidth(200)
	setDefaultsButton:SetHeight(40)
	setDefaultsButton:SetText("Set defaults & Reload")
	setDefaultsButton:SetScript("OnClick", function()
		UPConfigLoadUnitPlatesDefaultSettings()
		ReloadUI()
	end)
	
	local saveButton = CreateFrame("Button", nil, UnitPlatesOptionsFrame, "UIPanelButtonTemplate")
	saveButton:SetPoint("BOTTOMRIGHT",UnitPlatesOptionsFrame,"BOTTOMRIGHT",0,0)
	saveButton:SetWidth(200)
	saveButton:SetHeight(40)
	saveButton:SetText("Save & Reload")
	saveButton:SetScript("OnClick", function()
		--no need to additionally save anything, but calling it "Save & Reload" is supposed to reassure the user 
		ReloadUI()
	end)
	
	-- Create the scrolling parent frame and size it to fit inside the texture
	UnitPlatesOptionsFrame.scrollFrame = CreateFrame("ScrollFrame", "UnitPlatesOptionsFrame_ScrollFrame", UnitPlatesOptionsFrame, "UIPanelScrollFrameTemplate")
	UnitPlatesOptionsFrame.scrollFrame:SetHeight(UnitPlatesOptionsFrame:GetHeight())
	UnitPlatesOptionsFrame.scrollBar = _G[UnitPlatesOptionsFrame.scrollFrame:GetName() .. "ScrollBar"]
    UnitPlatesOptionsFrame.scrollFrame:SetWidth(UnitPlatesOptionsFrame:GetWidth())
	UnitPlatesOptionsFrame.scrollFrame:SetPoint("TOPLEFT", 10, -30)
	UnitPlatesOptionsFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

	-- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height (such as 1)
	local scrollChild = CreateFrame("Frame", nil, UnitPlatesOptionsFrame.scrollFrame)
	scrollChild:SetWidth(UnitPlatesOptionsFrame:GetWidth()-18)
	scrollChild:SetHeight(1) 
	scrollChild:SetAllPoints(UnitPlatesOptionsFrame.scrollFrame)
	UnitPlatesOptionsFrame.scrollFrame:SetScrollChild(scrollChild)
	
	
	
	local aurasSectionTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	aurasSectionTitle:SetPoint("TOPLEFT",8,-24)
	aurasSectionTitle:SetTextColor(0.999,0.819,0,barAlpha)
	aurasSectionTitle:SetJustifyH("LEFT")
	aurasSectionTitle:SetText("--- AURAS:")	
	
	
	local smallerAurasCheckbox = CreateFrame("CheckButton", "smallerAurasCheckbox", scrollChild, "UICheckButtonTemplate")
	smallerAurasCheckbox:SetPoint("TOPLEFT", aurasSectionTitle, "BOTTOMLEFT", 0, -4)
	getglobal(smallerAurasCheckbox:GetName() .. 'Text'):SetText("Smaller auras")
	smallerAurasCheckbox:SetChecked(UnitPlatesSettings.smallerAuras)
	smallerAurasCheckbox.tooltip = "Smaller auras"
	smallerAurasCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.smallerAuras=not UnitPlatesSettings.smallerAuras
		--applyAllSettings()
	end)
	
	
	local additionalAuraPollingDelaySecondsTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	additionalAuraPollingDelaySecondsTitle:SetPoint("TOPLEFT", smallerAurasCheckbox, "BOTTOMLEFT", 0, -4)
	additionalAuraPollingDelaySecondsTitle:SetTextColor(0.999,0.819,0,barAlpha)
	additionalAuraPollingDelaySecondsTitle:SetJustifyH("LEFT")
	additionalAuraPollingDelaySecondsTitle:SetText("Additional aura polling delay (seconds, e.g. 2 or 0.2) 0.2 is optimal\nTry setting above 0.2 if auras are not appearing at all sometimes\nSetting it to 0 will make it more responsive\nbut may also cause auras to not appear in some weird cases\nGenerally best to be kept between 0 and 0.3: ")
	
	local additionalAuraPollingDelaySecondsInput = CreateFrame("EditBox", nil, scrollChild)
	additionalAuraPollingDelaySecondsInput:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	additionalAuraPollingDelaySecondsInput:SetBackdropColor(0,0,0,.5)
	additionalAuraPollingDelaySecondsInput:SetTextInsets(5, 5, 5, 5)
	additionalAuraPollingDelaySecondsInput:SetTextColor(1,1,1,1)
	additionalAuraPollingDelaySecondsInput:SetJustifyH("LEFT")
	additionalAuraPollingDelaySecondsInput:SetWidth(280)
	additionalAuraPollingDelaySecondsInput:SetHeight(26)
	additionalAuraPollingDelaySecondsInput:SetPoint("TOPLEFT", additionalAuraPollingDelaySecondsTitle, "BOTTOMLEFT", 0, 0)
	additionalAuraPollingDelaySecondsInput:SetFontObject("GameFontNormal")
	additionalAuraPollingDelaySecondsInput:SetAutoFocus(false)
	additionalAuraPollingDelaySecondsInput:SetText(""..UnitPlatesSettings.additionalAuraPollingDelaySeconds)
	additionalAuraPollingDelaySecondsInput:SetScript("OnTextChanged", function(self)
		local inputValue = additionalAuraPollingDelaySecondsInput:GetText()
		if not inputValue then
			additionalAuraPollingDelaySecondsInput:SetText(""..UnitPlatesSettings.additionalAuraPollingDelaySeconds)
		else
			UnitPlatesSettings.additionalAuraPollingDelaySeconds = inputValue
			additionalAuraPollingDelaySecondsInput:SetText(""..UnitPlatesSettings.additionalAuraPollingDelaySeconds)
			--applyAllSettings()
		end
	end)
	
	
	
	
	
	local showBuffsCheckbox = CreateFrame("CheckButton", "showBuffsCheckbox", scrollChild, "UICheckButtonTemplate")
	showBuffsCheckbox:SetPoint("TOPLEFT", additionalAuraPollingDelaySecondsInput, "BOTTOMLEFT", 0, -16)
	getglobal(showBuffsCheckbox:GetName() .. 'Text'):SetText("Show buffs")
	showBuffsCheckbox:SetChecked(UnitPlatesSettings.showBuffs)
	showBuffsCheckbox.tooltip = "Show buffs"
	showBuffsCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.showBuffs=not UnitPlatesSettings.showBuffs
		--applyAllSettings()
	end)
	
	local showOnlyYourBuffsCheckbox = CreateFrame("CheckButton", "showOnlyYourBuffsCheckbox", scrollChild, "UICheckButtonTemplate")
	showOnlyYourBuffsCheckbox:SetPoint("TOP", showBuffsCheckbox, "BOTTOM", 0, -0)
	getglobal(showOnlyYourBuffsCheckbox:GetName() .. 'Text'):SetText("Show only your buffs")
	showOnlyYourBuffsCheckbox:SetChecked(UnitPlatesSettings.onlyYourBuffs)
	showOnlyYourBuffsCheckbox.tooltip = "Show only your buffs"
	showOnlyYourBuffsCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.onlyYourBuffs=not UnitPlatesSettings.onlyYourBuffs
		--applyAllSettings()
	end)
	--showOnlyYourBuffsCheckbox:Hide()
	
	local ignoredBuffnamesTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ignoredBuffnamesTitle:SetPoint("TOPLEFT", showOnlyYourBuffsCheckbox, "BOTTOMLEFT", 0, -4)
	ignoredBuffnamesTitle:SetTextColor(0.999,0.819,0,barAlpha)
	ignoredBuffnamesTitle:SetJustifyH("LEFT")
	ignoredBuffnamesTitle:SetText("Ignore buff names: ")
	
	local ignoredBuffnamesInput = CreateFrame("EditBox", nil, scrollChild)
	ignoredBuffnamesInput:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	ignoredBuffnamesInput:SetBackdropColor(0,0,0,.5)
	ignoredBuffnamesInput:SetTextInsets(5, 5, 5, 5)
	ignoredBuffnamesInput:SetTextColor(1,1,1,1)
	ignoredBuffnamesInput:SetJustifyH("LEFT")
	ignoredBuffnamesInput:SetWidth(280)
	ignoredBuffnamesInput:SetHeight(26)
	ignoredBuffnamesInput:SetPoint("TOPLEFT", ignoredBuffnamesTitle, "BOTTOMLEFT", 0, 0)
	ignoredBuffnamesInput:SetFontObject("GameFontNormal")
	ignoredBuffnamesInput:SetAutoFocus(false)
	ignoredBuffnamesInput:SetText(""..UnitPlatesSettings.ignoredBuffNames)
	ignoredBuffnamesInput:SetScript("OnTextChanged", function(self)
		local inputValue = ignoredBuffnamesInput:GetText()
		if not inputValue then
			ignoredBuffnamesInput:SetText(""..UnitPlatesSettings.ignoredBuffNames)
		else
			UnitPlatesSettings.ignoredBuffNames = inputValue
			ignoredBuffnamesInput:SetText(""..UnitPlatesSettings.ignoredBuffNames)
			--applyAllSettings()
		end
	end)
	
	local showDebuffsCheckbox = CreateFrame("CheckButton", "showDebuffsCheckbox", scrollChild, "UICheckButtonTemplate")
	showDebuffsCheckbox:SetPoint("TOPLEFT", ignoredBuffnamesInput, "BOTTOMLEFT", 0, -16)
	getglobal(showDebuffsCheckbox:GetName() .. 'Text'):SetText("Show debuffs")
	showDebuffsCheckbox:SetChecked(UnitPlatesSettings.showDebuffs)
	showDebuffsCheckbox.tooltip = "Show debuffs"
	showDebuffsCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.showDebuffs=not UnitPlatesSettings.showDebuffs
		--applyAllSettings()
	end)
	
	local showOnlyYourDebuffsCheckbox = CreateFrame("CheckButton", "showOnlyYourDebuffsCheckbox", scrollChild, "UICheckButtonTemplate")
	showOnlyYourDebuffsCheckbox:SetPoint("TOP", showDebuffsCheckbox, "BOTTOM", 0, -0)
	getglobal(showOnlyYourDebuffsCheckbox:GetName() .. 'Text'):SetText("Show only your debuffs")
	showOnlyYourDebuffsCheckbox:SetChecked(UnitPlatesSettings.onlyYourDebuffs)
	showOnlyYourDebuffsCheckbox.tooltip = "Show only your debuffs"
	showOnlyYourDebuffsCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.onlyYourDebuffs=not UnitPlatesSettings.onlyYourDebuffs
		--applyAllSettings()
	end)
	--showOnlyYourDebuffsCheckbox:Hide()
	
	local ignoredDebuffnamesTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ignoredDebuffnamesTitle:SetPoint("TOPLEFT", showOnlyYourDebuffsCheckbox, "BOTTOMLEFT", 0, -4)
	ignoredDebuffnamesTitle:SetTextColor(0.999,0.819,0,barAlpha)
	ignoredDebuffnamesTitle:SetJustifyH("LEFT")
	ignoredDebuffnamesTitle:SetText("Ignore debuff names: ")
	
	local ignoredDebuffnamesInput = CreateFrame("EditBox", nil, scrollChild)
	ignoredDebuffnamesInput:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	ignoredDebuffnamesInput:SetBackdropColor(0,0,0,.5)
	ignoredDebuffnamesInput:SetTextInsets(5, 5, 5, 5)
	ignoredDebuffnamesInput:SetTextColor(1,1,1,1)
	ignoredDebuffnamesInput:SetJustifyH("LEFT")
	ignoredDebuffnamesInput:SetWidth(280)
	ignoredDebuffnamesInput:SetHeight(26)
	ignoredDebuffnamesInput:SetPoint("TOPLEFT", ignoredDebuffnamesTitle, "BOTTOMLEFT", 0, 0)
	ignoredDebuffnamesInput:SetFontObject("GameFontNormal")
	ignoredDebuffnamesInput:SetAutoFocus(false)
	ignoredDebuffnamesInput:SetText(""..UnitPlatesSettings.ignoredDebuffNames)
	ignoredDebuffnamesInput:SetScript("OnTextChanged", function(self)
		local inputValue = ignoredDebuffnamesInput:GetText()
		if not inputValue then
			ignoredDebuffnamesInput:SetText(""..UnitPlatesSettings.ignoredDebuffNames)
		else
			UnitPlatesSettings.ignoredDebuffNames = inputValue
			ignoredDebuffnamesInput:SetText(""..UnitPlatesSettings.ignoredDebuffNames)
			--applyAllSettings()
		end
	end)
	
	----------------
	
	local uiSectionTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	uiSectionTitle:SetPoint("TOPLEFT", ignoredDebuffnamesInput, "BOTTOMLEFT", 0, -32)
	uiSectionTitle:SetTextColor(0.999,0.819,0,barAlpha)
	uiSectionTitle:SetJustifyH("LEFT")
	uiSectionTitle:SetText("--- UI:")	
	
	local scaleTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	scaleTitle:SetPoint("TOPLEFT", uiSectionTitle, "BOTTOMLEFT", 0, -8)
	scaleTitle:SetTextColor(0.999,0.819,0,barAlpha)
	scaleTitle:SetJustifyH("LEFT")
	scaleTitle:SetText("Scale (Valid value is number e.g. 1 or 1.0 or 0.3434 etc.): ")
	
	local scaleInput = CreateFrame("EditBox", nil, scrollChild)
	scaleInput:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	scaleInput:SetBackdropColor(0,0,0,.5)
	scaleInput:SetTextInsets(5, 5, 5, 5)
	scaleInput:SetTextColor(1,1,1,1)
	scaleInput:SetJustifyH("LEFT")
	scaleInput:SetWidth(280)
	scaleInput:SetHeight(26)
	scaleInput:SetPoint("TOPLEFT", scaleTitle, "BOTTOMLEFT", 0, 0)
	scaleInput:SetFontObject("GameFontNormal")
	scaleInput:SetAutoFocus(false)
	scaleInput:SetText(""..UnitPlatesSettings.scale)
	scaleInput:SetScript("OnTextChanged", function(self)
		local inputValue = scaleInput:GetText()
		if not inputValue then
			scaleInput:SetText(""..UnitPlatesSettings.scale)
		else
			UnitPlatesSettings.scale = inputValue
			scaleInput:SetText(""..UnitPlatesSettings.scale)
			--applyAllSettings()
		end
	end)
	
	----------------
	
	local compatibilitySectionTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	compatibilitySectionTitle:SetPoint("TOPLEFT", scaleInput, "BOTTOMLEFT", 0, -32)
	compatibilitySectionTitle:SetTextColor(0.999,0.819,0,barAlpha)
	compatibilitySectionTitle:SetJustifyH("LEFT")
	compatibilitySectionTitle:SetText("--- COMPATIBILITY:")	
	
	local enableWoWTranslateSupportCheckbox = CreateFrame("CheckButton", "enableWoWTranslateSupportCheckbox", scrollChild, "UICheckButtonTemplate")
	enableWoWTranslateSupportCheckbox:SetPoint("TOPLEFT", compatibilitySectionTitle, "BOTTOMLEFT", 0, -8)
	getglobal(enableWoWTranslateSupportCheckbox:GetName() .. 'Text'):SetText("Enable WoWTranslate support")
	enableWoWTranslateSupportCheckbox:SetChecked(UnitPlatesSettings.enableWoWTranslateSupport)
	enableWoWTranslateSupportCheckbox.tooltip = "Enable WoWTranslate support"
	enableWoWTranslateSupportCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.enableWoWTranslateSupport=not UnitPlatesSettings.enableWoWTranslateSupport
		--applyAllSettings()
	end)
	
	local enableChatBubbleHandlingCheckbox = CreateFrame("CheckButton", "enableChatBubbleHandlingCheckbox", scrollChild, "UICheckButtonTemplate")
	enableChatBubbleHandlingCheckbox:SetPoint("TOP", enableWoWTranslateSupportCheckbox, "BOTTOM", 0, -0)
	getglobal(enableChatBubbleHandlingCheckbox:GetName() .. 'Text'):SetText("Enable chat bubble handling (may conflict with other addons)")
	enableChatBubbleHandlingCheckbox:SetChecked(UnitPlatesSettings.enableChatBubbleHandling)
	enableChatBubbleHandlingCheckbox.tooltip = "Enable chat bubble handling (may conflict with other addons)"
	enableChatBubbleHandlingCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.enableChatBubbleHandling=not UnitPlatesSettings.enableChatBubbleHandling
		--applyAllSettings()
	end)
	
	
	UnitPlatesOptionsFrame:Hide()
	
	LoadUPMinimapButton()
end