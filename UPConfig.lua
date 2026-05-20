local _G = getfenv(0)

SLASH_UNITPLATES1 = "/unitplates"
SLASH_UNITPLATES2 = "/up"

SlashCmdList["UNITPLATES"] = function(msg)
	--print("UnitPlates config is not available yet")
	UnitPlatesOptionsFrame:Show()
end

UnitPlatesOptionsFrame = CreateFrame("Frame", "UnitPlatesOptionsFrame", UIParent)

function UPConfigLoadUnitPlatesDefaultSettings()
	UnitPlatesSettings = {
		minimapIconPos = 0,
		smallerAuras = true,
		showBuffs=true,
		onlyYourBuffs=false,
		ignoredBuffNames = "name1,name2",
		showDebuffs=true,
		onlyYourDebuffs=false,
		ignoredDebuffNames = "name1,name2",
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
	setDefaultsButton:SetPoint("BOTTOM",0,0)
	setDefaultsButton:SetWidth(200)
	setDefaultsButton:SetHeight(40)
	setDefaultsButton:SetText("Set defaults & Reload")
	setDefaultsButton:SetScript("OnClick", function()
		UPConfigLoadUnitPlatesDefaultSettings()
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
	
	local smallerAurasCheckbox = CreateFrame("CheckButton", "smallerAurasCheckbox", scrollChild, "UICheckButtonTemplate")
	smallerAurasCheckbox:SetPoint("TOPLEFT",8,-24)
	getglobal(smallerAurasCheckbox:GetName() .. 'Text'):SetText("Smaller auras")
	smallerAurasCheckbox:SetChecked(UnitPlatesSettings.smallerAuras)
	smallerAurasCheckbox.tooltip = "Smaller auras"
	smallerAurasCheckbox:SetScript("OnClick", function()
		UnitPlatesSettings.smallerAuras=not UnitPlatesSettings.smallerAuras
		--applyAllSettings()
	end)
	
	local showBuffsCheckbox = CreateFrame("CheckButton", "showBuffsCheckbox", scrollChild, "UICheckButtonTemplate")
	showBuffsCheckbox:SetPoint("TOP", smallerAurasCheckbox, "BOTTOM", 0, -0)
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
	showOnlyYourBuffsCheckbox:Hide()
	
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
	ignoredBuffnamesInput:SetPoint("LEFT", ignoredBuffnamesTitle, "RIGHT", 0, 0)
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
	showDebuffsCheckbox:SetPoint("TOPLEFT", ignoredBuffnamesTitle, "BOTTOMLEFT", 0, -16)
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
	showOnlyYourDebuffsCheckbox:Hide()
	
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
	ignoredDebuffnamesInput:SetPoint("LEFT", ignoredDebuffnamesTitle, "RIGHT", 0, 0)
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
	
	
	UnitPlatesOptionsFrame:Hide()
end