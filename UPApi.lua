UPApiScanTool = CreateFrame( "GameTooltip", "UPApiScanTool", nil, "GameTooltipTemplate" )
UPApiScanTool:SetOwner( WorldFrame, "ANCHOR_NONE" )
UPApiScanToolTextLine2 = UPApiScanToolTextLeft2 -- This is the line with <[Player]'s Pet>

--PUBLIC
function UPApiGetGuildText(guid)
	UPApiScanTool:ClearLines()
	UPApiScanTool:SetUnit(guid)
	local scanTextLine2Text = UPApiScanToolTextLine2:GetText()
	
	local guild = nil
	
	if not string.find(scanTextLine2Text, "Level") then
		--local owner, _ = string.split("'",ownerText)
		guild = scanTextLine2Text
		-- if guild then
			-- print("guild: "..guild)
		-- end
	end
	
	if not guild then
		--then get guild from api
		guild = GetGuildInfo(guid)
	end
	
	return guild
end

--PUBLIC
function UPApiIsPet(guid)
	UPApiScanTool:ClearLines()
	UPApiScanTool:SetUnit(guid)
	local scanTextLine2Text = UPApiScanToolTextLine2:GetText()
	if not string.find(scanTextLine2Text, "Level") then
		if scanTextLine2Text and (string.find(scanTextLine2Text, "'s Pet") or string.find(scanTextLine2Text, "'s Minion")) then
			return true
		end
	end
	return false
end

local UPApiActionSlotScanner = CreateFrame("GameTooltip", "UPApiActionSlotScanner", nil, "GameTooltipTemplate")
UPApiActionSlotScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
UPApiActionSlotScannerTextLeft1 = UPApiActionSlotScannerTextLeft1

--PUBLIC
function UPApiIsTargetInShootingDistance()
	for i = 1, 120 do
		UPApiActionSlotScanner:ClearLines()
        -- This tells the tooltip to load the information from action slot 'i'
        UPApiActionSlotScanner:SetAction(i)
		
		-- In 1.12, the first line of the tooltip is the name of the spell/item
        local text = UPApiActionSlotScannerTextLeft1:GetText()
        
        if text == "Auto Shot" then
            --print("Found Auto Shot at slot " .. i)
			--return IsUsableAction(i) and IsActionInRange(i)
			return IsActionInRange(i) == 1
        end
	end
	
	return false
end

---------------------------------UNSORTED

function UPApiIsTarget(guid)
	local unitExists, unitExistsGuid = UnitExists("target")	
	return unitExistsGuid and (unitExistsGuid == guid)
end

function UPApiGetCreatureType(guid)
	local creatureType = UnitCreatureType(guid)
	--most probably just an unknown type
	if (guid and (not creatureType)) then
		creatureType = "UNKNOWN"
	end
	if creatureType and creatureType ~= '' then
		creatureType = string.upper(creatureType)
	end
	
	return creatureType
end

function UPApiGetClassRaceGender(guid)
	local class = UnitClass(guid)
	local race = UnitRace(guid)
	if race then
		race = string.gsub(string.lower(race), " ", "")
		--print("name: "..name.." race: "..race)
	end
	local gender = UnitSex(guid)
	
	return class, race, gender
end

function UPApiGetLevelDifficultyColor(levelNumber)
	local levelDifficultyColor = {r = 0.9, g = 0.0, b = 0.0, a = 0.9} --defaults to red
	if levelNumber > 0 then
		levelDifficultyColor = GetDifficultyColor(levelNumber)
	end
	return levelDifficultyColor
end

function UPApiIsGrayLevel(levelNumber)
	local levelDifficultyColor = UPApiGetLevelDifficultyColor(levelNumber)
	if ((levelDifficultyColor.r == 0.5) and (levelDifficultyColor.g == 0.5) and (levelDifficultyColor.b == 0.5)) then
		return true
	else
		return false
	end
end


---------------------------------UNSORTED END

---------------TOTEMS
local UPApiTotemNameToIconList = {
  ["Disease Cleansing Totem"] = "spell_nature_diseasecleansingtotem",
  ["Earth Elemental Totem"] = "spell_nature_earthelemental_totem",
  ["Earthbind Totem"] = "spell_nature_strengthofearthtotem02",
  ["Fire Elemental Totem"] = "spell_fire_elemental_totem",
  ["Fire Nova Totem"] = "spell_fire_sealoffire",
  ["Fire Resistance Totem"] = "spell_fireresistancetotem_01",
  ["Flametongue Totem"] = "spell_nature_guardianward",
  ["Frost Resistance Totem"] = "spell_frostresistancetotem_01",
  ["Grace of Air Totem"] = "spell_nature_invisibilitytotem",
  ["Grounding Totem"] = "spell_nature_groundingtotem",
  ["Healing Stream Totem"] = "Inv_spear_04",
  ["Magma Totem"] = "spell_fire_selfdestruct",
  ["Mana Spring Totem"] = "spell_nature_manaregentotem",
  ["Mana Tide Totem"] = "spell_frost_summonwaterelemental",
  ["Nature Resistance Totem"] = "spell_nature_natureresistancetotem",
  ["Poison Cleansing Totem"] = "spell_nature_poisoncleansingtotem",
  ["Searing Totem"] = "spell_fire_searingtotem",
  ["Sentry Totem"] = "spell_nature_removecurse",
  ["Stoneclaw Totem"] = "spell_nature_stoneclawtotem",
  ["Stoneskin Totem"] = "spell_nature_stoneskintotem",
  ["Strength of Earth Totem"] = "spell_nature_earthbindtotem",
  ["Totem of Wrath"] = "spell_fire_totemofwrath",
  ["Tremor Totem"] = "spell_nature_tremortotem",
  ["Windfury Totem"] = "spell_nature_windfury",
  ["Windwall Totem"] = "spell_nature_earthbind",
  ["Wrath of Air Totem"] = "spell_nature_slowingtotem"
}

function UpApiGetTotemIconForName(name)
	for totem, icon in pairs(UPApiTotemNameToIconList) do
		if string.find(name, totem) then
			return ("Interface\\Icons\\"..icon)
		end
	end
	return nil
	--return ("Interface\\Icons\\".."spell_nature_slowingtotem")
end

function UPApiIsTotem(name)
	local totemIcon = UpApiGetTotemIconForName(name)
	if totemIcon then
		return true
	end
	return false
	--return true
end
---------------TOTEMS END

------------------------------AURAS

local UPApiGuidAurasCache = {}

-- A helper to get or create the sub-table for a GUID
local function UPApiGetGuidAurasCache(guid)
    if not UPApiGuidAurasCache[guid] then
        UPApiGuidAurasCache[guid] = {}
    end
    return UPApiGuidAurasCache[guid]
end

local function UPApiPutIntoAurasCache(guid, spellId, name, texture, count, debuffType, duration, startTime, expirationTime, isDebuff)
    if not guid or not name then return end
    
    local cache = UPApiGetGuidAurasCache(guid)
    
    cache[name] = {
        spellId = spellId,
		name = name,
		texture = texture,
		count = count,
		debuffType = debuffType,
		duration = duration,
		startTime = startTime,
		expirationTime = expirationTime,
		isDebuff = isDebuff
    }
end

local function UPApiSyncAurasCacheWithActual(guid)
	local actualUnitAuras = {} --both debuffs and buffs in case buff/debuff gets assigned wrong
	for i = 1, 16 do
		local texture, count, debuffType, spellId
		texture, count, spellId = UnitBuff(guid, i)
		-- In WoW, the loop continues until it hits a nil name (end of auras)
		if not texture then 
			break 
		end
		
		local name, rank, icon, spellMinRange, spellMaxRange = SpellInfo(spellId)
		
		actualUnitAuras[name] = { 
			spellId = spellId,
			name = name,
			texture = texture,
			count = count,
			debuffType = debuffType,
			isDebuff = false
		}
	end
	for i = 1, 16 do
		local texture, count, debuffType, spellId
		texture, count, debuffType, spellId = UnitDebuff(guid, i)
		-- In WoW, the loop continues until it hits a nil name (end of auras)
		if not texture then 
			break 
		end
		
		local name, rank, icon, spellMinRange, spellMaxRange = SpellInfo(spellId)
		
		actualUnitAuras[name] = { 
			spellId = spellId,
			name = name,
			texture = texture,
			count = count,
			debuffType = debuffType,
			isDebuff = true
		}
	end
	
	-- SYNC: Remove from Cache if not on Unit
    local cache = UPApiGetGuidAurasCache(guid)
    for cachedName, cachedData in pairs(cache) do
        if not actualUnitAuras[cachedName] then
			-- The aura is in our cache but no longer on the unit (faded/dispelled)
			cache[cachedName] = nil 
		else
			-- It's still there! Update the count/texture/isDebuff in case they changed
			cachedData.count = actualUnitAuras[cachedName].count
			cachedData.texture = actualUnitAuras[cachedName].texture
			cachedData.isDebuff = actualUnitAuras[cachedName].isDebuff
		end
    end
	
	-- -- INFINITE DURATION HANDLER: Add paladin auras, warrior stances etc.
    for actualName, actualData in pairs(actualUnitAuras) do
        -- If it's not in our cache yet, check if it's an "Infinite" spell
		--print("adding "..actualName.." as infinite aura")
        --if not cache[actualName] and UPLibAuraDurationsByRank[actualName] and (UPLibAuraDurationsByRank[actualName][0] == -1) then
		if not cache[actualName] and (UPLibAuraDurationsGetAuraDuration(actualName, 0) == -1) then
			--guid, spellId, name, texture, count, debuffType, duration, startTime, expirationTime, isDebuff
			--print("adding "..actualName.." as infinite aura")
            UPApiPutIntoAurasCache(
                guid, 
                actualData.spellId, 
                actualName, 
                actualData.texture, 
                actualData.count, 
                nil, -- debuffType
                -1,   -- duration (-1 = infinite)
                -1, -- startTime
                -1,   -- expirationTime (-1 = never)
                isDebuff
            )
        end
    end
end

local function UPApiCacheInAuraIfValid(guid, auraName, isDebuff)
	--get spell info
	--check for unit debuffs with same name
	for i = 1, 16 do
		local texture, count, debuffType, spellId, add1, add2, add3, add4 = UnitDebuff(guid, i)
		local name, rank, icon, spellMinRange, spellMaxRange = SpellInfo(spellId)
		if rank == nil or rank == '' then
			rank = "Rank 0"
		end
		--parse rank into number
		local _, _, rankDigits = string.find(rank, "(%d+)")
		local rankNumber = tonumber(rankDigits)
		
		if auraName == name then
			--rank can be empty string (then use 0)
			-- print("rank: "..tostring(rank))
			-- print("texture: "..tostring(texture))
			-- print("count: "..tostring(count))
			
			local duration = UPLibAuraDurationsGetAuraDuration(name, rankNumber)
			if duration == nil then
				--exit early
				break
			end			
			--duration is in seconds, GetTime() is also in seconds, floating (like 9.53 seconds)
			--put into cache
			local startTime = GetTime()
			local expirationTime = startTime+duration
			UPApiPutIntoAurasCache(guid, spellId, name, texture, count, debuffType, duration, startTime, expirationTime, isDebuff)
			
			--break loop (found it)
			break
		end
	end
	
	--now also compare actual auras with this, and remove if it is not in actual auras
	UPApiSyncAurasCacheWithActual(guid)
	
end

--PUBLIC
function UpApiGetUnitAuras(guid, getBuffs, onlyMineBuffs, getDebuffs, onlyMineDebuffs, ignoredBuffNames, ignoredDebuffNames)	
	UPApiSyncAurasCacheWithActual(guid)

	local maxAuras = 80 -- who knows, maybe it could be more than 16 now
	local unitBuffs = {}
	local unitDebuffs = {}
	
	if not guid or not UnitExists(guid) then
		return nil
	end
	
	local cache = UPApiGetGuidAurasCache(guid)
	for cachedName, cachedData in pairs(cache) do
		local spellId = cachedData.spellId
		local name = cachedData.name
		local texture = cachedData.texture
		local count = cachedData.count
		local debuffType = cachedData.debuffType
		local duration = cachedData.duration
		local startTime = cachedData.startTime
		local expirationTime = cachedData.expirationTime
		local isDebuff = cachedData.isDebuff
		
		if getBuffs and (not isDebuff) then
			local nameIsIgnored = false
			for _, ignoredBuffName in ipairs(ignoredBuffNames) do
				if (string.upper(name) == string.upper(ignoredBuffName)) then
					nameIsIgnored = true
					break
				end
			end
			
			if not nameIsIgnored then
				table.insert(unitBuffs, {
					spellId = spellId,
					name = name,
					texture = texture,
					count = count,
					debuffType = debuffType,
					duration = duration,
					startTime = startTime,
					expirationTime = expirationTime,
					isDebuff = false
				})
			end
		end
		
		if getDebuffs and (isDebuff) then
			local nameIsIgnored = false
			for _, ignoredDebuffName in ipairs(ignoredDebuffNames) do
				if (string.upper(name) == string.upper(ignoredDebuffName)) then
					nameIsIgnored = true
					break
				end
			end
			
			if not nameIsIgnored then
				table.insert(unitDebuffs, {
					spellId = spellId,
					name = name,
					texture = texture,
					count = count,
					debuffType = debuffType,
					duration = duration,
					startTime = startTime,
					expirationTime = expirationTime,
					isDebuff = true
				})
			end
		end
	end
	
	--sort by expirationTime DESC
	table.sort(unitBuffs, function(a, b)
		return a.expirationTime > b.expirationTime
	end)
	
	--sort by expirationTime DESC
	table.sort(unitDebuffs, function(a, b)
		return a.expirationTime > b.expirationTime
	end)
	
	local allAuras = {}
	
	-- Copy Buffs
	for _, data in ipairs(unitBuffs) do
		table.insert(allAuras, data)
	end
	
	-- Copy Debuffs
	for _, data in ipairs(unitDebuffs) do
		table.insert(allAuras, data)
	end
	
	return allAuras
end

------------------------------AURAS END

--CASTING
local UPApiCastCache = {}

-- -- Helper to get or create a cache entry
local function UPApiGetCastEntry(guid)
    if not UPApiCastCache[guid] then
        UPApiCastCache[guid] = { 
            name = nil,
			icon = nil,
            startTime = 0, 
            endTime = 0, 
            interruptible = true, 
            isChannel = false 
        }
    end
    return UPApiCastCache[guid]
end

--PUBLIC
function UPApiUnitCastingInfo(guid)
	local spellName = nil
	local spellNameSecondary = nil
	local spellDisplayName = nil
	local spellIcon = nil
	local spellStartTimeMillis = nil
	local spellEndTimeMillis = nil
	local spellIsTradeSkill = nil
	local isChannel = nil
	
	local entry = UPApiGetCastEntry(guid)
	
	spellName = entry.name
	spellIcon = entry.icon
	spellStartTimeMillis = entry.startTime
	spellEndTimeMillis = entry.endTime
	isChannel = entry.isChannel
	
	return spellName, spellNameSecondary, spellDisplayName, spellIcon, spellStartTimeMillis, spellEndTimeMillis, spellIsTradeSkill, isChannel
end
--CASTING END



------------------------------ApiFrame
local UPApiFrame = CreateFrame("Frame", "UPApiFrameFrame", UIParent)
UPApiFrame:SetFrameStrata("LOW")
UPApiFrame.TimeToCheck = 0
UPApiFrame.numFrames = 0

UPApiFrame:RegisterEvent("RAW_COMBATLOG")
UPApiFrame:RegisterEvent("UNIT_CASTEVENT")

UPApiFrame:SetScript("OnEvent", function()
	if event == "RAW_COMBATLOG" then
		--arg1 is event name
		--if string.find(arg2, "Rend") then
		--if string.find(arg2, "fades") then
		-- if string.find(arg2, "gain") or string.find(arg2, "afflicted") then
			-- print("event: "..tostring(event))
			-- print("arg1: "..tostring(arg1))--guid
			-- print("arg2: "..tostring(arg2))
			-- print("arg3: "..tostring(arg3))
			-- print("arg4: "..tostring(arg4))
			-- print("arg5: "..tostring(arg5))
		-- end
		
		if arg1 == "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS" 
		or arg1 == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS" 
		or arg1 == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"
		then
			local _, _, guid, auraName = string.find(arg2, "^(0x%x+)%sgains%s([^%d].-)%.$")
			if guid and auraName then
				-- print("assumed buff gain: ")
				-- print("guid: "..tostring(guid))
				-- print("auraName: "..tostring(auraName))
				
				--put it into cache here
				UPApiCacheInAuraIfValid(guid, auraName, false)	
			end
		end
		
		if arg1 == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" 
		or arg1 == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" 
		or arg1 == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"
		then
			local _, _, guid, auraName = string.find(arg2, "^(0x%x+)%sis%safflicted%sby%s(.-)%.$")
			if guid and auraName then
				-- print("assumed debuff gain: ")
				-- print("guid: "..tostring(guid))
				-- print("auraName: "..tostring(auraName))
				
				--put it into cache here
				UPApiCacheInAuraIfValid(guid, auraName, true)				
			end
		end
	end
	
	if event == "UNIT_CASTEVENT" then
		local casterGUID, targetGUID, eventType, spellId, duration = arg1, arg2, arg3, arg4, arg5
	
		if eventType == "MAINHAND" or eventType == "OFFHAND" then return nil end
		
		local casterName = UnitName(casterGUID)
		local targetName = UnitName(casterGUID)
		
		local spellName, spellRank, spellTexture, spellMinRange, spellMaxRange = SpellInfo(spellId)
		
		-- print("OnUnitCastEvent")
		-- print("casterName: ".. casterName)
		-- print("casterGUID: ".. casterGUID)
		-- print("targetGUID: ".. targetGUID)
		-- print("eventType: ".. eventType)
		-- print("spellId: ".. spellId)
		-- print("spellName: ".. spellName)
		-- print("spellTexture: ".. spellTexture)
		-- print("duration: ".. duration)
		
		local entry = UPApiGetCastEntry(casterGUID)
		
		local currTime = GetTime() * 1000
		if eventType == "START" or eventType == "CHANNEL" then
			entry.name = spellName
			entry.icon = spellTexture
			entry.startTime = currTime
			entry.endTime = currTime + duration
			entry.isChannel = (eventType == "CHANNEL")
			entry.interruptible = true -- SuperWoW doesn't always provide this in arg, 
									   -- you may need a separate list for boss spells
		elseif eventType == "CAST" then
			--entry.name = nil
			--entry.endTime = 0
		elseif eventType == "FAIL" then
			-- Clear the cast
			entry.name = nil
			entry.endTime = 0
		end
	end
end)
------------------------------ApiFrame END

