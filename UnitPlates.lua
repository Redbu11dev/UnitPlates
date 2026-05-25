local addonIsLoaded = false
local playerEnteredWorld = false

---------------------------CONSTANTS

local spellSchoolColors = {
	[1] = {a = 1.00, r = 1.00, g = 1.00, b = 0.00}, -- Physical
	[2] = {a = 1.00, r = 1.00, g = 0.90, b = 0.50}, -- Holy
	[4] = {a = 1.00, r = 1.00, g = 0.50, b = 0.00}, -- Fire
	[8] = {a = 1.00, r = 0.30, g = 1.00, b = 0.30}, -- Nature
	[16] = {a = 1.00, r = 0.50, g = 1.00, b = 1.00}, -- Frost
	[20] = {a = 1.00, r = 0.50, g = 1.00, b = 1.00}, -- Frostfire
	[32] = {a = 1.00, r = 0.50, g = 0.50, b = 1.00}, -- Shadow
	[64] = {a = 1.00, r = 1.00, g = 0.50, b = 1.00} -- Arcane
}

local function getClassPos(class)
	if(class=="WARRIOR") then return 0,    0.25,    0,	0.25;	end
	if(class=="MAGE")    then return 0.25, 0.5,     0,	0.25;	end
	if(class=="ROGUE")   then return 0.5,  0.75,    0,	0.25;	end
	if(class=="DRUID")   then return 0.75, 1,       0,	0.25;	end
	if(class=="HUNTER")  then return 0,    0.25,    0.25,	0.5;	end
	if(class=="SHAMAN")  then return 0.25, 0.5,     0.25,	0.5;	end
	if(class=="PRIEST")  then return 0.5,  0.75,    0.25,	0.5;	end
	if(class=="WARLOCK") then return 0.75, 1,       0.25,	0.5;	end
	if(class=="PALADIN") then return 0,    0.25,    0.5,	0.75;	end
	return 0.25, 0.5, 0.5, 0.75	-- Returns empty next one, so blank
end

local slowUpdateTime, critUpdateTime, aurasUnitUpdateTime = 0.1, 0.01, 0.2

--SIZES
--make all sizes relative to UPConstants.nameplateHealthBarHeight
local UPConstants = {}
UPConstants.nameplateHealthBarHeight = 14
UPConstants.minimalOnePixel = UPConstants.nameplateHealthBarHeight / 16

UPConstants.nameplateHealthBarWidth = UPConstants.nameplateHealthBarHeight * 6.5
UPConstants.nameplateWidthGrayLevel = UPConstants.nameplateHealthBarHeight * 4.1
UPConstants.nameplatePowerBarHeight = UPConstants.nameplateHealthBarHeight / 2

UPConstants.nameFontSize = UPConstants.nameplateHealthBarHeight * 0.6875
UPConstants.healthPercentageFontSize = UPConstants.nameplateHealthBarHeight * 0.625
UPConstants.healthBigFontSize = UPConstants.nameplateHealthBarHeight * 0.625
UPConstants.powerFontSize = UPConstants.nameplateHealthBarHeight * 0.5
UPConstants.levelFontSize = UPConstants.nameplateHealthBarHeight * 0.625
UPConstants.castWarningNameFontSize = UPConstants.nameplateHealthBarHeight * 0.6875
UPConstants.castWarningDurationFontSize = UPConstants.nameplateHealthBarHeight * 0.5

UPConstants.nameplateArrowSize = UPConstants.nameplateHealthBarHeight * 1.875
UPConstants.nameplateRarityH = UPConstants.nameplateHealthBarHeight * 2.75
UPConstants.nameplateRarityW = UPConstants.nameplateHealthBarHeight * 2.625

UPConstants.questIconSize = UPConstants.nameplateHealthBarHeight * 1.1

UPConstants.petHappinessIconSize = UPConstants.nameplateHealthBarHeight * 1.4

UPConstants.combatIconSize = UPConstants.nameplateHealthBarHeight * 1.4

UPConstants.shootingIconSize = UPConstants.nameplateHealthBarHeight * 0.9

UPConstants.nameplateTypeIconSize = UPConstants.nameplateHealthBarHeight
UPConstants.nameplateClassIconSize = UPConstants.nameplateHealthBarHeight * 1.25

UPConstants.totemIconSize = UPConstants.nameplateHealthBarHeight * 2

UPConstants.raidIconSize = UPConstants.nameplateHealthBarHeight * 2

UPConstants.threatFrameSize = UPConstants.nameplateHealthBarHeight
UPConstants.threatFontSize = UPConstants.nameplateHealthBarHeight * 0.5

UPConstants.maxAuras = 80
UPConstants.maxAurasInRow = 5
UPConstants.auraIconOffset = 0.1 * UPConstants.minimalOnePixel

local castBarSizes = {
	cbheight = UPConstants.nameplateHealthBarHeight * 0.3125,
	shield = UPConstants.nameplateHealthBarHeight,
	icon = UPConstants.nameplateHealthBarHeight
 }

local combopointsSizes = {
	combopoints = UPConstants.nameplateHealthBarHeight * 0.5625,
	spacing = UPConstants.minimalOnePixel
}

--OFFSETS
local nameplateRarityXOffset = UPConstants.nameplateRarityW * 0.619

--COLORS
local glowColor = {.3, 0.7, 1, 1}
local hatedColor = {.7, 0.2, 0.1}
local neutralColor = {1, 0.8, 0}
local friendlyColor = {.2, 0.6, 0.1}
local tappedColor = {0.2352941176470588, 0.2274509803921569, 0.2352941176470588}
local playerColor = {.2, 0.5, 0.9}

local castBarColor = {.43, 0.47, 0.55, 1}
local castBarShieldColor = {.8, 0.1, 0.1, 1}

local combopointsColors = {
	full = {1, 0.224, 0.027}
}

local powerBarColors = {
	mana = {0, 0, 0.9, 0.99999779462814},
	energy = {1, 1, 0, 0.99999779462814},
	rage = {1, 0, 0, 0.99999779462814},
	rageDim = {0.5, 0, 0, 0.99999779462814}
}

local chatTextColors = {
    ["CHAT_MSG_SAY"] = {1.0, 1.0, 1.0, 0.99}, -- White
    ["CHAT_MSG_PARTY"] = {0.67, 0.67, 1.0, 0.99}, -- Light Blue
    ["CHAT_MSG_YELL"] = {1.0, 0.25, 0.25, 0.99}, -- Bright Red
    ["CHAT_MSG_MONSTER_SAY"] = {1.0, 1.0, 0.6, 0.99}, -- Pale Yellow
    ["CHAT_MSG_MONSTER_YELL"] = {1.0, 0.48, 0.0, 0.99}, -- Orange-Gold (Distinct from Say)
}

--FONT
--local mainFontPath = "Interface\\AddOns\\UnitPlates\\fonts\\francois.ttf"
local mainFontPath = "Interface\\AddOns\\UnitPlates\\fonts\\INTERNATIONAL_FRIZQT__.ttf"

---------------------------CONSTANTS END

--aura
local function HideAllAuras(kuiPlateFrame)
	kuiPlateFrame.unitAuras = {}
	for i = 1, UPConstants.maxAuras do
        kuiPlateFrame.aurasContainer.auraIcons[i]:Hide()
    end
end

local function GetHighestVisibleAuraFrame(kuiPlateFrame)
	local latestVisibleFrame = kuiPlateFrame.name

	for i = 1, UPConstants.maxAuras do
		if kuiPlateFrame.aurasContainer.auraIcons[i] then
			if kuiPlateFrame.aurasContainer.auraIcons[i]:IsShown() then
				latestVisibleFrame = kuiPlateFrame.aurasContainer.auraIcons[i]
			end
		else
			break
		end
	end

	return latestVisibleFrame
end

------------------------------------------------------------- Frame functions --
--required to set frame positions
local function SetFrameCenter(kuiPlateFrame)
	-- using CENTER breaks pixel-perfectness with oddly sized frames
	-- .. so we have to align frames manually.
	
	--overlap
	kuiPlateFrame.originalPlateFrame:SetWidth(1)
	kuiPlateFrame.originalPlateFrame:SetHeight(1)
	
	local w = kuiPlateFrame:GetWidth()
	local h = kuiPlateFrame:GetHeight()

	if kuiPlateFrame.isTrivial then
		kuiPlateFrame.x = math.floor((w / 2) - (UPConstants.nameplateWidthGrayLevel / 2))
		kuiPlateFrame.y = math.floor((h / 2) - (UPConstants.nameplateHealthBarHeight / 2))
	else
		kuiPlateFrame.x = math.floor((w / 2) - (UPConstants.nameplateHealthBarWidth / 2))
		kuiPlateFrame.y = math.floor((h / 2) - (UPConstants.nameplateHealthBarHeight / 2))
	end
end

local function ResetFrame(kuiPlateFrame, originalPlateFrame)
	kuiPlateFrame:SetWidth(originalPlateFrame:GetWidth())
	kuiPlateFrame:SetHeight(originalPlateFrame:GetHeight())
	SetFrameCenter(kuiPlateFrame)
	
	kuiPlateFrame.elapsed = 0
	kuiPlateFrame.critElap = 0
	kuiPlateFrame.aurasUpdateElapsed = 0
	
	--kuiPlateFrame:SetFrameLevel(0)
	kuiPlateFrame.glow:Hide() 
	kuiPlateFrame.glow2:Hide()
	originalPlateFrame.totem:Hide()
	kuiPlateFrame.isTarget = nil
	UPCoreFrameFadeRemoveFrame(kuiPlateFrame.castWarning)
	kuiPlateFrame.castWarning:Hide()
	HideAllAuras(kuiPlateFrame)
	kuiPlateFrame.guid = nil
end

local function OnFrameShow(originalPlateFrame)
	--print("OnFrameShow")
	local kuiPlateFrame = originalPlateFrame.kui
	ResetFrame(kuiPlateFrame, originalPlateFrame)
end

-------------------------------------------------------

local function UpdatePlate(kuiPlateFrame)
	--print("here1")
	kuiPlateFrame.originalPlateFrame.totem:Hide()
	kuiPlateFrame:Show()
	kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
	kuiPlateFrame.isTrivial = false
	kuiPlateFrame.guild:SetText("")
	
	if not kuiPlateFrame.originalPlateFrame.name then return nil end
	kuiPlateFrame.oldName = kuiPlateFrame.originalPlateFrame.name
	kuiPlateFrame.originalPlateFrame.name:Hide()
	
	if not kuiPlateFrame.originalPlateFrame.level then return nil end
	kuiPlateFrame.oldLevel = kuiPlateFrame.originalPlateFrame.level
	kuiPlateFrame.originalPlateFrame.level:Hide()
	
	-- print("here2")
	
	--raid icon
	--adjust aurcasContainer position
	if kuiPlateFrame.classIcon:IsShown() then
		kuiPlateFrame.aurasContainer:SetPoint("BOTTOM", kuiPlateFrame.name, "TOP", 0, UPConstants.nameplateClassIconSize / 2)
	else
		kuiPlateFrame.aurasContainer:SetPoint("BOTTOM", kuiPlateFrame.name, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	end
	
	if kuiPlateFrame.originalPlateFrame.raidIconRegion then
		kuiPlateFrame.originalPlateFrame.raidIconRegion:SetParent(kuiPlateFrame.originalPlateFrame)
		kuiPlateFrame.originalPlateFrame.raidIconRegion:SetWidth(UPConstants.raidIconSize)
		kuiPlateFrame.originalPlateFrame.raidIconRegion:SetHeight(UPConstants.raidIconSize)
		kuiPlateFrame.originalPlateFrame.raidIconRegion:ClearAllPoints()
		
		--kuiPlateFrame.originalPlateFrame.raidIconRegion:SetPoint("BOTTOM", GetHighestVisibleAuraFrame(kuiPlateFrame), "TOP", 0, 2 * UPConstants.minimalOnePixel)
		
		local auraFrame = GetHighestVisibleAuraFrame(kuiPlateFrame)
		
		-- 1. Get the Center X and Center Y of the aura frame
        local auraTopY = auraFrame:GetTop()
		if not auraTopY then
			auraTopY = 0
		end
		kuiPlateFrame.originalPlateFrame.raidIconRegion:SetPoint("CENTER", kuiPlateFrame.name, "CENTER", 0, 0) -- Align X center with nameplate
        kuiPlateFrame.originalPlateFrame.raidIconRegion:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, auraTopY + (2 * UPConstants.minimalOnePixel)) -- Align BOTTOM Y with screen coordinate
	end
	--raid icon end
	
	--own player
	local isMyPlayerInParty = GetNumPartyMembers() or GetNumPartyMembers()
	local myPlayerHasPetUI, myPlayerPetIsHunterPet = HasPetUI()
	local myGuildName, myGuildRankName, myGuildRankIndex = GetGuildInfo("player")
	--own player end
	
	--init data
	kuiPlateFrame.guid = kuiPlateFrame.originalPlateFrame:GetName(1)
	
	--local isWoWTranslateAvailable = WoWTranslate_API and WoWTranslate_API.IsAvailable()
	
	if kuiPlateFrame.bossIconRegion and kuiPlateFrame.bossIconRegion:IsVisible() then
		-- This unit is a Boss (it has the skull icon active)
		bossIconRegion:SetTexture(nil)
		kuiPlateFrame.isBoss = true
	end
	
	--print("UnitName(kuiPlateFrame.guid): "..tostring(UnitName(kuiPlateFrame.guid)))
	kuiPlateFrame.nameTextVariable = UnitName(kuiPlateFrame.guid)	
	
	kuiPlateFrame.originalPlateFrame.isTotem = UPApiIsTotem(kuiPlateFrame.nameTextVariable)
	
	kuiPlateFrame.guildTextVariable = UPApiGetGuildText(kuiPlateFrame.guid)
	kuiPlateFrame.levelNumber = UnitLevel(kuiPlateFrame.guid)
	kuiPlateFrame.isPlayer = UnitIsPlayer(kuiPlateFrame.guid)	
	kuiPlateFrame.isInCombat = UnitAffectingCombat(kuiPlateFrame.guid)
	kuiPlateFrame.class, kuiPlateFrame.race, kuiPlateFrame.gender = UPApiGetClassRaceGender(kuiPlateFrame.guid)
	kuiPlateFrame.classification = UnitClassification(kuiPlateFrame.guid)
	kuiPlateFrame.isPlusMob = UnitIsPlusMob(kuiPlateFrame.guid)
	kuiPlateFrame.creatureType = UPApiGetCreatureType(kuiPlateFrame.guid)	
	kuiPlateFrame.unitMaxPower = UnitManaMax(kuiPlateFrame.guid)
	if kuiPlateFrame.unitMaxPower > 0 then
		kuiPlateFrame.unitPower = UnitMana(kuiPlateFrame.guid)
		kuiPlateFrame.unitPowerType = UnitPowerType(kuiPlateFrame.guid)	
	else
		kuiPlateFrame.unitPower = 0
		kuiPlateFrame.unitPowerType = 0
	end
	kuiPlateFrame.isTarget = UPApiIsTarget(kuiPlateFrame.guid)
	kuiPlateFrame.levelDifficultyColor = UPApiGetLevelDifficultyColor(kuiPlateFrame.levelNumber)
	kuiPlateFrame.isGrayLevel = UPApiIsGrayLevel(kuiPlateFrame.levelNumber)
	kuiPlateFrame.isPet = UPApiIsPet(kuiPlateFrame.guid)
	kuiPlateFrame.isTapped = (UnitIsTapped(kuiPlateFrame.guid) and not (UnitIsTappedByPlayer(kuiPlateFrame.guid)))
	
	if kuiPlateFrame.isGrayLevel or kuiPlateFrame.isPet or kuiPlateFrame.creatureType == "CRITTER" then
		kuiPlateFrame.isTrivial = true
	end
	--init data end
	
	
	
	-- print("here3")
	
	
	--setGuild
	if kuiPlateFrame.guildTextVariable then
		local guildTranslation = UPCompatWoWTranslateGetCachedGuildTranslation(kuiPlateFrame.guildTextVariable)
		if guildTranslation and (guildTranslation ~= '') then
			kuiPlateFrame.guild:SetText("<"..guildTranslation.."*"..">")
		else
			kuiPlateFrame.guild:SetText("<"..kuiPlateFrame.guildTextVariable..">")
		end
	end
	--coloring
	if (kuiPlateFrame.isPlayer and myGuildName and (kuiPlateFrame.guildTextVariable == myGuildName)) then
		kuiPlateFrame.guild:SetTextColor(0,0.999,0,1)
	else
		kuiPlateFrame.guild:SetTextColor(1,1,1,1)
	end
	--setGuild end
	
	--setName
	local nameTranslation = UPCompatWoWTranslateGetCachedNameTranslation(kuiPlateFrame.nameTextVariable)
	if nameTranslation and (nameTranslation ~= '') then
		kuiPlateFrame.name:SetText(nameTranslation.."*")
	else
		kuiPlateFrame.name:SetText(kuiPlateFrame.nameTextVariable)
	end
	
	kuiPlateFrame.name:SetTextColor(1,1,1,1)
	if (kuiPlateFrame.guild:GetText() == nil or kuiPlateFrame.guild:GetText() == '') then
		kuiPlateFrame.name:SetPoint("BOTTOM", kuiPlateFrame.health, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	else
		kuiPlateFrame.name:SetPoint("BOTTOM", kuiPlateFrame.guild, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	end
	--setName end
	
	--level
	if kuiPlateFrame.levelNumber > 0 then
		kuiPlateFrame.level:SetText(kuiPlateFrame.oldLevel:GetText())
		kuiPlateFrame.level:SetTextColor(kuiPlateFrame.oldLevel:GetTextColor())
	else
		if kuiPlateFrame.isBoss then
			kuiPlateFrame.level:SetText("??")
		else
			kuiPlateFrame.level:SetText("??")
		end
		kuiPlateFrame.level:SetTextColor(kuiPlateFrame.levelDifficultyColor.r, kuiPlateFrame.levelDifficultyColor.g, kuiPlateFrame.levelDifficultyColor.b)
	end
	kuiPlateFrame.level:Show()
	--level end
	
	--RARITY
	if (kuiPlateFrame.isPlayer) then
		kuiPlateFrame.rarityIcon:Hide()
		kuiPlateFrame.rarityIconR:Hide()
	else
		kuiPlateFrame.rarityIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_elite")
		kuiPlateFrame.rarityIconR.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_elite")
		if kuiPlateFrame.classification == "elite" then
			kuiPlateFrame.rarityIcon.icon:SetVertexColor(1, 1, 0, 1)
			kuiPlateFrame.rarityIcon:Show()
			kuiPlateFrame.rarityIconR.icon:SetVertexColor(1, 1, 0, 1)
			kuiPlateFrame.rarityIconR:Show()
		elseif kuiPlateFrame.classification == "rareelite" then
			kuiPlateFrame.rarityIcon.icon:SetVertexColor(1, 1, 1, 1)
			kuiPlateFrame.rarityIcon:Show()
			kuiPlateFrame.rarityIconR.icon:SetVertexColor(1, 1, 1, 1)
			kuiPlateFrame.rarityIconR:Show()
		elseif kuiPlateFrame.classification == "rare" then
			kuiPlateFrame.rarityIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_rare")
			kuiPlateFrame.rarityIconR.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_rare")
			kuiPlateFrame.rarityIcon.icon:SetVertexColor(1, 1, 1, 1)
			kuiPlateFrame.rarityIcon:Show()
			kuiPlateFrame.rarityIconR.icon:SetVertexColor(1, 1, 1, 1)
			kuiPlateFrame.rarityIconR:Show()
		elseif (kuiPlateFrame.classification == "boss") or kuiPlateFrame.isBoss then
		--TODO should set boss icon?
			if kuiPlateFrame.isPlusMob then
				kuiPlateFrame.rarityIcon.icon:SetVertexColor(0.5, 0, 0, 1)
				kuiPlateFrame.rarityIcon:Show()
				kuiPlateFrame.rarityIconR.icon:SetVertexColor(0.5, 0, 0, 1)
				kuiPlateFrame.rarityIconR:Show()
			else
				kuiPlateFrame.rarityIcon:Hide()
				kuiPlateFrame.rarityIconR:Hide()
			end
		else
			kuiPlateFrame.rarityIcon:Hide()
			kuiPlateFrame.rarityIconR:Hide()
		end
	end
	--RARITY END
	
	--combat icon
	if kuiPlateFrame.isInCombat then
		kuiPlateFrame.combatIcon:Show()
	else
		kuiPlateFrame.combatIcon:Hide()
	end
	--
	
	--pet happiness
	if (myPlayerHasPetUI and myPlayerPetIsHunterPet and kuiPlateFrame.guildTextVariable and string.find(kuiPlateFrame.guildTextVariable, UnitName("player").."'s Pet")) then
		local petHappiness, petDamagePercentage, petLoyaltyRate = GetPetHappiness()
		
		if (petHappiness == 1) then
			kuiPlateFrame.petHappiness.icon:SetTexCoord(0.375, 0.5625, 0, 0.359375)
			kuiPlateFrame.combatIcon:SetPoint("LEFT", kuiPlateFrame.petHappiness, "RIGHT", -0, -0)
			kuiPlateFrame.petHappiness:Show()
		elseif (petHappiness == 2) then
			kuiPlateFrame.petHappiness.icon:SetTexCoord(0.1875, 0.375, 0, 0.359375)
			kuiPlateFrame.combatIcon:SetPoint("LEFT", kuiPlateFrame.petHappiness, "RIGHT", -0, -0)
			kuiPlateFrame.petHappiness:Show()
		elseif (petHappiness == 3) then
			-- kuiPlateFrame.petHappiness.icon:SetTexCoord(0, 0.1875, 0, 0.359375)
			-- kuiPlateFrame.combatIcon:SetPoint("LEFT", kuiPlateFrame.petHappiness, "RIGHT", -0, -0)
			-- kuiPlateFrame.petHappiness:Show()
			kuiPlateFrame.petHappiness:Hide()
		end
	else
		kuiPlateFrame.petHappiness:Hide()
	end
	--pet happiness end
	
	--healthbar with
	if kuiPlateFrame.isTrivial then
		-- if not UnitAffectingCombat("player") then
			-- --can't call this while in combat
			-- kuiPlateFrame.originalPlateFrame:SetWidth(UPConstants.nameplateWidthGrayLevel)
			-- kuiPlateFrame.originalPlateFrame:SetHeight(UPConstants.nameplateHealthBarHeight)
		-- end
		kuiPlateFrame.originalPlateFrame:SetWidth(UPConstants.nameplateWidthGrayLevel)
		kuiPlateFrame.originalPlateFrame:SetHeight(UPConstants.nameplateHealthBarHeight)
		SetFrameCenter(kuiPlateFrame)
		kuiPlateFrame.health:SetWidth(UPConstants.nameplateWidthGrayLevel)
		kuiPlateFrame.health:SetHeight(UPConstants.nameplateHealthBarHeight)
		kuiPlateFrame.health:SetPoint("BOTTOMLEFT", kuiPlateFrame.x, kuiPlateFrame.y)
		kuiPlateFrame.power:SetWidth(UPConstants.nameplateWidthGrayLevel)
		kuiPlateFrame.castWarning.bar:SetWidth(UPConstants.nameplateWidthGrayLevel)
		kuiPlateFrame.aurasContainer:SetWidth(UPConstants.nameplateWidthGrayLevel)
	else
		-- if not UnitAffectingCombat("player") then
			-- --can't call this while in combat
			-- kuiPlateFrame.originalPlateFrame:SetWidth(UPConstants.nameplateHealthBarWidth)
			-- kuiPlateFrame.originalPlateFrame:SetHeight(UPConstants.nameplateHealthBarHeight)
		-- end
		kuiPlateFrame.originalPlateFrame:SetWidth(UPConstants.nameplateHealthBarWidth)
		kuiPlateFrame.originalPlateFrame:SetHeight(UPConstants.nameplateHealthBarHeight)
		SetFrameCenter(kuiPlateFrame)
		kuiPlateFrame.health:SetWidth(UPConstants.nameplateHealthBarWidth)
		kuiPlateFrame.health:SetHeight(UPConstants.nameplateHealthBarHeight)
		kuiPlateFrame.health:SetPoint("BOTTOMLEFT", kuiPlateFrame.x, kuiPlateFrame.y)
		kuiPlateFrame.power:SetWidth(UPConstants.nameplateHealthBarWidth)
		kuiPlateFrame.castWarning.bar:SetWidth(UPConstants.nameplateHealthBarWidth)
		kuiPlateFrame.aurasContainer:SetWidth(UPConstants.nameplateHealthBarWidth)
	end
	--healthbar with end
	
	--health color
	local r, g, b = kuiPlateFrame.oldHealth:GetStatusBarColor()	
	kuiPlateFrame.health.r, kuiPlateFrame.health.g, kuiPlateFrame.health.b = r, g, b
	if g > 0.9 and r == 0 and b == 0 then
		-- friendly NPC
		r, g, b = unpack(friendlyColor)
	elseif b > 0.9 and r == 0 and g == 0 then
		-- friendly player
		r, g, b = unpack(playerColor)
	elseif r > 0.9 and g == 0 and b == 0 then
		-- enemy NPC
		r, g, b = unpack(hatedColor)
	elseif (r + g) > 1.8 and b == 0 then
		-- neutral NPC
		r, g, b = unpack(neutralColor)
	elseif r < 0.6 and (r + g) == (r + b) then
		-- tapped NPC
		r, g, b = unpack(tappedColor)
	else
		-- enemy player, use default UI colour
	end
	kuiPlateFrame.health:SetStatusBarColor(r, g, b)
	--health color end
	
	--health percentage
	local hpPercent = math.floor(kuiPlateFrame.health.percent)
	if hpPercent < 100 then
		kuiPlateFrame.health.percentage:SetText(math.floor(kuiPlateFrame.health.percent).."%")
	else
		kuiPlateFrame.health.percentage:SetText("")
	end
	--health percentage
	
	--update health
	kuiPlateFrame.health.min, kuiPlateFrame.health.max = kuiPlateFrame.oldHealth:GetMinMaxValues()
	kuiPlateFrame.health.curr = curval or kuiPlateFrame.oldHealth:GetValue()
	kuiPlateFrame.health.percent = 100 * kuiPlateFrame.health.curr / kuiPlateFrame.health.max
	kuiPlateFrame.health:SetMinMaxValues(kuiPlateFrame.health.min, kuiPlateFrame.health.max)
	kuiPlateFrame.health:SetValue(kuiPlateFrame.health.curr)
	if UPCoreNum(kuiPlateFrame.health.max) == 100 then
		--most likely it is unknown hp
		--try to get from MobHealth
		local current, max = UPCompatGetHealthFromMobHealth(kuiPlateFrame.guid)
		
		if not current then
			--try shaguTweaks fallback
			current, max = UPCompatGetHealthFromShaguTweaks(kuiPlateFrame.guid)
		end
		
		if current then
			kuiPlateFrame.health.p:SetText(UPCoreNum(tonumber(string.format("%d", current))))
		else
			--most likely it is unknown hp
			kuiPlateFrame.health.p:SetText(UPCoreNum(kuiPlateFrame.health.curr).."%")
		end	
	else
		--most likely has real hp
		kuiPlateFrame.health.p:SetText(UPCoreNum(kuiPlateFrame.health.curr))
	end
	--update health end
	
	--power
	if kuiPlateFrame.unitMaxPower > 0 then		
		-- print("----------unitPowerType: "..kuiPlateFrame.unitPowerType)
		-- print("----------unitMaxPower: "..kuiPlateFrame.unitMaxPower)
		-- print("----------unitPower: "..unitPower)
		kuiPlateFrame.power.text:SetText(string.format("%s", UPCoreAbbreviate(kuiPlateFrame.unitPower)))
	
		if kuiPlateFrame.unitPowerType == 0 then
			kuiPlateFrame.power:SetStatusBarColor(unpack(powerBarColors.mana))
		elseif kuiPlateFrame.unitPowerType == 1 then
			kuiPlateFrame.power:SetStatusBarColor(unpack(powerBarColors.rage))
		elseif kuiPlateFrame.unitPowerType == 2 or kuiPlateFrame.unitPowerType == 3 then
			kuiPlateFrame.power:SetStatusBarColor(unpack(powerBarColors.energy))
		else
			kuiPlateFrame.power:SetStatusBarColor(unpack(powerBarColors.energy))
		end
		
		kuiPlateFrame.power:SetMinMaxValues(0, kuiPlateFrame.unitMaxPower)
		
		if kuiPlateFrame.unitPowerType == 1 and kuiPlateFrame.unitPower < 1 then
			kuiPlateFrame.power:SetValue(kuiPlateFrame.unitMaxPower)
			kuiPlateFrame.power:SetStatusBarColor(unpack(powerBarColors.rageDim))
		else
			kuiPlateFrame.power:SetValue(kuiPlateFrame.unitPower)
		end
		kuiPlateFrame.power:Show()
	else
		kuiPlateFrame.power:Hide()
	end
	--power end
	
	--class, race, gender
	if kuiPlateFrame.isPlayer then
		if kuiPlateFrame.class then
			local classr, classl, classt, classb = getClassPos(string.upper(kuiPlateFrame.class))
			kuiPlateFrame.classIcon.icon:SetTexCoord(classr, classl, classt, classb)
			kuiPlateFrame.classIcon:Show()
		else
			--empty
			kuiPlateFrame.classIcon:Hide()
		end
		
		--set gender icon
		if kuiPlateFrame.gender and kuiPlateFrame.race then
			if kuiPlateFrame.gender == 3 then
				kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\races\\"..kuiPlateFrame.race.."_female.tga")
			else
				kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\races\\"..kuiPlateFrame.race.."_male.tga")
			end
		else
			--empty
			kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
		end
	else
		kuiPlateFrame.classIcon:Hide()
	end
	--class, race, gender end
	
	--set creature type
	if not kuiPlateFrame.isPlayer then
		if kuiPlateFrame.creatureType then
			--print("creatureType: "..kuiPlateFrame.creatureType)
			local success = kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\creaturetypes\\"..kuiPlateFrame.creatureType..".tga")
			if not success then
				local success = kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\creaturetypes\\UNKNOWN.tga")
			end
		else
			--empty
			kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
		end
	end
	--set creature type end
	
	--tapped
	if kuiPlateFrame.isTapped then
		--print("----------name3: "..kuiPlateFrame.guid)
		-- tapped NPC
		local rt, gt, bt = unpack(tappedColor)
		kuiPlateFrame.health:SetStatusBarColor(tr, gt, bt)
	else
		--not tapped
		--gotta set normal color?
	end
	--tapped end
	
	--combo points update
	if kuiPlateFrame.isTarget then
		kuiPlateFrame.combopoints.points = GetComboPoints("player", "target")
		if not kuiPlateFrame.combopoints.points or kuiPlateFrame.combopoints.points < 1 then
			kuiPlateFrame.combopoints:Hide()
		else
			kuiPlateFrame.combopoints.color = combopointsColors.full
			for i = 1, 5 do
				if i <= kuiPlateFrame.combopoints.points then
					kuiPlateFrame.combopoints[i]:SetAlpha(1)
				else
					kuiPlateFrame.combopoints[i]:SetAlpha(.3)
				end
				kuiPlateFrame.combopoints[i]:SetVertexColor(unpack(kuiPlateFrame.combopoints.color))
			end
			kuiPlateFrame.combopoints:Show()
		end
	else
		kuiPlateFrame.combopoints.points = nil
		kuiPlateFrame.combopoints:Hide()
	end
	--combo points update end
	
	--mouseover
	if kuiPlateFrame.originalPlateFrame.isInMouseOver then
		kuiPlateFrame.originalPlateFrame:SetFrameStrata("LOW")
		-- kuiPlateFrame.name:SetTextColor(1,1,0,1)
		-- kuiPlateFrame.guild:SetTextColor(1,1,0,1)
	else
		kuiPlateFrame.originalPlateFrame:SetFrameStrata("BACKGROUND")
		-- kuiPlateFrame.name:SetTextColor(1,1,0,1)
		-- kuiPlateFrame.guild:SetTextColor(1,1,0,1)
	end
	--mouseover end
	
	--target
	if kuiPlateFrame.isTarget then
		kuiPlateFrame:SetFrameStrata("LOW")
		kuiPlateFrame.glow:Show() 
		kuiPlateFrame.glow2:Show()
		kuiPlateFrame.originalPlateFrame.totem.glow:Show()
		kuiPlateFrame.originalPlateFrame.totem.glow2:Show()
		
		-- kuiPlateFrame.health:SetBackdropColor(unpack(glowColor))
		-- kuiPlateFrame.power:SetBackdropColor(unpack(glowColor))
		-- kuiPlateFrame.typeIcon:SetBackdropColor(unpack(glowColor))
		kuiPlateFrame.health:SetBackdropBorderColor(unpack(glowColor))
		kuiPlateFrame.power:SetBackdropBorderColor(unpack(glowColor))
		kuiPlateFrame.typeIcon:SetBackdropBorderColor(unpack(glowColor))
		
		-- kuiPlateFrame.health.bgOffsetFrame:SetBackdropBorderColor(unpack(glowColor)) -- Very dark grey subtle border
		-- kuiPlateFrame.health.overlayMask:SetBackdropBorderColor(unpack(glowColor)) -- Black masking border
		
		--kuiPlateFrame:SetFrameLevel(3)
	else
		kuiPlateFrame.glow:Hide() 
		kuiPlateFrame.glow2:Hide()
		kuiPlateFrame.originalPlateFrame.totem.glow:Hide()
		kuiPlateFrame.originalPlateFrame.totem.glow2:Hide()
		
		-- kuiPlateFrame.health:SetBackdropColor(0, 0, 0, 1)
		-- kuiPlateFrame.power:SetBackdropColor(0, 0, 0, 1)
		-- kuiPlateFrame.typeIcon:SetBackdropColor(0, 0, 0, 1)
		kuiPlateFrame.health:SetBackdropBorderColor(0, 0, 0, 1)
		kuiPlateFrame.power:SetBackdropBorderColor(0, 0, 0, 1)
		kuiPlateFrame.typeIcon:SetBackdropBorderColor(0, 0, 0, 1)
		
		-- kuiPlateFrame.health.bgOffsetFrame:SetBackdropBorderColor(0.1, 0.1, 0.1, 1) -- Very dark grey subtle border
		-- kuiPlateFrame.health.overlayMask:SetBackdropBorderColor(0, 0, 0, 1) -- Black masking border
		
		--kuiPlateFrame:SetFrameLevel(0)
	end
	--target end
	
	--shooting range icon
	if kuiPlateFrame.isTarget and UnitCanAttack("player", "target") then
		if UPApiIsTargetInShootingDistance() then
			kuiPlateFrame.shootingIcon:Show()
		else
			kuiPlateFrame.shootingIcon:Hide()
		end
	else
		kuiPlateFrame.shootingIcon:Hide()
	end
	--shooting range icon end
	
	--TOTEM
	if kuiPlateFrame.originalPlateFrame.isTotem then
		kuiPlateFrame.originalPlateFrame.totem.icon:SetTexture(UpApiGetTotemIconForName(kuiPlateFrame.nameTextVariable))
		local totemR,totemG,totemB,totemA = kuiPlateFrame.health:GetStatusBarColor()
		kuiPlateFrame.originalPlateFrame.totem:SetBackdropColor(totemR,totemG,totemB,totemA)
		kuiPlateFrame.originalPlateFrame.totem:SetBackdropBorderColor(totemR,totemG,totemB,totemA)
		
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetBackdropColor(totemR,totemG,totemB,totemA) -- Dark backdrop fill
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetBackdropBorderColor(totemR,totemG,totemB,totemA) -- Matte grey border rim
		kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetBackdropBorderColor(0, 0, 0, 1) -- Pure black mask to match layouts
		
		kuiPlateFrame.originalPlateFrame.totem:Show()
		kuiPlateFrame:Hide()
	else
		kuiPlateFrame.originalPlateFrame.totem:Hide()
		kuiPlateFrame:Show()
	end
	--if totemIcon then return nil end
	--TOTEM end
	
	--cast warning bar simulation
	local currTimeMillis = GetTime()*1000
	local spellName, spellNameSecondary, spellDisplayName, spellIcon, spellStartTimeMillis, spellEndTimeMillis, spellIsTradeSkill, isChannel = UPApiUnitCastingInfo(kuiPlateFrame.guid)
	-- local spellName = nil
	if kuiPlateFrame.guid then
		if (spellName and ((spellEndTimeMillis - currTimeMillis) > 0)) then
			-- print("spellName: "..spellName)
			-- print("spellNameSecondary: "..spellNameSecondary)
			-- print("spellDisplayName: "..spellDisplayName)
			-- print("spellIcon: "..spellIcon)
			-- print("spellStartTimeMillis: "..spellStartTimeMillis)
			-- print("spellEndTimeMillis: "..spellEndTimeMillis)
			-- print("spellIsTradeSkill: ".."boolean")
			-- print("spellCastID: "..spellCastID)
			-- print("spellInterrupt: ".."boolean")
			
			--something is being cast
			kuiPlateFrame.castWarning.currentValue = spellEndTimeMillis - currTimeMillis
			kuiPlateFrame.castWarning.startTime = spellStartTimeMillis
			kuiPlateFrame.castWarning.endTime = spellEndTimeMillis
			kuiPlateFrame.castWarning.castTime = kuiPlateFrame.castWarning.endTime-kuiPlateFrame.castWarning.startTime
			
			-- print("guid startTime raw: "..spellStartTimeMillis)
			-- print("guid endTime raw: "..spellEndTimeMillis)
			
			local col = {r = 1, g = 1, b = 1}
			kuiPlateFrame.castWarning.text:SetTextColor(col.r, col.g, col.b)
			kuiPlateFrame.castWarning.text:SetText("["..spellName.."]")
			kuiPlateFrame.castWarning.icon.tex:SetTexture(spellIcon)
			
			kuiPlateFrame.castWarning.curr:SetText(string.format("%.1f", kuiPlateFrame.castWarning.currentValue/1000))
			kuiPlateFrame.castWarning.bar:SetMinMaxValues(0, kuiPlateFrame.castWarning.castTime)
			local progress = kuiPlateFrame.castWarning.castTime - kuiPlateFrame.castWarning.currentValue -- Fills (e.g., 0 -> 3000)
			if isChannel then
				progress = kuiPlateFrame.castWarning.currentValue -- Drains (e.g., 3000 -> 0)
			end
			kuiPlateFrame.castWarning.bar:SetValue(progress)
			
			-- Move the Spark
			local barWidth = kuiPlateFrame.castWarning.bar:GetWidth()
			if barWidth > 0 and kuiPlateFrame.castWarning.castTime > 0 then
				-- 2. Calculate the progress ratio (0 to 1)
				-- For a standard cast (filling up):
				local ratio = progress / kuiPlateFrame.castWarning.castTime
				
				-- 3. Calculate the pixel offset
				local sparkOffset = ratio * barWidth
				
				-- 4. APPLY THE MOVEMENT
				kuiPlateFrame.castWarning.spark:ClearAllPoints() -- CRITICAL for 1.12
				kuiPlateFrame.castWarning.spark:SetPoint("CENTER", kuiPlateFrame.castWarning.bar, "LEFT", sparkOffset, 0)
				
				--print("Ratio: "..ratio.." Offset: "..sparkOffset)
				
				-- 5. Optional: Hide spark if it's at the very beginning or end
				if ratio <= 0.01 or ratio >= 0.99 then
					kuiPlateFrame.castWarning.spark:Hide()
				else
					kuiPlateFrame.castWarning.spark:Show()
				end
			end
			
			if not spellInterrupt then
				kuiPlateFrame.castWarning.bar:SetStatusBarColor(unpack(castBarColor))	
				kuiPlateFrame.castWarning.shield:Hide()
			else
				kuiPlateFrame.castWarning.bar:SetStatusBarColor(unpack(castBarShieldColor))
				kuiPlateFrame.castWarning.shield:Show()
			end
			
			kuiPlateFrame.castWarning:Show()
			-- print("guid castTime: "..kuiPlateFrame.castWarning.castTime.." / ".."current: "..kuiPlateFrame.castWarning.castTime-kuiPlateFrame.castWarning.currentValue)
		else
			--assume nothing is being cast
			kuiPlateFrame.castWarning.startTime = 0
			kuiPlateFrame.castWarning.endTime = 0
			
			if kuiPlateFrame.castWarning.endTime > currTimeMillis then
				kuiPlateFrame.castWarning.currentValue = kuiPlateFrame.castWarning.endTime - currTimeMillis
				
				kuiPlateFrame.castWarning.curr:SetText(string.format("%.1f", kuiPlateFrame.castWarning.currentValue/1000))
				kuiPlateFrame.castWarning.bar:SetMinMaxValues(0, kuiPlateFrame.castWarning.castTime)
				kuiPlateFrame.castWarning.bar:SetValue(kuiPlateFrame.castWarning.castTime - kuiPlateFrame.castWarning.currentValue)
				
				kuiPlateFrame.castWarning.bar:SetStatusBarColor(unpack(castBarColor))	
				kuiPlateFrame.castWarning.shield:Hide()
				
			end
			if (kuiPlateFrame.castWarning:IsShown() and (kuiPlateFrame.castWarning.castTime > 0) and (currTimeMillis > kuiPlateFrame.castWarning.endTime)) then
				kuiPlateFrame.castWarning.castTime = 0
				kuiPlateFrame.castWarning:Hide()
				kuiPlateFrame.castWarning.spark:ClearAllPoints() -- CRITICAL for 1.12
				kuiPlateFrame.castWarning.spark:SetPoint("CENTER", kuiPlateFrame.castWarning.bar, "LEFT", 0, 0)
			end
		end
	else
		if kuiPlateFrame.castWarning.endTime > currTimeMillis then
			kuiPlateFrame.castWarning.currentValue = kuiPlateFrame.castWarning.endTime - currTimeMillis
			
			kuiPlateFrame.castWarning.curr:SetText(string.format("%.1f", kuiPlateFrame.castWarning.currentValue/1000))
			kuiPlateFrame.castWarning.bar:SetMinMaxValues(0, kuiPlateFrame.castWarning.castTime)
			kuiPlateFrame.castWarning.bar:SetValue(kuiPlateFrame.castWarning.castTime-kuiPlateFrame.castWarning.currentValue)
			
			kuiPlateFrame.castWarning.bar:SetStatusBarColor(unpack(castBarColor))	
			kuiPlateFrame.castWarning.shield:Hide()
			
			-- print("normal castTime: "..kuiPlateFrame.castWarning.castTime.." / ".."current: "..kuiPlateFrame.castWarning.castTime-kuiPlateFrame.castWarning.currentValue)
		end
		if (kuiPlateFrame.castWarning:IsShown() and (kuiPlateFrame.castWarning.castTime > 0) and (currTimeMillis > kuiPlateFrame.castWarning.endTime)) then
			kuiPlateFrame.castWarning.castTime = 0
			kuiPlateFrame.castWarning:Hide()
			kuiPlateFrame.castWarning.spark:ClearAllPoints() -- CRITICAL for 1.12
			kuiPlateFrame.castWarning.spark:SetPoint("CENTER", kuiPlateFrame.castWarning.bar, "LEFT", 0, 0)
		end
	end
	--cast warning bar simulation end
	
	--THREAT
	--if (guid and (not kuiPlateFrame.friend)) then
	-- if (kuiPlateFrame.guid) then
		-- -- local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", guid)
		-- -- if threatpct then
			-- -- local p = threatpct / 100
        
			-- -- -- Interpolate: StartValue + (EndValue - StartValue) * Ratio
			-- -- local r = 0.2 + (0.7 - 0.2) * p
			-- -- local g = 0.6 + (0.2 - 0.6) * p
			-- -- local b = 0.1 -- Both start and end at 0.1		
		
			-- -- kuiPlateFrame.threat.text:SetTextColor(r, g, b, 1)
			-- -- kuiPlateFrame.threat.text:SetText(string.format("%d", threatpct).."%")
			-- -- kuiPlateFrame.threat.text:Show()
		-- -- else
			-- -- kuiPlateFrame.threat.text:Hide()
		-- -- end
		-- local threatPercentage = UPThreatLibGetMyThreatPercentage(kuiPlateFrame.guid)
		-- kuiPlateFrame.threat:SetText(string.format("%d", threatPercentage).."%")
		-- kuiPlateFrame.threat:Show()
	-- else
		-- kuiPlateFrame.threat:Hide()
	-- end
	
	if (not kuiPlateFrame.isPlayer) and kuiPlateFrame.isInCombat and (not UnitIsFriend("player", kuiPlateFrame.guid)) and UPApiIsUnitTargetingMe(kuiPlateFrame.guid) then
		kuiPlateFrame.name:SetTextColor(0.9,0,0,1)
		kuiPlateFrame.guild:SetTextColor(0.9,0,0,1)
		kuiPlateFrame.health:SetStatusBarColor(0.85,0,0,1)
		kuiPlateFrame.health:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar")
	else
		kuiPlateFrame.health:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar4")
	end
	
	--THREAT END
	
	--PARTY/RAID
	if kuiPlateFrame.isPlayer then
		if UnitInParty(kuiPlateFrame.guid) then
		--if true then
			--is in party
			kuiPlateFrame.name:SetTextColor(0.4, 0.6, 1, 0.99999779462814)
			if not (kuiPlateFrame.guildTextVariable == myGuildName) then
				kuiPlateFrame.guild:SetTextColor(0.4, 0.6, 1, 0.99999779462814)
			end
			kuiPlateFrame.health:SetStatusBarColor(0.4, 0.6, 1, 0.99999779462814)
			--kuiPlateFrame.health:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar8")
			
			--UPApiIsPartyLeader(guid)
		elseif UnitInRaid(kuiPlateFrame.guid) then
		--elseif true then
			--not in party but in raid
			--0.85, 0.55, 0.25 --another option
			kuiPlateFrame.name:SetTextColor(0.85, 0.45, 0.15, 0.99999779462814)
			if not (kuiPlateFrame.guildTextVariable == myGuildName) then
				kuiPlateFrame.guild:SetTextColor(0.85, 0.45, 0.15, 0.99999779462814)
			end
			kuiPlateFrame.health:SetStatusBarColor(0.85, 0.45, 0.15, 0.99999779462814)
			
			--UPApiIsRaidLeader(guid)
			--UPApiIsRaidAssistant(guid)
		else
			--defaults
		end
	end
	--PARTY/RAID END
	
	--PVP SITUATION
		--add faction icon
	--PVP SITUATION END
	
	--AURA POLLING
	if kuiPlateFrame.aurasUpdateElapsed <= 0 then
		kuiPlateFrame.aurasUpdateElapsed = aurasUnitUpdateTime
		--print("here")
		
		ignoredBuffNames = {}
		for word in string.gfind(UnitPlatesSettings.ignoredBuffNames, '([^,]+)') do
			table.insert(ignoredBuffNames, UPCoreTrimString(word))
		end
		
		ignoredDebuffNames = {}
		for word in string.gfind(UnitPlatesSettings.ignoredDebuffNames, '([^,]+)') do
			table.insert(ignoredDebuffNames, UPCoreTrimString(word))
		end
		
		--print("here")
		local polledUnitAuras = UpApiGetUnitAuras(
			kuiPlateFrame.guid,
			UnitPlatesSettings.showBuffs,
			UnitPlatesSettings.onlyYourBuffs,
			UnitPlatesSettings.showDebuffs,
			UnitPlatesSettings.onlyYourDebuffs,
			ignoredBuffNames,
			ignoredDebuffNames
		)
		if polledUnitAuras then
			kuiPlateFrame.unitAuras = polledUnitAuras
		else
			--we don't know if it's the same nameplate?
			--kuiPlateFrame.unitAuras = {}
		end
	end
	--AURA POLLING END
end

-- stuff that needs to be updated every frame
local function OnFrameUpdate(originalPlateFrame, e)
	local kuiPlateFrame = originalPlateFrame.kui
	kuiPlateFrame.elapsed = kuiPlateFrame.elapsed - e
	kuiPlateFrame.critElap = kuiPlateFrame.critElap - e
	kuiPlateFrame.aurasUpdateElapsed = kuiPlateFrame.aurasUpdateElapsed - e
	
	------------------------------------------------------------------- Alpha --
	kuiPlateFrame.defaultAlpha = originalPlateFrame:GetAlpha()
	kuiPlateFrame.currentAlpha = 1
	if UnitExists("target") and (not kuiPlateFrame.isTarget) then
		kuiPlateFrame.currentAlpha = 0.6
	end	
	--IMPORTANT - DISABLES NON_TARGETED PLATE TRANSPARENCY
	kuiPlateFrame:SetAlpha(kuiPlateFrame.currentAlpha)
	
	------------------------------------------------------------------ Fading --
	-- call delayed updates
	
	if kuiPlateFrame.critElap <= 0 then
		kuiPlateFrame.critElap = critUpdateTime
		
		UpdatePlate(kuiPlateFrame)
	end	
	
	if kuiPlateFrame.elapsed <= 0 then
		kuiPlateFrame.elapsed = slowUpdateTime
		
		--pfquest compatibility
		if not kuiPlateFrame.isPlayer then
			local icon = UPCompatPfQuestQuestObjectives[kuiPlateFrame.nameTextVariable]
			if icon then
				kuiPlateFrame.questIcon.icon:SetTexture(icon)
				kuiPlateFrame.questIcon:Show()
			else
				kuiPlateFrame.questIcon:Hide()
			end
		else
			kuiPlateFrame.questIcon:Hide()
		end
		--
	end
	
	
	if MouseIsOver(kuiPlateFrame.health) or MouseIsOver(kuiPlateFrame.typeIcon) or MouseIsOver(kuiPlateFrame.power) or MouseIsOver(originalPlateFrame.totem) then
		kuiPlateFrame.originalPlateFrame.isInMouseOver = true
		--print("MouseIsOver")
		--SetMouseoverUnit(kuiPlateFrame.guid)
		if kuiPlateFrame.guid and UnitCanAttack("player", kuiPlateFrame.guid) then
			--print("can attack")
			SetCursor("ATTACK_CURSOR")
			--set right click attack action?
		end
		if (kuiPlateFrame.isTarget) and UnitCanAttack("player", "target") then
			--print("can attack")
			SetCursor("ATTACK_CURSOR")
			--set right click attack action?
		end
		
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnit(kuiPlateFrame.guid)
		GameTooltip:Show()
	else
		-- --SetMouseoverUnit()
		kuiPlateFrame.originalPlateFrame.isInMouseOver = false
	end
end

-----------PLATE CREATION
local function InitFrame(originalPlateFrame)
	-- originalPlateFrame.variables = {
		-- guid = nil,
		-- name = nil,
		-- level = nil,
		-- isTotem = nil,
		-- isPlayer = nil,
		-- isBoss = nil,
		-- isTrivial = nil,
	-- }


	-- container for kui objects!
	originalPlateFrame.kui = CreateFrame("Frame", nil, originalPlateFrame)
	local kuiPlateFrame = originalPlateFrame.kui

	kuiPlateFrame.fontObjects = {}

	-- fetch default ui's objects
	--local healthBar, castBar = originalPlateFrame:GetChildren()
	--local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = originalPlateFrame:GetRegions()
	
	--local healthBar = originalPlateFrame.healthbar
	--local castBar = originalPlateFrame.castBar
	local healthBar, castBar = originalPlateFrame:GetChildren()
	
	--local nameTextRegion = originalPlateFrame.name
	--local levelTextRegion = originalPlateFrame.level
	-- local nameTextRegion = originalPlateFrame.name
	-- local nameTextRegion = originalPlateFrame.name
	
	--local threatGlow, border, highlight, levelIcon, bossIcon, raidIcon, nameTextRegion, levelTextRegion, stateIcon, eliteBorder = originalPlateFrame:GetRegions()
	
	local borderRegion, glowRegion, highlightRegion, levelIconRegion, bossIconRegion, raidIconRegion1, nameTextRegion, levelTextRegion, stateIcon, eliteBorder = originalPlateFrame:GetRegions()
	
	-- originalPlateFrame.name = nameTextRegion	
	-- originalPlateFrame.level = levelTextRegion
	
	--ureg2:SetTexture(nil)
	
	local raidIconRegion = nil
	--raid icon
	-- GetRegions returns a list of all textures and fontstrings on the frame
    local regions = {originalPlateFrame:GetRegions()}
	local fontStrings = {}
	-- Loop through all graphical components on the engine plate
	for i = 1, table.getn(regions) do
		if regions[i] and regions[i]:GetObjectType() == "FontString" then
			table.insert(fontStrings, regions[i])
		end
	end	
	-- The 1.12 engine always creates Name first, then Level second
	if table.getn(fontStrings) >= 2 then
		originalPlateFrame.name = fontStrings[1]
		originalPlateFrame.level = fontStrings[2]
	end
	
	
    for _, region in ipairs(regions) do
        -- Check if the region is a texture and has the raid icons path
        if region:IsObjectType("Texture") then
            local texturePath = region:GetTexture()
            if texturePath and string.find(texturePath, "UI%-RaidTargetingIcons") then
				raidIconRegion = region
            end
        end
    end
	originalPlateFrame.raidIconRegion = raidIconRegion
	--raid icon end	
	
	-- bossIconRegion:SetTexture(nil)
	if bossIconRegion and bossIconRegion:IsVisible() then
		-- This unit is a Boss (it has the skull icon active)
		--print("Boss detected!")
		bossIconRegion:SetTexture(nil)
		kuiPlateFrame.isBoss = true
	end
	originalPlateFrame.bossIconRegion = bossIconRegion
	
	-- print(tostring(borderRegion:GetTexture()))
	-- print(tostring(glowRegion:GetTexture()))
	--print(tostring(highlightRegion:GetTexture()))

	--overlayRegion:SetTexture(nil)
	--highlightRegion:SetTexture(nil)
	--bossIconRegion:SetTexture(nil)
	--shieldedRegion:SetTexture(nil)
	--castbarOverlay:SetTexture(nil)
	glowRegion:SetTexture(nil)
	--spellIconRegion:SetSize(0.01, 0.01)

	--overlayRegion:Hide()
	--castbarOverlay:Hide()

	healthBar:Hide()
	--nameTextRegion:Hide()

	-- re-hidden OnFrameShow
	--bossIconRegion:Hide()
	--bossIconRegion:SetSize(0.01, 0.01)
	--stateIconRegion:Hide()
	--stateIconRegion:SetSize(0.01, 0.01)

	-- make default healthbar & castbar transparent
	--castBar:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\Media\\t\\empty")
	healthBar:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\Media\\t\\empty")

	kuiPlateFrame.oldGlow = glowRegion
	kuiPlateFrame.oldHealth = healthBar
	kuiPlateFrame.oldCastbar = castBar
	kuiPlateFrame.originalPlateFrame = originalPlateFrame
	kuiPlateFrame.oldHighlight = highlightRegion
	--------------------------------------------------------- Frame functions --
	--kuiPlateFrame.SetFrameCenter = SetFrameCenter
	------------------------------------------------------------------ Layout --	
	kuiPlateFrame:SetPoint("CENTER", originalPlateFrame, "CENTER")
	kuiPlateFrame:SetFrameStrata("BACKGROUND")
	--kuiPlateFrame:SetFrameLevel(0)
	SetFrameCenter(kuiPlateFrame)
	
	
	
	
	
	
	-- -- self:CreateHealthBar(originalPlateFrame, kuiPlateFrame)
	-- kuiPlateFrame.health = CreateFrame("StatusBar", nil, kuiPlateFrame)
	-- kuiPlateFrame.health:SetFrameLevel(1)
	-- kuiPlateFrame.health:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar4")
	-- kuiPlateFrame.health.percent = 100
	-- kuiPlateFrame.health:GetStatusBarTexture():SetDrawLayer("ARTWORK", -8)
	-- -- if self.SetValueSmooth then
		-- -- kuiPlateFrame.health.OrigSetValue = kuiPlateFrame.health.SetValue
		-- -- kuiPlateFrame.health.SetValue = self.SetValueSmooth
	-- -- elseif self.CutawayBar then
		-- -- self.CutawayBar(kuiPlateFrame.health)
	-- -- end
	-- kuiPlateFrame.health:SetBackdrop({
		-- bgFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", -- A solid texture
		-- edgeFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", 
		-- edgeSize = 1, 
		-- insets = { left = -UPConstants.minimalOnePixel, right = -UPConstants.minimalOnePixel, top = -UPConstants.minimalOnePixel, bottom = -UPConstants.minimalOnePixel }
	-- })
	-- kuiPlateFrame.health:SetBackdropColor(0, 0, 0, 1) -- Black Background
	-- kuiPlateFrame.health:SetBackdropBorderColor(0, 0, 0, 1) -- Black Border
	-- kuiPlateFrame.health:ClearAllPoints()
	-- kuiPlateFrame.health:SetWidth(UPConstants.nameplateHealthBarWidth)
	-- kuiPlateFrame.health:SetHeight(UPConstants.nameplateHealthBarHeight)
	-- kuiPlateFrame.health:SetPoint("BOTTOMLEFT", kuiPlateFrame.x, kuiPlateFrame.y)
	

	
	kuiPlateFrame.health = CreateFrame("StatusBar", nil, kuiPlateFrame)
	kuiPlateFrame.health:SetFrameLevel(2) -- Bumped up slightly so it layers nicely
	kuiPlateFrame.health:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar4")
	kuiPlateFrame.health.percent = 100
	kuiPlateFrame.health:GetStatusBarTexture():SetDrawLayer("ARTWORK", -8)
	
	-- 1. CLEAN BACKDROP HANDLING: Create a distinct frame *behind* the health bar
	-- This ensures your dark background background has nicely padded rounded edges.
	if not kuiPlateFrame.health.bgOffsetFrame then
		kuiPlateFrame.health.bgOffsetFrame = CreateFrame("Frame", nil, kuiPlateFrame)
		kuiPlateFrame.health.bgOffsetFrame:SetFrameLevel(1) -- Below health bar
		kuiPlateFrame.health.bgOffsetFrame:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8", -- Crisp solid engine texture
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Built-in 2px rounded edge
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.health.bgOffsetFrame:SetBackdropColor(0, 0, 0, 0.8) -- Dark backdrop fill
		kuiPlateFrame.health.bgOffsetFrame:SetBackdropBorderColor(0.1, 0.1, 0.1, 1) -- Very dark grey subtle border
	end

	-- 2. THE CORNER MASKING OVERLAY: Create a frame *above* the health bar
	-- This chops off the sharp moving edges of the status bar as health updates.
	if not kuiPlateFrame.health.overlayMask then
		kuiPlateFrame.health.overlayMask = CreateFrame("Frame", nil, kuiPlateFrame)
		kuiPlateFrame.health.overlayMask:SetFrameLevel(3) -- Directly above the health bar
		kuiPlateFrame.health.overlayMask:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Slices off the 4 square corners
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.health.overlayMask:SetBackdropBorderColor(0, 0, 0, 1) -- Black masking border
	end

	-- 3. POSITIONING LOGIC
	kuiPlateFrame.health:ClearAllPoints()
	kuiPlateFrame.health:SetWidth(UPConstants.nameplateHealthBarWidth)
	kuiPlateFrame.health:SetHeight(UPConstants.nameplateHealthBarHeight)
	kuiPlateFrame.health:SetPoint("BOTTOMLEFT", kuiPlateFrame.x, kuiPlateFrame.y)

	-- Lock the background and foreground rounded layers tight to the bar dimensions plus padding
	local padding = 2.5
	kuiPlateFrame.health.bgOffsetFrame:ClearAllPoints()
	kuiPlateFrame.health.bgOffsetFrame:SetPoint("TOPLEFT", kuiPlateFrame.health, "TOPLEFT", -padding, padding)
	kuiPlateFrame.health.bgOffsetFrame:SetPoint("BOTTOMRIGHT", kuiPlateFrame.health, "BOTTOMRIGHT", padding, -padding)

	kuiPlateFrame.health.overlayMask:ClearAllPoints()
	kuiPlateFrame.health.overlayMask:SetPoint("TOPLEFT", kuiPlateFrame.health, "TOPLEFT", -padding, padding)
	kuiPlateFrame.health.overlayMask:SetPoint("BOTTOMRIGHT", kuiPlateFrame.health, "BOTTOMRIGHT", padding, -padding)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- 1. Create a dedicated High-Strata Frame to host all texts
	if not kuiPlateFrame.textLayerHost then
		kuiPlateFrame.textLayerHost = CreateFrame("Frame", nil, kuiPlateFrame)
		-- Force this frame off the nameplate strata layer entirely
		--kuiPlateFrame.textLayerHost:SetFrameStrata("LOW") 
	end
	-- Update the host frame level dynamically relative to your health bar
	local currentHealthLevel = kuiPlateFrame.health:GetFrameLevel()
	kuiPlateFrame.textLayerHost:SetFrameLevel(currentHealthLevel + 5)
	
	
	
	-- self:CreateHealthText(originalPlateFrame, kuiPlateFrame)
	-- kuiPlateFrame.health.p = kuiPlateFrame:CreateFontString(kuiPlateFrame.overlay, {
		-- font = self.font,
		-- size = "health",
		-- alpha = 1,
		-- outline = "OUTLINE"
	-- })
	-- kuiPlateFrame.health.p:SetHeight(10)
	-- kuiPlateFrame.health.p:SetJustifyH("RIGHT")
	-- kuiPlateFrame.health.p:SetJustifyV("MIDDLE")
	-- kuiPlateFrame.health.p.osize = "health" -- original font size used to update/restore
	--nameplate.health.text:SetAllPoints()
	
	kuiPlateFrame.health.p = kuiPlateFrame.textLayerHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.health.p:SetFont(mainFontPath, UPConstants.healthBigFontSize, "OUTLINE")
	kuiPlateFrame.health.p:SetJustifyH("RIGHT")
	kuiPlateFrame.health.p:SetTextColor(1,1,1,1)
	kuiPlateFrame.health.p:ClearAllPoints()
	kuiPlateFrame.health.p:SetPoint("BOTTOMRIGHT", kuiPlateFrame.health, "BOTTOMRIGHT", -1 * UPConstants.minimalOnePixel, -(UPConstants.healthBigFontSize * 0.4))
	kuiPlateFrame.health.p:Show()
	
	kuiPlateFrame.health.percentage = kuiPlateFrame.health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.health.percentage:SetFont(mainFontPath, UPConstants.healthPercentageFontSize)
	kuiPlateFrame.health.percentage:SetJustifyH("CENTER")
	kuiPlateFrame.health.percentage:SetPoint("CENTER", kuiPlateFrame.health, "CENTER", 0, 0)
	kuiPlateFrame.health.percentage:SetTextColor(1,1,1,1)
	kuiPlateFrame.health.percentage:SetText("69%")

	-- overlay - originalPlateFrame level above health bar, used for text -------------------
	kuiPlateFrame.overlay = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.overlay:SetAllPoints(kuiPlateFrame.health)
	kuiPlateFrame.overlay:SetFrameLevel(2)

	-- self:CreateHighlight(originalPlateFrame, kuiPlateFrame)
	-- kuiPlateFrame.highlight = kuiPlateFrame.overlay:CreateTexture(nil, "ARTWORK")
	-- kuiPlateFrame.highlight:SetTexture(addon.bartexture)
	-- kuiPlateFrame.highlight:SetAllPoints(kuiPlateFrame.health)
	-- kuiPlateFrame.highlight:SetVertexColor(1, 1, 1)
	-- kuiPlateFrame.highlight:SetBlendMode("ADD")
	-- kuiPlateFrame.highlight:SetAlpha(.05)
	-- kuiPlateFrame.highlight:Hide()
	
	-- kuiPlateFrame.typeIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	-- kuiPlateFrame.typeIcon:SetFrameLevel(1)
	-- kuiPlateFrame.typeIcon:SetPoint("RIGHT", kuiPlateFrame.health, "LEFT", -1 * UPConstants.minimalOnePixel, 0)
	-- kuiPlateFrame.typeIcon:SetHeight(UPConstants.nameplateTypeIconSize)
	-- kuiPlateFrame.typeIcon:SetWidth(UPConstants.nameplateTypeIconSize)
	-- kuiPlateFrame.typeIcon.icon = kuiPlateFrame.typeIcon:CreateTexture(nil, "OVERLAY")
	-- kuiPlateFrame.typeIcon.icon:SetAllPoints()
	-- --kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\creaturetypes\\UNKNOWN.tga")
	-- kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
	-- --CreateBackdrop(nameplate.typeIcon, 1)
	-- kuiPlateFrame.typeIcon:SetBackdrop({
		-- bgFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", -- A solid texture
		-- edgeFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", 
		-- edgeSize = 1, 
		-- insets = { left = -UPConstants.minimalOnePixel, right = -UPConstants.minimalOnePixel, top = -UPConstants.minimalOnePixel, bottom = -UPConstants.minimalOnePixel }
	-- })
	-- kuiPlateFrame.typeIcon:SetBackdropColor(0, 0, 0, 1) -- Black Background
	-- kuiPlateFrame.typeIcon:SetBackdropBorderColor(0, 0, 0, 1) -- Black Border
	-- kuiPlateFrame.typeIcon:Show()
	
	kuiPlateFrame.typeIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.typeIcon:SetFrameLevel(2) -- Bumped to match health bar level logic
	kuiPlateFrame.typeIcon:SetPoint("RIGHT", kuiPlateFrame.health, "LEFT", -1 * UPConstants.minimalOnePixel, 0)
	kuiPlateFrame.typeIcon:SetHeight(UPConstants.nameplateTypeIconSize)
	kuiPlateFrame.typeIcon:SetWidth(UPConstants.nameplateTypeIconSize)
	
	kuiPlateFrame.typeIcon.icon = kuiPlateFrame.typeIcon:CreateTexture(nil, "ARTWORK") -- Changed to ARTWORK layer to stay under mask
	kuiPlateFrame.typeIcon.icon:SetAllPoints()
	kuiPlateFrame.typeIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")

	-- 1. CLEAN BACKDROP HANDLING: Create a distinct frame *behind* the type icon
	if not kuiPlateFrame.typeIcon.bgOffsetFrame then
		kuiPlateFrame.typeIcon.bgOffsetFrame = CreateFrame("Frame", nil, kuiPlateFrame)
		kuiPlateFrame.typeIcon.bgOffsetFrame:SetFrameLevel(1) -- Below icon frame
		kuiPlateFrame.typeIcon.bgOffsetFrame:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8", 
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Built-in rounded edge
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.typeIcon.bgOffsetFrame:SetBackdropColor(0, 0, 0, 0.8) 
		kuiPlateFrame.typeIcon.bgOffsetFrame:SetBackdropBorderColor(0.1, 0.1, 0.1, 1) 
	end

	-- 2. THE CORNER MASKING OVERLAY: Create a frame *above* the type icon
	if not kuiPlateFrame.typeIcon.overlayMask then
		kuiPlateFrame.typeIcon.overlayMask = CreateFrame("Frame", nil, kuiPlateFrame)
		kuiPlateFrame.typeIcon.overlayMask:SetFrameLevel(3) -- Directly above the icon texture
		kuiPlateFrame.typeIcon.overlayMask:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Slices off the 4 square corners
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.typeIcon.overlayMask:SetBackdropBorderColor(0, 0, 0, 1) -- Black masking border
	end

	-- Lock the background and foreground rounded layers tight to the icon dimensions plus padding
	local padding = 2.5
	kuiPlateFrame.typeIcon.bgOffsetFrame:ClearAllPoints()
	kuiPlateFrame.typeIcon.bgOffsetFrame:SetPoint("TOPLEFT", kuiPlateFrame.typeIcon, "TOPLEFT", -padding, padding)
	kuiPlateFrame.typeIcon.bgOffsetFrame:SetPoint("BOTTOMRIGHT", kuiPlateFrame.typeIcon, "BOTTOMRIGHT", padding, -padding)

	kuiPlateFrame.typeIcon.overlayMask:ClearAllPoints()
	kuiPlateFrame.typeIcon.overlayMask:SetPoint("TOPLEFT", kuiPlateFrame.typeIcon, "TOPLEFT", -padding, padding)
	kuiPlateFrame.typeIcon.overlayMask:SetPoint("BOTTOMRIGHT", kuiPlateFrame.typeIcon, "BOTTOMRIGHT", padding, -padding)

	kuiPlateFrame.typeIcon:Show()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- kuiPlateFrame.threat = CreateFrame("Frame", nil, kuiPlateFrame)
	-- kuiPlateFrame.threat:SetFrameLevel(1)
	-- kuiPlateFrame.threat:SetPoint("TOP", kuiPlateFrame.typeIcon, "BOTTOM", 0, -1 * UPConstants.minimalOnePixel)
	-- kuiPlateFrame.threat:SetHeight(UPConstants.threatFrameSize)
	-- kuiPlateFrame.threat:SetWidth(UPConstants.threatFrameSize)
	
	kuiPlateFrame.threat = kuiPlateFrame.textLayerHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.threat:SetFont(mainFontPath, UPConstants.threatFontSize, "OUTLINE")
	kuiPlateFrame.threat:SetJustifyH("RIGHT")
	kuiPlateFrame.threat:SetTextColor(1,1,1,1)
	kuiPlateFrame.threat:ClearAllPoints()
	kuiPlateFrame.threat:SetPoint("TOPRIGHT", kuiPlateFrame.typeIcon, "BOTTOMRIGHT", 0, -1 * UPConstants.minimalOnePixel)
	kuiPlateFrame.threat:SetText("100%")
	kuiPlateFrame.threat:Hide()

	-- self:CreateLevel(originalPlateFrame, kuiPlateFrame)
	-- kuiPlateFrame.level = kuiPlateFrame:CreateFontString(kuiPlateFrame.level, {
		-- reset = true,
		-- font = self.font,
		-- size = "level",
		-- alpha = 1,
		-- outline = "OUTLINE"
	-- })
	-- kuiPlateFrame.level:SetParent(kuiPlateFrame.overlay)
	-- kuiPlateFrame.level:SetJustifyH("LEFT")
	-- kuiPlateFrame.level:SetJustifyV("MIDDLE")
	-- kuiPlateFrame.level:SetHeight(10)
	-- kuiPlateFrame.level:ClearAllPoints()
	-- kuiPlateFrame.level.osize = "level" -- original font size used to update/restore
	
	-- kuiPlateFrame.level:ClearAllPoints()
	kuiPlateFrame.level = kuiPlateFrame.textLayerHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.level:SetFont(mainFontPath, UPConstants.levelFontSize, "OUTLINE")
	--kuiPlateFrame.level:SetParent(kuiPlateFrame.health.overlayMask)
	kuiPlateFrame.level:SetJustifyH("CENTER")
	-- kuiPlateFrame.level:SetPoint("RIGHT", kuiPlateFrame.typeIcon, "RIGHT", -2, -4)
	kuiPlateFrame.level:ClearAllPoints()
	kuiPlateFrame.level:SetPoint("BOTTOMLEFT", kuiPlateFrame.health, "BOTTOMLEFT", 2 * UPConstants.minimalOnePixel, -(UPConstants.levelFontSize * 0.4))
	-- kuiPlateFrame.oldLevel.enabled = true
	-- kuiPlateFrame.oldLevel:Hide()
	
	
	-- kuiPlateFrame.guild = kuiPlateFrame:CreateFontString(kuiPlateFrame.overlay, {
		-- font = self.font,
		-- size = "name",
		-- outline = "OUTLINE"
	-- })
	-- kuiPlateFrame.guild.osize = "name" -- original font size used to update/restore
	-- kuiPlateFrame.guild:SetHeight(10)
	kuiPlateFrame.guild = kuiPlateFrame.textLayerHost:CreateFontString(nil, "OVERLAY")
	kuiPlateFrame.guild:SetFont(mainFontPath, UPConstants.nameFontSize, "OUTLINE")
	kuiPlateFrame.guild:ClearAllPoints()
	kuiPlateFrame.guild:SetWidth(0)
	kuiPlateFrame.guild:SetPoint("BOTTOM", kuiPlateFrame.health, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	
	-- kuiPlateFrame.name = kuiPlateFrame:CreateFontString(kuiPlateFrame.overlay, {
		-- font = self.font,
		-- size = "name",
		-- outline = "OUTLINE"
	-- })
	-- kuiPlateFrame.name.osize = "name" -- original font size used to update/restore
	
	kuiPlateFrame.name = kuiPlateFrame.textLayerHost:CreateFontString(nil, "OVERLAY")
	kuiPlateFrame.name:SetFont(mainFontPath, UPConstants.nameFontSize, "OUTLINE")
	--kuiPlateFrame.name:SetHeight(10)
	kuiPlateFrame.name:ClearAllPoints()
	kuiPlateFrame.name:SetWidth(0)
	if (kuiPlateFrame.guild:GetText() == nil or kuiPlateFrame.guild:GetText() == '') then
		kuiPlateFrame.name:SetPoint("BOTTOM", kuiPlateFrame.health, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	else
		kuiPlateFrame.name:SetPoint("BOTTOM", kuiPlateFrame.guild, "TOP", 0, 2 * UPConstants.minimalOnePixel)
	end
	
	kuiPlateFrame.questIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.questIcon:SetFrameLevel(0)
	kuiPlateFrame.questIcon:SetPoint("RIGHT", kuiPlateFrame.name, "LEFT", -0, -0)
	kuiPlateFrame.questIcon:SetHeight(UPConstants.questIconSize)
	kuiPlateFrame.questIcon:SetWidth(UPConstants.questIconSize)
	kuiPlateFrame.questIcon.icon = kuiPlateFrame.questIcon:CreateTexture(nil, "OVERLAY")
	kuiPlateFrame.questIcon.icon:SetAllPoints()
	kuiPlateFrame.questIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\combat\\swords_combat_2")
	kuiPlateFrame.questIcon:Hide()	
	
	kuiPlateFrame.petHappiness = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.petHappiness:SetFrameLevel(0)
	kuiPlateFrame.petHappiness:SetPoint("LEFT", kuiPlateFrame.name, "RIGHT", -0, 0)
	kuiPlateFrame.petHappiness:SetHeight(20)
	kuiPlateFrame.petHappiness:SetWidth(20)
	kuiPlateFrame.petHappiness.icon = kuiPlateFrame.petHappiness:CreateTexture(nil, "OVERLAY")
	--kuiPlateFrame.rarityIconR.icon:SetTexCoord(1, 0, 0, 1)
	--kuiPlateFrame.combatIcon.icon:SetVertexColor(1, 1, 0, 1)
	kuiPlateFrame.petHappiness.icon:SetAllPoints()
	kuiPlateFrame.petHappiness.icon:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	kuiPlateFrame.petHappiness:Hide()
	
	kuiPlateFrame.combatIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.combatIcon:SetFrameLevel(0)
	kuiPlateFrame.combatIcon:SetPoint("LEFT", kuiPlateFrame.name, "RIGHT", -0, -0)
	kuiPlateFrame.combatIcon:SetHeight(UPConstants.combatIconSize)
	kuiPlateFrame.combatIcon:SetWidth(UPConstants.combatIconSize)
	kuiPlateFrame.combatIcon.icon = kuiPlateFrame.combatIcon:CreateTexture(nil, "OVERLAY")
	kuiPlateFrame.combatIcon.icon:SetAllPoints()
	kuiPlateFrame.combatIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\combat\\swords_combat_2")
	kuiPlateFrame.combatIcon:Hide()	
	
	kuiPlateFrame.shootingIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.shootingIcon:SetFrameLevel(3)
	kuiPlateFrame.shootingIcon:SetPoint("LEFT", kuiPlateFrame.health.p, "RIGHT", -0, -0)
	--kuiPlateFrame.shootingIcon:SetPoint("LEFT", kuiPlateFrame.health, "RIGHT", -0, -0)
	kuiPlateFrame.shootingIcon:SetHeight(UPConstants.shootingIconSize)
	kuiPlateFrame.shootingIcon:SetWidth(UPConstants.shootingIconSize)
	kuiPlateFrame.shootingIcon.icon = kuiPlateFrame.shootingIcon:CreateTexture(nil, "ARTWORK")
	kuiPlateFrame.shootingIcon.icon:SetAllPoints()
	kuiPlateFrame.shootingIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\combat\\arrow_target_1_32")
	kuiPlateFrame.shootingIcon.icon:SetDrawLayer("ARTWORK", 2)
	kuiPlateFrame.shootingIcon:Hide()	
	
	
	
	kuiPlateFrame.power = CreateFrame("StatusBar", nil, kuiPlateFrame)
	kuiPlateFrame.power:SetFrameLevel(1) -- keep above glow
	kuiPlateFrame.power:SetOrientation("HORIZONTAL")
	kuiPlateFrame.power:SetPoint("TOP", kuiPlateFrame.health, "BOTTOM", 0, 0)
	kuiPlateFrame.power:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar7")
	kuiPlateFrame.power.hlr, kuiPlateFrame.power.hlg, kuiPlateFrame.power.hlb, kuiPlateFrame.power.hla = glowr, glowg, glowb, 1
	kuiPlateFrame.power:SetWidth(UPConstants.nameplateHealthBarWidth)
	kuiPlateFrame.power:SetHeight(UPConstants.nameplatePowerBarHeight)
	kuiPlateFrame.power:SetBackdrop({
		bgFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", -- A solid texture
		edgeFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", 
		edgeSize = 1, 
		insets = { left = -UPConstants.minimalOnePixel, right = -UPConstants.minimalOnePixel, top = -UPConstants.minimalOnePixel, bottom = -UPConstants.minimalOnePixel }
	})
	kuiPlateFrame.power:SetBackdropColor(0, 0, 0, 1) -- Black Background
	kuiPlateFrame.power:SetBackdropBorderColor(0, 0, 0, 1) -- Black Border
	kuiPlateFrame.power:Hide()
	
	kuiPlateFrame.power.text = kuiPlateFrame.power:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.power.text:SetFont(mainFontPath, UPConstants.powerFontSize, "OUTLINE")
	kuiPlateFrame.power.text:SetJustifyH("RIGHT")
	kuiPlateFrame.power.text:SetPoint("BOTTOMRIGHT", kuiPlateFrame.power, "BOTTOMRIGHT", -1 * UPConstants.minimalOnePixel, -(UPConstants.powerFontSize * 0.6))
	kuiPlateFrame.power.text:SetText("69")
	kuiPlateFrame.power.text:SetTextColor(1,1,1,1)
	
	kuiPlateFrame.classIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.classIcon:SetPoint("RIGHT", kuiPlateFrame.name, "LEFT", -2 * UPConstants.minimalOnePixel, 4 * UPConstants.minimalOnePixel)
	kuiPlateFrame.classIcon:SetHeight(UPConstants.nameplateClassIconSize)
	kuiPlateFrame.classIcon:SetWidth(UPConstants.nameplateClassIconSize)
	kuiPlateFrame.classIcon.icon = kuiPlateFrame.classIcon:CreateTexture(nil, "ARTWORK")
	kuiPlateFrame.classIcon.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	kuiPlateFrame.classIcon.icon:SetAllPoints()
	kuiPlateFrame.classIcon:Hide()
	
	kuiPlateFrame.rarityIcon = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.rarityIcon:SetFrameLevel(0)
	kuiPlateFrame.rarityIcon:SetPoint("RIGHT", kuiPlateFrame.typeIcon, "LEFT", nameplateRarityXOffset, -1 * UPConstants.minimalOnePixel)
	kuiPlateFrame.rarityIcon:SetHeight(UPConstants.nameplateRarityH)
	kuiPlateFrame.rarityIcon:SetWidth(UPConstants.nameplateRarityW)
	kuiPlateFrame.rarityIcon.icon = kuiPlateFrame.rarityIcon:CreateTexture(nil, "BORDER")
	kuiPlateFrame.rarityIcon.icon:SetTexCoord(1, 0, 0, 1)
	kuiPlateFrame.rarityIcon.icon:SetVertexColor(1, 1, 0, 1)
	kuiPlateFrame.rarityIcon.icon:SetAllPoints()
	kuiPlateFrame.rarityIcon.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_elite")
	kuiPlateFrame.rarityIcon:Hide()

	kuiPlateFrame.rarityIconR = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.rarityIconR:SetFrameLevel(0)
	kuiPlateFrame.rarityIconR:SetPoint("LEFT", kuiPlateFrame.health, "RIGHT", -nameplateRarityXOffset, -1 * UPConstants.minimalOnePixel)
	kuiPlateFrame.rarityIconR:SetHeight(UPConstants.nameplateRarityH)
	kuiPlateFrame.rarityIconR:SetWidth(UPConstants.nameplateRarityW)
	kuiPlateFrame.rarityIconR.icon = kuiPlateFrame.rarityIconR:CreateTexture(nil, "BORDER")
	--nameplate.rarityIconR.icon:SetTexCoord(1, 0, 0, 1)
	kuiPlateFrame.rarityIconR.icon:SetVertexColor(1, 1, 0, 1)
	kuiPlateFrame.rarityIconR.icon:SetAllPoints()
	kuiPlateFrame.rarityIconR.icon:SetTexture("Interface\\AddOns\\UnitPlates\\img\\frame_elite")
	kuiPlateFrame.rarityIconR:Hide()

	-- castbar #################################################################
	-- if self.Castbar then
		-- self.Castbar:CreateCastbar(kuiPlateFrame)
	-- end
	-- self.Castbar:CreateCastbar(kuiPlateFrame)

	-- target highlight --------------------------------------------------------
	kuiPlateFrame.glow = kuiPlateFrame:CreateTexture(nil, "BACKGROUND")
	kuiPlateFrame.glow:SetPoint("LEFT", kuiPlateFrame.typeIcon, "LEFT", -UPConstants.nameplateArrowSize, 0)
	kuiPlateFrame.glow:SetTexture("Interface\\AddOns\\UnitPlates\\img\\arrow_left")
	--nameplate.glow:SetFrameLevel(1)
	kuiPlateFrame.glow:SetDrawLayer("BACKGROUND")
	kuiPlateFrame.glow:SetWidth(UPConstants.nameplateArrowSize)
	kuiPlateFrame.glow:SetHeight(UPConstants.nameplateArrowSize)
	kuiPlateFrame.glow:SetVertexColor(unpack(glowColor))
	kuiPlateFrame.glow:Hide()

	kuiPlateFrame.glow2 = kuiPlateFrame:CreateTexture(nil, "BACKGROUND")
	kuiPlateFrame.glow2:SetPoint("RIGHT", kuiPlateFrame.health, "RIGHT", UPConstants.nameplateArrowSize, 0)
	kuiPlateFrame.glow2:SetTexture("Interface\\AddOns\\UnitPlates\\img\\arrow_right")
	--nameplate.glow:SetFrameLevel(1)
	kuiPlateFrame.glow2:SetDrawLayer("BACKGROUND")
	--nameplate.glow2.texture:SetRotation(2)
	kuiPlateFrame.glow2:SetWidth(UPConstants.nameplateArrowSize)
	kuiPlateFrame.glow2:SetHeight(UPConstants.nameplateArrowSize)
	kuiPlateFrame.glow2:SetVertexColor(unpack(glowColor))
	kuiPlateFrame.glow2:Hide()
	
	-- kuiPlateFrame.targetGlow = kuiPlateFrame.overlay:CreateTexture(nil, "ARTWORK")
	-- kuiPlateFrame.targetGlow:SetTexture("Interface\\AddOns\\UnitPlates\\Media\\target-glow")
	-- kuiPlateFrame.targetGlow:SetTexCoord(0, .593, 0, .875)
	-- kuiPlateFrame.targetGlow:SetPoint("CENTER", kuiPlateFrame.health, "CENTER", 0, -10)
	-- kuiPlateFrame.targetGlow:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
	-- kuiPlateFrame.targetGlow:Hide()
	-- kuiPlateFrame.targetGlow:SetSize(UPConstants.nameplateHealthBarWidth, UPConstants.nameplateHealthBarHeight*4)

	-- raid icon ---------------------------------------------------------------
	-- kuiPlateFrame.icon:SetParent(kuiPlateFrame.overlay)
	-- kuiPlateFrame.icon:SetWidth(UPConstants.raidIconSize)
	-- kuiPlateFrame.icon:SetHeight(UPConstants.raidIconSize)
	-- kuiPlateFrame.icon:ClearAllPoints()
	-- kuiPlateFrame.icon:SetPoint("TOP", kuiPlateFrame.overlay, "BOTTOM", 0, -8 * UPConstants.minimalOnePixel)
	
	----------------------------------------------------------------------------
	
	kuiPlateFrame.castWarning = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.castWarning:SetFrameLevel(0)
	kuiPlateFrame.castWarning:SetPoint("TOP", kuiPlateFrame.power, "BOTTOM", 0, -5 * UPConstants.minimalOnePixel)
	kuiPlateFrame.castWarning:SetWidth(1)
	kuiPlateFrame.castWarning:SetHeight(1)
	kuiPlateFrame.castWarning:Hide()
	
	kuiPlateFrame.castWarning.bar = CreateFrame("StatusBar", nil, kuiPlateFrame.castWarning)
	kuiPlateFrame.castWarning.bar:SetStatusBarTexture("Interface\\AddOns\\UnitPlates\\img\\statusbar\\XPerl_StatusBar7")
	kuiPlateFrame.castWarning.bar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 2)
	kuiPlateFrame.castWarning.bar:SetStatusBarColor(unpack(castBarColor))
	kuiPlateFrame.castWarning.bar:SetHeight(4)
	kuiPlateFrame.castWarning.bar:SetWidth(UPConstants.nameplateHealthBarWidth)
	kuiPlateFrame.castWarning.bar:SetPoint("TOP", kuiPlateFrame.castWarning, "TOP", 0, 0)
	kuiPlateFrame.castWarning.bar:SetMinMaxValues(0, 1)
	
	kuiPlateFrame.castWarning.bar:SetBackdrop({
		bgFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", -- A solid texture
		edgeFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", 
		edgeSize = 1, 
		insets = { left = -UPConstants.minimalOnePixel, right = -UPConstants.minimalOnePixel, top = -UPConstants.minimalOnePixel, bottom = -UPConstants.minimalOnePixel }
	})
	kuiPlateFrame.castWarning.bar:SetBackdropColor(0, 0, 0, 1) -- Black Background
	kuiPlateFrame.castWarning.bar:SetBackdropBorderColor(0, 0, 0, 1) -- Black Border
	
	-- uninterruptible cast shield -----------------------------------------
	kuiPlateFrame.castWarning.shield = kuiPlateFrame.castWarning.bar:CreateTexture(nil, "ARTWORK")
	kuiPlateFrame.castWarning.shield:SetTexture("Interface\\AddOns\\UnitPlates\\Media\\Shield")
	kuiPlateFrame.castWarning.shield:SetTexCoord(0, 0.84375, 0, 1)
	kuiPlateFrame.castWarning.shield:SetVertexColor(0.5, 0.5, 0.7)

	kuiPlateFrame.castWarning.shield:SetWidth(castBarSizes.shield * .84375)
	kuiPlateFrame.castWarning.shield:SetHeight(castBarSizes.shield)
	kuiPlateFrame.castWarning.shield:SetPoint("LEFT", kuiPlateFrame.castWarning.bar, -7 * UPConstants.minimalOnePixel, 0)

	kuiPlateFrame.castWarning.shield:SetBlendMode("BLEND")
	kuiPlateFrame.castWarning.shield:SetDrawLayer("ARTWORK", 7)
	
	--
	-- kuiPlateFrame.castWarning.spark = kuiPlateFrame.castWarning.bar:CreateTexture(nil, "ARTWORK")
	-- kuiPlateFrame.castWarning.spark:SetDrawLayer("ARTWORK", 6)
	-- kuiPlateFrame.castWarning.spark:SetVertexColor(1, 1, 0.8)
	-- kuiPlateFrame.castWarning.spark:SetTexture("Interface\\AddOns\\UnitPlates\\Media\\t\\spark")
	-- kuiPlateFrame.castWarning.spark:SetPoint("TOP", kuiPlateFrame.castWarning.bar:GetRegions(), "TOPRIGHT", 0, 3 * UPConstants.minimalOnePixel)
	-- kuiPlateFrame.castWarning.spark:SetPoint("BOTTOM", kuiPlateFrame.castWarning.bar:GetRegions(), "BOTTOMRIGHT", 0, -3 * UPConstants.minimalOnePixel)
	-- kuiPlateFrame.castWarning.spark:SetWidth(6)
	
	kuiPlateFrame.castWarning.spark = kuiPlateFrame.castWarning.bar:CreateTexture(nil, "OVERLAY") -- Use OVERLAY to be on top
	kuiPlateFrame.castWarning.spark:SetDrawLayer("ARTWORK", 6)
	kuiPlateFrame.castWarning.spark:SetVertexColor(1, 1, 0.8)
	kuiPlateFrame.castWarning.spark:SetTexture("Interface\\AddOns\\UnitPlates\\Media\\t\\spark")
	kuiPlateFrame.castWarning.spark:SetHeight(kuiPlateFrame.castWarning.bar:GetHeight() + 6) -- Make it slightly taller than the bar
	kuiPlateFrame.castWarning.spark:SetBlendMode("ADD") -- Makes it look like a "glow"
	kuiPlateFrame.castWarning.spark:SetPoint("CENTER", kuiPlateFrame.castWarning.bar, "LEFT", 0, 0)
	kuiPlateFrame.castWarning.spark:SetWidth(6)
	
	kuiPlateFrame.castWarning.curr = kuiPlateFrame.castWarning.bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.castWarning.curr:SetFont(mainFontPath, UPConstants.castWarningDurationFontSize, "OUTLINE")
	--kuiPlateFrame.castWarning.curr:SetPoint("LEFT", kuiPlateFrame.castWarning.bar, "RIGHT", 2, 0)
	kuiPlateFrame.castWarning.curr:SetPoint("BOTTOMRIGHT", kuiPlateFrame.castWarning.bar, "BOTTOMRIGHT", -1 * UPConstants.minimalOnePixel, -(UPConstants.castWarningDurationFontSize * 0.65))
	kuiPlateFrame.castWarning.curr:SetText("0")
	
	kuiPlateFrame.castWarning.text = kuiPlateFrame.castWarning:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	kuiPlateFrame.castWarning.text:SetFont(mainFontPath, UPConstants.castWarningNameFontSize, "OUTLINE")
	kuiPlateFrame.castWarning.text:SetPoint("TOP", kuiPlateFrame.castWarning.bar, "BOTTOM", 0, -5)
	-- kuiPlateFrame.castWarning.text:SetText("69")
	-- kuiPlateFrame.castWarning.text:SetTextColor(1,1,1,1)
	
	kuiPlateFrame.castWarning.icon = CreateFrame("Frame", nil, kuiPlateFrame.castWarning)
	kuiPlateFrame.castWarning.icon:SetFrameLevel(0)
	kuiPlateFrame.castWarning.icon:SetPoint("RIGHT", kuiPlateFrame.castWarning.text, "LEFT", -2 * UPConstants.minimalOnePixel, 0)
	kuiPlateFrame.castWarning.icon:SetHeight(castBarSizes.icon)
	kuiPlateFrame.castWarning.icon:SetWidth(castBarSizes.icon)
	kuiPlateFrame.castWarning.icon.tex = kuiPlateFrame.castWarning.icon:CreateTexture(nil, "ARTWORK")
	kuiPlateFrame.castWarning.icon.tex:SetAllPoints()
	-- kuiPlateFrame.castWarning.icon.tex:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
	
	kuiPlateFrame.castWarning.currentValue = 0
	kuiPlateFrame.castWarning.startTime = 0
	kuiPlateFrame.castWarning.endTime = 0
	kuiPlateFrame.castWarning.castTime = 0
	
	---------------------------------------------------------------------------------

	-- scripts -------------------------------------------------------------
	-- kuiPlateFrame.castbar:RegisterEvent("UNIT_SPELLCAST_START")
	-- kuiPlateFrame.castbar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	--cast bar end
	
	-- create combo points
	kuiPlateFrame.combopoints = CreateFrame("Frame", nil, kuiPlateFrame.overlay)
	kuiPlateFrame.combopoints:Hide()

	local pcp
	for i = 0, 4 do
		-- create individual combo point icons
		-- size and position of first icon is set in ScaleComboPoints
		local cp = kuiPlateFrame.combopoints:CreateTexture(nil, "ARTWORK")
		cp:SetDrawLayer("ARTWORK", 2)
		cp:SetTexture("Interface\\AddOns\\UnitPlates\\Media\\combopoint-round")

		if i > 0 then
			cp:SetPoint("LEFT", pcp, "RIGHT", combopointsSizes.spacing, 0)
		end

		tinsert(kuiPlateFrame.combopoints, i + 1, cp)
		pcp = cp
	end

	for i, cp in ipairs(kuiPlateFrame.combopoints) do
		cp:SetWidth(combopointsSizes.combopoints)
		cp:SetHeight(combopointsSizes.combopoints)

		if i == 1 then
			-- place first icon to offset others to center
			cp:SetPoint("BOTTOM", kuiPlateFrame.health, "BOTTOM", -(combopointsSizes.combopoints + combopointsSizes.spacing) * 2, -(combopointsSizes.combopoints / 2))
		end
	end
	-- create combo points end
	
	--totem
	-- originalPlateFrame.totem = CreateFrame("Frame", nil, originalPlateFrame)
	-- originalPlateFrame.totem:SetPoint("TOP", originalPlateFrame, "TOP", 0, 0)
	-- originalPlateFrame.totem:SetHeight(UPConstants.totemIconSize)
	-- originalPlateFrame.totem:SetWidth(UPConstants.totemIconSize)
	-- --originalPlateFrame.totem:SetFrameLevel(5)
	-- originalPlateFrame.totem.icon = originalPlateFrame.totem:CreateTexture(nil, "OVERLAY")
	-- originalPlateFrame.totem.icon:SetTexCoord(.078, .92, .079, .937)
	-- originalPlateFrame.totem.icon:SetAllPoints()
	-- originalPlateFrame.totem:SetBackdrop({
		-- bgFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", -- A solid texture
		-- edgeFile = "Interface\\AddOns\\UnitPlates\\img\\WHITE", 
		-- edgeSize = 1, 
		-- insets = { left = -(3 * UPConstants.minimalOnePixel), right = -(3 * UPConstants.minimalOnePixel), top = -(3 * UPConstants.minimalOnePixel), bottom = -(3 * UPConstants.minimalOnePixel) }
	-- })
	-- originalPlateFrame.totem:SetBackdropColor(0, 0, 0, 1) -- Black Background
	-- originalPlateFrame.totem:SetBackdropBorderColor(0, 0, 0, 1) -- Black Border
	-- --originalPlateFrame.totem:SetVertexColor(1, 1, 1, 1)
	-- originalPlateFrame.totem:Hide()
	
	-- Initialize the Totem container frame
	kuiPlateFrame.originalPlateFrame.totem = CreateFrame("Frame", nil, originalPlateFrame)
	kuiPlateFrame.originalPlateFrame.totem:SetFrameLevel(3) -- Middle layer for the icon
	kuiPlateFrame.originalPlateFrame.totem:SetPoint("TOP", kuiPlateFrame.health, "TOP", 0, 0)
	kuiPlateFrame.originalPlateFrame.totem:SetHeight(UPConstants.totemIconSize)
	kuiPlateFrame.originalPlateFrame.totem:SetWidth(UPConstants.totemIconSize)
	
	-- Create the icon texture asset inside the frame
	kuiPlateFrame.originalPlateFrame.totem.icon = originalPlateFrame.totem:CreateTexture(nil, "ARTWORK") -- Changed to ARTWORK layer to stay under the mask frame
	kuiPlateFrame.originalPlateFrame.totem.icon:SetAllPoints()
	kuiPlateFrame.originalPlateFrame.totem.icon:SetTexture("Interface\\Icons\\Spell_Nature_ thereIsNoIcon")
	
	-- 1. CLEAN BACKDROP HANDLING: Create a distinct background frame *behind* the totem icon
	if not kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame then
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame = CreateFrame("Frame", nil, originalPlateFrame.totem)
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetFrameLevel(2) -- Safely layers behind the texture
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8", -- Crisp solid engine texture
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Built-in rounded edge asset
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetBackdropColor(0, 0, 0, 0.8) -- Dark backdrop fill
		kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetBackdropBorderColor(0.1, 0.1, 0.1, 1) -- Matte grey border rim
	end

	-- 2. THE CORNER MASKING OVERLAY: Create a matte-black masking frame *above* the totem icon
	if not kuiPlateFrame.originalPlateFrame.totem.overlayMask then
		kuiPlateFrame.originalPlateFrame.totem.overlayMask = CreateFrame("Frame", nil, originalPlateFrame.totem)
		kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetFrameLevel(4) -- Directly above the icon texture to clip it
		kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Slices off the 4 square corners
			tile = false, tileSize = 0, edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 }
		})
		kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetBackdropBorderColor(0, 0, 0, 1) -- Pure black mask to match layouts
	end

	-- 3. POSITIONING LOGIC
	-- Anchor the background and foreground overlay frames perfectly to the main icon frame
	local padding = 4
	kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:ClearAllPoints()
	kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetPoint("TOPLEFT", kuiPlateFrame.originalPlateFrame.totem, "TOPLEFT", -padding, padding)
	kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetPoint("BOTTOMRIGHT", kuiPlateFrame.originalPlateFrame.totem, "BOTTOMRIGHT", padding, -padding)

	kuiPlateFrame.originalPlateFrame.totem.overlayMask:ClearAllPoints()
	kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetPoint("TOPLEFT", kuiPlateFrame.originalPlateFrame.totem, "TOPLEFT", -padding, padding)
	kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetPoint("BOTTOMRIGHT", kuiPlateFrame.originalPlateFrame.totem, "BOTTOMRIGHT", padding, -padding)

	kuiPlateFrame.originalPlateFrame.totem:Hide()
	
	
	
	
	
	
	originalPlateFrame.totem.glow = originalPlateFrame.totem:CreateTexture(nil, "BACKGROUND")
	originalPlateFrame.totem.glow:SetPoint("LEFT", originalPlateFrame.totem, "LEFT", -UPConstants.nameplateArrowSize * 1.1, 0)
	originalPlateFrame.totem.glow:SetTexture("Interface\\AddOns\\UnitPlates\\img\\arrow_left")
	--nameplate.glow:SetFrameLevel(1)
	originalPlateFrame.totem.glow:SetDrawLayer("BACKGROUND")
	originalPlateFrame.totem.glow:SetWidth(UPConstants.nameplateArrowSize)
	originalPlateFrame.totem.glow:SetHeight(UPConstants.nameplateArrowSize)
	originalPlateFrame.totem.glow:SetVertexColor(unpack(glowColor))
	originalPlateFrame.totem.glow:Hide()

	originalPlateFrame.totem.glow2 = originalPlateFrame.totem:CreateTexture(nil, "BACKGROUND")
	originalPlateFrame.totem.glow2:SetPoint("RIGHT", originalPlateFrame.totem, "RIGHT", UPConstants.nameplateArrowSize * 1.1, 0)
	originalPlateFrame.totem.glow2:SetTexture("Interface\\AddOns\\UnitPlates\\img\\arrow_right")
	--nameplate.glow:SetFrameLevel(1)
	originalPlateFrame.totem.glow2:SetDrawLayer("BACKGROUND")
	--nameplate.glow2.texture:SetRotation(2)
	originalPlateFrame.totem.glow2:SetWidth(UPConstants.nameplateArrowSize)
	originalPlateFrame.totem.glow2:SetHeight(UPConstants.nameplateArrowSize)
	originalPlateFrame.totem.glow2:SetVertexColor(unpack(glowColor))
	originalPlateFrame.totem.glow2:Hide()
	--totem END
	
	--auras
	kuiPlateFrame.unitAuras = {}
	
	kuiPlateFrame.aurasContainer = CreateFrame("Frame", nil, kuiPlateFrame)
	kuiPlateFrame.aurasContainer:SetPoint("BOTTOM", kuiPlateFrame.name, "TOP", 0, UPConstants.nameplateClassIconSize / 2)
	kuiPlateFrame.aurasContainer:SetHeight(UPConstants.nameplateHealthBarHeight)
	kuiPlateFrame.aurasContainer:SetWidth(UPConstants.nameplateHealthBarWidth)
	--create icons
	kuiPlateFrame.aurasContainer.auraIcons = {} -- Table to hold our icon frames
	--auras onupdate
	kuiPlateFrame.aurasContainer:SetScript("OnUpdate", function()
		local self = kuiPlateFrame.aurasContainer
		if not self then return nil end
		local elapsed = arg1
	
		self.nextUpdate = (self.nextUpdate or 0) - elapsed
		if self.nextUpdate > 0 then return end
		self.nextUpdate = 0.1 
		
		--THIS IS AURAS FRAMES UPDATE
		--print("here")
		
		local currentTime = GetTime()
		
		-- Safely remove expired auras by iterating backwards
		for i = table.getn(kuiPlateFrame.unitAuras), 1, -1 do
			local aura = kuiPlateFrame.unitAuras[i]
			-- Check if it has an expiration time and if that time has passed
			--print("aura name1: "..tostring(aura.name))
			if not (aura.duration == -1) then
				local timeLeftSeconds = aura.expirationTime - currentTime
				if timeLeftSeconds <= 0 then
					--should remove only if it is not in the actual aura list
					-- or maybe do not even manually remove at all? since I frequently update it anyways
					--just know/notify somehow that it seems that db duration is wrong on this one
					--table.remove(kuiPlateFrame.unitAuras, i)
				end
			end
		end
		--
		
		local activeUnitAurasCount = table.getn(kuiPlateFrame.unitAuras)
		
		local hasDebuffRow = false
		local firstDebuffIndex = 1
		local firstDebuffRow = 1
		local buffrows = 0
		local lastBuffYOffset = 0
		local hadAnyBuffs = false
		
		--iterating through stored list
		local iconIndex = 1    
		for _, aura in ipairs(kuiPlateFrame.unitAuras) do
			local name = aura.name
			local texture = aura.texture
			local count = aura.count
			local duration = aura.duration
			local expirationTime = aura.expirationTime
			
			-- Stop if no more auras OR if we ran out of our MAX icons
			if not name or iconIndex > UPConstants.maxAuras then
				break 
			end
			
			--setup icon
			local icon = self.auraIcons[iconIndex]
			
			icon.isDebuff = aura.isDebuff
			
			-- Set Texture
			icon.tex:SetTexture(texture)
			
			--set count
			icon.count = count
			
			-- Set Cooldown
			if duration > 0 then
				icon.expirationTime = expirationTime
				icon.duration = duration
				icon.startTime = expirationTime - duration
			elseif duration == -1 then
				icon.expirationTime = -1
				icon.duration = -1
				icon.startTime = -1
			else
				icon.expirationTime = 0
				icon.duration = 0
				icon.startTime = 0
			end
			
			-- Position the icon dynamically
			--determine icon size based on active count and max in row
			
			if activeUnitAurasCount <= 8 then
				if UnitPlatesSettings.smallerAuras then
					UPConstants.maxAurasInRow = 6
				else
					UPConstants.maxAurasInRow = 4
				end
			elseif activeUnitAurasCount <= 16 then
				if UnitPlatesSettings.smallerAuras then
					UPConstants.maxAurasInRow = 6
				else
					UPConstants.maxAurasInRow = 5
				end
			elseif activeUnitAurasCount <= 24 then
				UPConstants.maxAurasInRow = 6
			else
				UPConstants.maxAurasInRow = 7
			end
			
			
			local iconSize = (UPConstants.nameplateHealthBarWidth / UPConstants.maxAurasInRow) - UPConstants.auraIconOffset
			if kuiPlateFrame.isGrayLevel or kuiPlateFrame.isPet then
				iconSize = (UPConstants.nameplateWidthGrayLevel / UPConstants.maxAurasInRow) - UPConstants.auraIconOffset
			end
			
			local column = math.mod((iconIndex - 1), UPConstants.maxAurasInRow)          -- Results in 0, 1, 2, 3
			local row = math.floor((iconIndex - 1) / UPConstants.maxAurasInRow) -- Results in 0, 1, 2...
			
			if not aura.isDebuff then
				hadAnyBuffs = true
			end
			if hadAnyBuffs and aura.isDebuff and firstDebuffIndex == 1 then
				buffrows = (math.floor((iconIndex - 1 - 1) / UPConstants.maxAurasInRow))
				firstDebuffIndex = iconIndex
				firstDebuffRow = row
			end
			
			if firstDebuffIndex > 1 then
				-- row = row + 1
				column = math.mod((iconIndex - firstDebuffIndex), UPConstants.maxAurasInRow)
				row = math.floor((iconIndex - firstDebuffIndex) / UPConstants.maxAurasInRow)
			end
			
			local xOffset = column * (iconSize + UPConstants.auraIconOffset)
			local yOffset = row * (iconSize + UPConstants.auraIconOffset)
			
			if firstDebuffIndex > 1 then
				yOffset = (buffrows * (iconSize + UPConstants.auraIconOffset)) + (row * (iconSize + UPConstants.auraIconOffset)) + (iconSize * 1.3)
			end
			
			icon:SetWidth(iconSize)
			icon:SetHeight(iconSize)
			local timeLeftSeconds = aura.expirationTime - currentTime
			if timeLeftSeconds >= 60 then
				icon.cdText:SetFont(mainFontPath, iconSize/2.6, "OUTLINE")
			else
				icon.cdText:SetFont(mainFontPath, iconSize/2, "OUTLINE")
			end
			icon.countText:SetFont(mainFontPath, iconSize/3, "OUTLINE")
			
			icon:ClearAllPoints()
			-- We use BOTTOMLEFT so that as 'row' increases, icons move UP (on top)
			icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", xOffset, yOffset)
			
			icon:Show()
			iconIndex = iconIndex + 1
		end
		
		--Hide any remaining icons in our pool that aren't being used
		for i = iconIndex, UPConstants.maxAuras do
			if self.auraIcons[i] then
				self.auraIcons[i]:Hide()
			end
		end
	end)
	--aura onupdate end
	
	--kuiPlateFrame.aurasContainer:SetFrameStrata("TOOLTIP")	
	for i = 1, UPConstants.maxAuras do		
		local icon = CreateFrame("Frame", nil, kuiPlateFrame.aurasContainer)
		icon:SetWidth(16)
		icon:SetHeight(16)
		icon:SetFrameLevel(1)
		
		icon.tex = icon:CreateTexture(nil, "BACKGROUND")
		icon.tex:SetTexture("Interface\\AddOns\\UnitPlates\\img\\loading.tga")
		icon.tex:SetAllPoints(icon)
		--icon.tex:SetFrameLevel(0)
		
		icon.countText = icon:CreateFontString(nil, "OVERLAY", "SubSpellFont")
		icon.countText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, 0)
		icon.countText:SetFont(mainFontPath, UPConstants.powerFontSize, "OUTLINE")
		icon.countText:SetTextColor(1,1,1,1)
		
		icon.cdText = icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		icon.cdText:SetPoint("CENTER", icon, "CENTER", 0, 0)
		icon.cdText:SetFont(mainFontPath, UPConstants.levelFontSize, "OUTLINE")
		icon.cdText:SetTextColor(1,1,1,1)
		
		icon.quads = {
			TR = UPCoreCreateQuadrant(icon, "TOPRIGHT"),
			BR = UPCoreCreateQuadrant(icon, "BOTTOMRIGHT"),
			BL = UPCoreCreateQuadrant(icon, "BOTTOMLEFT"),
			TL = UPCoreCreateQuadrant(icon, "TOPLEFT"),
		}
		
		icon:SetScript("OnUpdate", function()
			local self = icon
			local elapsed = arg1
		
			if self:IsShown() then
				self.nextUpdate = (self.nextUpdate or 0) - elapsed
				if self.nextUpdate > 0 then return end
				self.nextUpdate = 0.1 
				
				--count
				if self.count and self.count > 1 then
					self.countText:SetText(""..self.count)
				else
					self.countText:SetText("")
				end
				
				--time left
				if self.duration == -1 then
					self.cdText:SetText("")
					for _, q in pairs(self.quads) do
						q:Hide()
					end
					return nil
				end
				
				local timeLeftSeconds = self.expirationTime-GetTime()
				if timeLeftSeconds > 0 then
					local cooldownText = ""..timeLeftSeconds
					if timeLeftSeconds >= 60*60 then
						cooldownText = math.floor(timeLeftSeconds / 3600) .. "h"
						if self.isDebuff then
							self.cdText:SetTextColor(0.70, 0.30, 1.0, 1.0)
						else
							self.cdText:SetTextColor(0.53,0.81,0.98,1)
						end
					elseif timeLeftSeconds >= 60 then
						cooldownText = math.floor(timeLeftSeconds / 60) .. "m"
						if self.isDebuff then
							self.cdText:SetTextColor(0.70, 0.30, 1.0, 1.0)
						else
							self.cdText:SetTextColor(0.53,0.81,0.98,1)
						end
					elseif timeLeftSeconds >= 1 then
						cooldownText = math.floor(timeLeftSeconds) .. ""
						if self.isDebuff then
							self.cdText:SetTextColor(1,0.8,0.8,1)
						else
							self.cdText:SetTextColor(0.8,0.8,1,1)
						end
						if timeLeftSeconds <= 3 then
							self.cdText:SetTextColor(0.99,0,0,1)
						elseif timeLeftSeconds <= 7 then
							self.cdText:SetTextColor(0.99,0.99,0,1)
						end
					elseif timeLeftSeconds > 0 then
						local s = string.format("%.1f", timeLeftSeconds)
						--cooldownText = string.gsub(s, "^0", "")
						cooldownText = string.sub(s, 2)
						self.cdText:SetTextColor(0.99,0,0,1)
					else
						cooldownText = "0"
						self.cdText:SetTextColor(0.99,0,0,1)
					end
					
					self.cdText:SetText(cooldownText)--show
				else
					self.cdText:SetText("0")--show
					if timeLeftSeconds < 0 then
						--probably negative values are more informative than questions
						local cooldownText = ""..timeLeftSeconds
						local s = string.format("%.1f", timeLeftSeconds)
						cooldownText = string.sub(s, 2)
						self.cdText:SetTextColor(0.99,0,0,1)
						
						--self.cdText:SetText("??")--show
						--print("aura duration seems to be incorrect for: "..auraName)
					end
				end
				
				local pct = timeLeftSeconds / self.duration -- 1.0 down to 0.0
				if pct > 1 then
					pct = 1 -- Clamp to 100%
				end
				if pct < 0 then
					pct = 0  -- Clamp to 0%
				end
				local size = self:GetWidth() / 2 -- Half the icon size (e.g., 18)

				-- Reset state
				for _, q in pairs(self.quads) do
					q:Show()
					q:SetWidth(size) 
					q:SetHeight(size) 
				end

				if pct > 0.75 then
					-- 100% to 75%: Shrink TOP RIGHT width
					self.quads.TR:SetWidth(size * ((pct - 0.75) / 0.25))
				elseif pct > 0.50 then
					-- 75% to 50%: TR is gone, shrink BOTTOM RIGHT height
					self.quads.TR:Hide()
					self.quads.BR:SetHeight(size * ((pct - 0.50) / 0.25))
				elseif pct > 0.25 then
					-- 50% to 25%: TR/BR gone, shrink BOTTOM LEFT width
					self.quads.TR:Hide()
					self.quads.BR:Hide()
					self.quads.BL:SetWidth(size * ((pct - 0.25) / 0.25))
				elseif pct > 0 then
					-- 25% to 0%: Only TL left, shrink TOP LEFT height
					self.quads.TR:Hide()
					self.quads.BR:Hide()
					self.quads.BL:Hide()
					self.quads.TL:SetHeight(size * (pct / 0.25))
				else
					for _, q in pairs(self.quads) do
						q:Hide()
					end
				end
			end
		end)

		icon.expirationTime = 0
		icon.duration = 0
		icon.startTime = 0
		icon:Hide() -- Hide by default
		kuiPlateFrame.aurasContainer.auraIcons[i] = icon -- Store in our pool
	end
	--auras END

	----------------------------------------------------------------- Scripts --
	-- originalPlateFrame:HookScript("OnShow", OnFrameShow)
	-- originalPlateFrame:HookScript("OnHide", OnFrameHide)
	-- originalPlateFrame:HookScript("OnUpdate", OnFrameUpdate)
	
	-- Manual Hook for OnShow
	local oldOnShow = originalPlateFrame:GetScript("OnShow")
	originalPlateFrame:SetScript("OnShow", function()
		if oldOnShow then oldOnShow() end		
		OnFrameShow(this) -- In 1.12 we use 'this' instead of passing 'originalPlateFrame'
	end)

	-- Manual Hook for OnHide
	local oldOnHide = originalPlateFrame:GetScript("OnHide")
	originalPlateFrame:SetScript("OnHide", function()
		if oldOnHide then oldOnHide() end
		--OnFrameHide(this)
		--local kuiPlateFrame = self.kui
		this:Hide()
		ResetFrame(this.kui, this)
	end)

	-- Manual Hook for OnUpdate
	local oldOnUpdate = originalPlateFrame:GetScript("OnUpdate")
	originalPlateFrame:SetScript("OnUpdate", function()
		-- originalPlateFrame:SetWidth(1)
		-- originalPlateFrame:SetHeight(1)
		if oldOnUpdate then oldOnUpdate(arg1) end
		OnFrameUpdate(this, arg1)
		-- originalPlateFrame:SetWidth(1)
		-- originalPlateFrame:SetHeight(1)
	end)

	kuiPlateFrame.oldHealth.kuiParent = originalPlateFrame
	-- kuiPlateFrame.oldHealth:HookScript("OnValueChanged", function(self)
		-- kuiPlateFrame:OnHealthValueChanged(unpack(arg)) 
	-- end)
	-- local oldOnValueChanged = kuiPlateFrame.oldHealth:GetScript("OnValueChanged")
	-- kuiPlateFrame.oldHealth:SetScript("OnValueChanged", function()
		-- if oldOnValueChanged then oldOnValueChanged(arg1) end
		-- -- We use 'kuiPlateFrame' directly since it's in the scope of InitFrame
		-- --kuiPlateFrame:OnHealthValueChanged() 
		-- UpdateHealth(kuiPlateFrame)
	-- end)
	
	--kuiPlateFrame:EnableMouse(1)
	kuiPlateFrame.health:EnableMouse(true)
	kuiPlateFrame.typeIcon:EnableMouse(true)
	kuiPlateFrame.power:EnableMouse(true)
	originalPlateFrame.totem:EnableMouse(true)
	
	kuiPlateFrame.health:SetScript("OnMouseUp", function()
		--print("here1")
		if MouseIsOver(kuiPlateFrame.health) then
			--print("here")
			originalPlateFrame:Click(arg1)
		end
	end)
	kuiPlateFrame.typeIcon:SetScript("OnMouseUp", function()
		--print("here1")
		if MouseIsOver(kuiPlateFrame.typeIcon) then
			--print("here")
			originalPlateFrame:Click(arg1)
		end
	end)
	kuiPlateFrame.power:SetScript("OnMouseUp", function()
		--print("here1")
		if MouseIsOver(kuiPlateFrame.power) then
			--print("here")
			originalPlateFrame:Click(arg1)
		end
	end)
	-- originalPlateFrame.totem:SetScript("OnMouseUp", function()
		-- --print("here1")
		-- if MouseIsOver(originalPlateFrame.totem) then
			-- --print("here")
			-- originalPlateFrame:Click(arg1)
		-- end
	-- end)
	originalPlateFrame.totem:SetScript("OnMouseDown", function()
		-- arg1 contains "LeftButton" or "RightButton"
		if MouseIsOver(originalPlateFrame.totem) then
			originalPlateFrame:Click(arg1)
			
			--USE CUSTOM LOGIC LATER
			-- if kuiPlateFrame and kuiPlateFrame.nameTextVariable then
				-- -- Force selection via the target system instantly
				-- TargetByName(kuiPlateFrame.nameTextVariable, true)
				
				-- -- If right-clicking, start attacking/auto-shotting immediately
				-- if arg1 == "RightButton" then
					-- AttackTarget()
				-- end
			-- end
		end
	end)
	
	kuiPlateFrame.health:SetScript("OnEnter", function()
		--print("here1")
		if kuiPlateFrame.guid then
			SetMouseoverUnit(kuiPlateFrame.guid)
		end
	end)
	kuiPlateFrame.typeIcon:SetScript("OnEnter", function()
		--print("here1")
		if kuiPlateFrame.guid then
			SetMouseoverUnit(kuiPlateFrame.guid)
		end
	end)
	kuiPlateFrame.power:SetScript("OnEnter", function()
		--print("here1")
		if kuiPlateFrame.guid then
			SetMouseoverUnit(kuiPlateFrame.guid)
		end
	end)
	originalPlateFrame.totem:SetScript("OnEnter", function()
		--print("here1")
		if kuiPlateFrame.guid then
			SetMouseoverUnit(kuiPlateFrame.guid)
		end
	end)
	
	
	kuiPlateFrame.health:SetScript("OnLeave", function()
		--print("here1")
		SetMouseoverUnit()
	end)
	kuiPlateFrame.typeIcon:SetScript("OnLeave", function()
		--print("here1")
		SetMouseoverUnit()
	end)
	kuiPlateFrame.power:SetScript("OnLeave", function()
		--print("here1")
		SetMouseoverUnit()
	end)
	originalPlateFrame.totem:SetScript("OnLeave", function()
		--print("here1")
		SetMouseoverUnit()
	end)
	------------------------------------------------------------ Finishing up --
	-- addon:SendMessage("UnitPlates_PostCreate", kuiPlateFrame)
	
	------------------------------------------------------------

	if originalPlateFrame:IsShown() then
		-- force OnShow
		OnFrameShow(originalPlateFrame)
	else
		kuiPlateFrame:Hide()
	end
end
-----------PLATE CREATION END


---------------------------------------------------------------------- Events --

local function OnPlayerEnteringWorld()
	--set cvars as needed

	--SetCVar("chatBubbles", 1) 
    --SetCVar("chatBubblesParty", 1)
	
	-- Enable overlapping (Disable collision)
    --SetCVar("nameplateAllowOverlap", 1)
	
	--SetCVar("ShowClassColorInNameplate", 0)
	
	--SetCVar("showVKeyCastbar", 1)
	
	-- force enable threat on nameplates - this is a hidden CVar
	--SetCVar("threatWarning", 3)
	
	--UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")[cite: 1]
	
	-- Optional: These are the only other common CVars in 3.3.5
    -- They control how far away plates appear
    -- SetCVar("nameplateMaxDistance", 40)
end

--event processing
local UnitPlatesMainFrame = CreateFrame("Frame", "UnitPlatesMainFrame", UIParent)
UnitPlatesMainFrame:SetFrameStrata("LOW")
UnitPlatesMainFrame.TimeToCheck = 0
UnitPlatesMainFrame.numFrames = 0

UnitPlatesMainFrame:SetScript("OnEvent", function()
	--print("here11111111")
	addonIsLoaded = true

	if event == "ADDON_LOADED" and arg1 == "UnitPlates" then
		addonIsLoaded = true
		--print("----------ADDON_LOADED: "..tostring(arg1))
		UnitPlatesMainFrame:UnregisterEvent("ADDON_LOADED")
		
		if (addonIsLoaded and playerEnteredWorld) then
			--UnitPlatesMainFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
			--CoolHealthBar_OnLoad()
			UPConfigInitUnitPlatesSettings()
		end
	end
	if event == "PLAYER_ENTERING_WORLD" then
		playerEnteredWorld = true
		--print("----------ADDON_LOADED: "..tostring(arg1))
		UnitPlatesMainFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		if (addonIsLoaded and playerEnteredWorld) then
			--UnitPlatesMainFrame:UnregisterEvent("ADDON_LOADED")
			--CoolHealthBar_OnLoad()
			UPConfigInitUnitPlatesSettings()
			OnPlayerEnteringWorld()
		end
	end
end)

UnitPlatesMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
UnitPlatesMainFrame:RegisterEvent("ADDON_LOADED")

UnitPlatesMainFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
UnitPlatesMainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
UnitPlatesMainFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
UnitPlatesMainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
UnitPlatesMainFrame:RegisterEvent("RAID_ROSTER_UPDATE")
--event processing end



--MAIN LOOP
UnitPlatesMainFrame:SetScript("OnUpdate", function()
	local self = UnitPlatesMainFrame
	local elapsed = arg1
    self.TimeToCheck = self.TimeToCheck - elapsed
    if self.TimeToCheck > 0 then 
        return -- We haven't counted down to zero yet so do nothing
    end
    self.TimeToCheck = 0.01 -- We've waited a second so reset the timer
	
	-- find new nameplates
	local frames = {WorldFrame:GetChildren()} -- Pack them into a table
	
	local framesCount = table.getn(frames)
	if framesCount ~= self.numFrames then
		for i = 1, framesCount do
			local f = frames[i]
			--print("x1")
			if UPCoreIsNameplate(f) and not f.kui then
				--print("x2")
				InitFrame(f)
			end
		end
		self.numFrames = framesCount
	end
	
	-- update chat bubbles
	if UnitPlatesSettings and UnitPlatesSettings.enableChatBubbleHandling then
		for _, v in pairs(frames) do
			if UPCoreIsBalloon(v) then
				UPCoreStyleBalloon(v)
			end
		end
	end
	
	
	
	-- FRAME LEVEL SORTING!
	local activePlates = {}
	
	-- 1. Gather all currently visible nameplates
	for i = 1, framesCount do
		local f = frames[i]
		if UPCoreIsNameplate(f) and f:IsShown() and f.kui then
			table.insert(activePlates, f)
		end
	end
	
	-- 2. Sort them cleanly by their Y position on the screen 
	-- (Highest Y is near the top of the monitor, so it should be in the background)
	table.sort(activePlates, function(a, b)
		local _, yA = a:GetCenter()
		local _, yB = b:GetCenter()
		return (yA or 0) > (yB or 0)
	end)
	
	-- 3. Apply strict, non-overlapping frame level sandboxes based on their sorted order
	for i = 1, table.getn(activePlates) do
		local f = activePlates[i]
		local kuiPlateFrame = f.kui
		
		-- Each plate gets an exclusive block of 7 levels.
		-- Plate 1 gets 7-13. Plate 2 gets 14-20. Plate 3 gets 21-27, etc.
		local targetLevel = i * 7 
		
		-- Target priority: If this is your current target, force it to the absolute top safely
		--if f.isTarget or (UnitName("target") == kuiPlateFrame.nameTextVariable) then
		if f.isTarget then
			targetLevel = 120 -- Safe ceiling just below the Vanilla engine cap of 128
		end
		
		-- 4. Apply the stack without any fear of interleaving
		f:SetFrameLevel(targetLevel)
		kuiPlateFrame:SetFrameLevel(targetLevel + 1)
		
		if kuiPlateFrame.health then
			if kuiPlateFrame.health.bgOffsetFrame then
				kuiPlateFrame.health.bgOffsetFrame:SetFrameLevel(targetLevel + 2)
			end
			kuiPlateFrame.health:SetFrameLevel(targetLevel + 3)
			if kuiPlateFrame.health.overlayMask then
				kuiPlateFrame.health.overlayMask:SetFrameLevel(targetLevel + 4)
			end
		end
		
		if kuiPlateFrame.typeIcon then
			if kuiPlateFrame.typeIcon.bgOffsetFrame then
				kuiPlateFrame.typeIcon.bgOffsetFrame:SetFrameLevel(targetLevel + 2)
			end
			kuiPlateFrame.typeIcon:SetFrameLevel(targetLevel + 3)
			if kuiPlateFrame.typeIcon.overlayMask then
				kuiPlateFrame.typeIcon.overlayMask:SetFrameLevel(targetLevel + 4)
			end
		end
		
		if kuiPlateFrame.power then
			kuiPlateFrame.power:SetFrameLevel(targetLevel + 1)
		end
		
		if kuiPlateFrame.classIcon then
			kuiPlateFrame.classIcon:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.aurasContainer then
			kuiPlateFrame.aurasContainer:SetFrameLevel(targetLevel + 5)
			for i = 1, UPConstants.maxAuras do
				if kuiPlateFrame.aurasContainer.auraIcons[i] then
					kuiPlateFrame.aurasContainer.auraIcons[i]:SetFrameLevel(targetLevel + 5)
				end
			end
		end
		
		if kuiPlateFrame.textLayerHost then
			kuiPlateFrame.textLayerHost:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.shootingIcon then
			kuiPlateFrame.shootingIcon:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.combopoints then
			kuiPlateFrame.combopoints:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.questIcon then
			kuiPlateFrame.questIcon:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.petHappiness then
			kuiPlateFrame.petHappiness:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.combatIcon then
			kuiPlateFrame.combatIcon:SetFrameLevel(targetLevel + 5)
		end
		
		if kuiPlateFrame.originalPlateFrame.totem then
			if kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame then
				kuiPlateFrame.originalPlateFrame.totem.bgOffsetFrame:SetFrameLevel(targetLevel + 2)
			end
			kuiPlateFrame.originalPlateFrame.totem:SetFrameLevel(targetLevel + 3)
			if kuiPlateFrame.originalPlateFrame.totem.overlayMask then
				kuiPlateFrame.originalPlateFrame.totem.overlayMask:SetFrameLevel(targetLevel + 4)
			end
		end
	end
	
end)
--MAIN LOOP END