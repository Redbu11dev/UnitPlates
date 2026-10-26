--WoWTranslate
local UPCompatWoWTranslateNameCachePrefix = "\1wt_name:"
local UPCompatWoWTranslateGuildCachePrefix = "\1wt_name:guild:"

function UPCompatWoWTranslateGetCachedNameTranslation(text)
	local cachedTranslation = nil
	if UnitPlatesSettings and UnitPlatesSettings.enableWoWTranslateSupport and WoWTranslate_API and WoWTranslate_API.IsAvailable() and text and (text ~= '') then
		cachedTranslation = WoWTranslate_CacheGet(UPCompatWoWTranslateNameCachePrefix..text)
		if (not cachedTranslation) or (cachedTranslation == '') then
			--try raw cache, why not?
			cachedTranslation = WoWTranslate_CacheGet(text)
		end
		if (not cachedTranslation) or (cachedTranslation == '') then
			--try from glossary, why not?
			cachedTranslation = WoWTranslateGlossary[text]
		end
	end
	return cachedTranslation
end

function UPCompatWoWTranslateGetCachedGuildTranslation(text)
	local cachedTranslation = nil
	if UnitPlatesSettings and UnitPlatesSettings.enableWoWTranslateSupport and WoWTranslate_API and WoWTranslate_API.IsAvailable() and text and (text ~= '') then		
		if (string.find(text, "'s Pet") or string.find(text, "'s Minion")) then
			local _, _, name, suffix = string.find(text, "^(.-)('s .+)")
			if name and suffix then
				--print(name)   -- Outputs: Blabla
				--print(suffix) -- Outputs: 's Pet
				
				local cachedNameTranslation = WoWTranslate_CacheGet(UPCompatWoWTranslateNameCachePrefix..name)
				if (not cachedNameTranslation) or (cachedNameTranslation == '') then
					--try raw cache, why not?
					cachedNameTranslation = WoWTranslate_CacheGet(name)
				end
				if (not cachedNameTranslation) or (cachedNameTranslation == '') then
					--try from glossary, why not?
					cachedNameTranslation = WoWTranslateGlossary[name]
				end
				
				if (cachedNameTranslation) and (cachedNameTranslation ~= '') then
					cachedTranslation = cachedNameTranslation..suffix
				end
			end
		else
			cachedTranslation = WoWTranslate_CacheGet(UPCompatWoWTranslateGuildCachePrefix..text)
			if (not cachedTranslation) or (cachedTranslation == '') then
				--try raw cache, why not?
				cachedTranslation = WoWTranslate_CacheGet(text)
			end
			if (not cachedTranslation) or (cachedTranslation == '') then
				--try from glossary, why not?
				cachedTranslation = WoWTranslateGlossary[text]
			end
		end
	end
	return cachedTranslation
end
--WoWTranslate END

function UPCompatGetHealthFromMobHealth(guid)
	local current, max
	
	if guid and (MobHealthDB) then
		local index
		if UnitIsPlayer(guid) then
			index = UnitName(guid)
		else
			index = UnitName(guid)..":"..UnitLevel(guid)
		end

		local table = MobHealthDB
		if (not (table and table[index])) then
			table = MobHealthPlayerDB
		end
		if (table and table[index]) then
			local s, e
			local pts
			local pct

			if ( type(table[index]) ~= "string" ) then
				frameHealthBarText:SetText(targethealth.."%")
			end
			s, e, pts, pct = strfind(table[index], "^(%d+)/(%d+)$")

			if ( pts and pct ) then
				pts = pts + 0
				pct = pct + 0
				if( pct ~= 0 ) then
					pointsPerPct = pts / pct
				else
					pointsPerPct = 0
				end
			end
			local currentPct = UnitHealth(guid)
			if ( pointsPerPct > 0 ) then
				current = (currentPct * pointsPerPct) + 0.5
				max = (100 * pointsPerPct) + 0.5
			end
		end
	end
	
	return current, max
end

function UPCompatGetHealthFromShaguTweaks(guid)
	local current, max
	
	if guid and ShaguTweaks and ShaguTweaks.libhealth then
		local name = UnitName(guid)
		local level = UnitLevel(guid)
		local curPct = UnitHealth(guid)
		local cur, maxHp, isReal = ShaguTweaks.libhealth:GetUnitHealthByName(name, level, curPct, 100)
		if isReal then
			current = cur
			max = maxHp
		end
	end
	
	return current, max
end


------------------------------------------------------------------------------------

--pfquest compatibility
-- local UPCompatIsFirstPfQuestLoad = true

local UPComapt_PFQUEST_SWORD_ICON = "Interface\\AddOns\\UnitPlates\\img\\quest\\slay"
local UPComapt_PFQUEST_BAG_ICON = "Interface\\AddOns\\UnitPlates\\img\\quest\\loot"
local UPComapt_PFQUEST_TURNIN_ICON = "Interface\\AddOns\\UnitPlates\\img\\quest\\turnin_yellow"

function UPCompatPfQuestHasHearthDB()
	return type(pfQuestHearthDB) == "table" and type(pfQuestHearthDB.GetQuestTargetsAsync) == "function"
end

--questie-octo compatibility
function UPCompatQuestieOctoIsLoaded()
        return type(QuestieOcto) == "table"
end

function UPCompatQuestieOctoIsReady()
        return UPCompatQuestieOctoIsLoaded()
                and type(QuestieOcto.DatabaseAPI) == "table"
                and type(QuestieOcto.DatabaseAPI.IsReady) == "function"
                and QuestieOcto.DatabaseAPI:IsReady()
                and type(QuestieOcto.Objectives) == "table"
                and QuestieOcto.Objectives.ready == true
                and type(QuestieOcto.QuestLog) == "table"
                and type(QuestieOcto.QuestLog.active) == "table"
                and type(QuestieOcto.QuestModel) == "table"
                and type(QuestieOcto.QuestModel.Get) == "function"
end

-- Questie-Octo's GetCreatureName never returns nil; it falls back to
-- "Creature <id>" when the DB has no name. Filter those placeholders out.
local function UPCompatQuestieOctoCreatureName(unitId)
        local name = QuestieOcto.DatabaseAPI:GetCreatureName(unitId)
        if name and not string.find(name, "^Creature %d+$") then
                return name
        end
        return nil
end
--questie-octo compatibility END

UPCompatPfQuestQuestObjectives = {}

local function UPCompatPfQuestScanQuestObjectivesPfDB()
	-- This path is only valid against the real pfQuest addon; Questie-Octo
    -- also creates a pfDB global, so detection must go through pfQuest's own
    -- pfDatabase table instead.
    if not pfDatabase or not pfDB or not pfDB["quests"] or not pfDB["quests"]["data"] or not pfDB["quests"]["enUS"] then
        return
    end

    UPCompatPfQuestQuestObjectives = {}

    -- if not pfDB or not pfDB["quests"] or not pfDB["quests"]["data"] or not pfDB["quests"]["enUS"] then
        -- return
    -- end

    local activeQuests = {}
    local completedQuestTitles = {}
    
    -- 1. Scan the actual Quest Log
    for qid = 1, GetNumQuestLogEntries() do
        local questTitle, _, _, _, _, complete = GetQuestLogTitle(qid)
        
        if questTitle then
            if complete == 1 then
                -- Quest is finished, flag for turn-in mapping
                completedQuestTitles[questTitle] = true
            else
                -- Quest is active, fetch objectives
                activeQuests[questTitle] = {}
                local numObjectives = GetNumQuestLeaderBoards(qid)
                
                if numObjectives and numObjectives > 0 then
                    for i = 1, numObjectives do
                        local text, objType, finished = GetQuestLogLeaderBoard(i, qid)
                        if text and not finished then
                            local _, _, objName, current, total = string.find(text, "(.*):%s*(%d+)%s*/%s*(%d+)")
                            
                            if objName then
                                objName = string.gsub(objName, "^%s*(.-)%s*$", "%1")
                                table.insert(activeQuests[questTitle], {
                                    objective = objName,
                                    current = tonumber(current) or 0,
                                    total = tonumber(total) or 1
                                })
                            else
                                table.insert(activeQuests[questTitle], {
                                    objective = text,
                                    current = 0,
                                    total = 1
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Match Quest Log against pfDB.
    -- NPC-resolution is ID-driven end to end: for each active quest we resolve
    -- its kill/loot objectives to concrete NPC IDs, then convert ID -> name once
    -- at the end to key the nameplate (the plate itself only exposes a name, so
    -- the final key must be a name -- but the matching is exact-ID, never
    -- substring). This fixes quest 192 ("Shadowmaw Panther slain"), whose DB
    -- obj.U also lists the plain "Panther": a name-substring match would icon the
    -- wrong mob, ID matching cannot.
    for questId, localizedData in pairs(pfDB["quests"]["enUS"]) do
        local questTitle = localizedData["T"]

        if questTitle then
            local questData = pfDB["quests"]["data"][questId]

            if questData then
                -- CASE A: TURN-IN (?)
                if completedQuestTitles[questTitle] then
                    -- questData["end"]["U"] contains the NPC IDs to hand the quest into
                    if questData["end"] and questData["end"]["U"] then
                        for _, unitId in pairs(questData["end"]["U"]) do
                            local npcName = pfDB["units"]["enUS"][unitId]
                            if npcName then
                                -- Assign the turn-in icon
                                UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_TURNIN_ICON
                            end
                        end
                    end

                -- CASE B: ACTIVE OBJECTIVES (Sword/Bag)
                elseif activeQuests[questTitle] then
                    -- Resolve each quest-log objective line to the exact set of NPC
                    -- IDs it refers to, keyed by ID (never by name-substring). The
                    -- objective's bare name (counter + verb stripped) is looked up in
                    -- pfQuest's own name index with an EXACT match, so "Shadowmaw
                    -- Panther slain" resolves to unit 684 only and never to the plain
                    -- "Panther" (736). Unfinished objectives icon their NPCs; finished
                    -- ones are skipped.
                    local swordIDs = {}  -- unitId -> true for unfinished kill objectives
                    local lootItemIDs = {} -- itemId -> true for unfinished loot objectives

                    for _, activeObj in ipairs(activeQuests[questTitle]) do
                        local objStr  = type(activeObj) == "table" and activeObj.objective or activeObj
                        local current = type(activeObj) == "table" and activeObj.current or 0
                        local total   = type(activeObj) == "table" and activeObj.total or 1

                        if type(objStr) == "string" and current < total then
                            -- bare subject: drop trailing ": N/M" counter and verb
                            local base = string.gsub(objStr, "%s*:%s*%d+%s*/%s*%d+$", "")
                            base = string.gsub(base, "%s+slain$", "")
                            base = string.gsub(base, "%s+killed$", "")
                            base = string.gsub(base, "^%s*(.-)%s*$", "%1")

                            -- exact-match lookup against units (kill) and items (loot).
                            -- If the exact form misses, retry the singular ("... Stalkers"
                            -- -> "... Stalker"): the quest log plurals the objective but
                            -- the DB stores the singular creature/item name.
                            local unitIds = pfDatabase:GetIDByName(base, "units")
                            if (not unitIds or not next(unitIds)) and string.find(base, "s$") then
                                unitIds = pfDatabase:GetIDByName(string.sub(base, 1, -2), "units")
                            end
                            if unitIds then
                                for unitId in pairs(unitIds) do
                                    swordIDs[unitId] = true
                                end
                            end
                            local itemIds = pfDatabase:GetIDByName(base, "items")
                            if (not itemIds or not next(itemIds)) and string.find(base, "s$") then
                                itemIds = pfDatabase:GetIDByName(string.sub(base, 1, -2), "items")
                            end
                            if itemIds then
                                for itemId in pairs(itemIds) do
                                    lootItemIDs[itemId] = true
                                end
                            end
                        end
                    end

                    -- KILL OBJECTIVES -> sword on each unfinished objective's NPC IDs
                    if questData["obj"] and questData["obj"]["U"] then
                        for _, unitId in pairs(questData["obj"]["U"]) do
                            if swordIDs[unitId] then
                                local npcName = pfDB["units"]["enUS"][unitId]
                                -- higher-priority icon (turn-in) already set wins
                                if npcName and not UPCompatPfQuestQuestObjectives[npcName] then
                                    UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_SWORD_ICON
                                end
                            end
                        end
                    end

                    -- LOOT OBJECTIVES -> bag on every NPC that drops an unfinished item, by NPC ID.
                    -- Respect pfQuest's "Minimum Item Drop Chance" (mindropchance): only icon
                    -- units whose drop chance meets the configured minimum, matching what the
                    -- pfQuest map shows (SearchItemID skips sub-threshold drops).
                    local minDropChance = tonumber(pfQuest_config and pfQuest_config.mindropchance) or 0
                    if questData["obj"] and questData["obj"]["I"] then
                        for _, itemId in pairs(questData["obj"]["I"]) do
                            if lootItemIDs[itemId] then
                                local itemData = pfDB["items"]["data"][itemId]
                                if itemData and itemData["U"] then
                                    for unitId, chance in pairs(itemData["U"]) do
                                        if (chance or 0) >= minDropChance then
                                            local npcName = pfDB["units"]["enUS"][unitId]
                                            if npcName and not UPCompatPfQuestQuestObjectives[npcName] then
                                                UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_BAG_ICON
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function UPCompatPfQuestScanQuestObjectivesQuestieOcto()
    UPCompatPfQuestQuestObjectives = {}

    if not UPCompatQuestieOctoIsReady() then
        return
    end

    -- Questie-Octo's QuestLog.active is the authoritative set of quests the
    -- player currently has, keyed by questID, with .complete and .failed.
    for questID, state in pairs(QuestieOcto.QuestLog.active) do
        if state and not state.failed then

            -- CASE A: TURN-IN (?)
            if state.complete then
                local q = QuestieOcto.QuestModel:Get(questID)
                if q and q.finishes and q.finishes.creature then
                    for _, unitId in pairs(q.finishes.creature) do
                        local npcName = UPCompatQuestieOctoCreatureName(unitId)
                        if npcName then
                            -- Turn-in always wins; assign unconditionally
                            UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_TURNIN_ICON
                        end
                    end
                end

            -- CASE B: ACTIVE OBJECTIVES (Sword/Bag)
            else
                -- byQuest[questID] is Questie-Octo's live-resolved objective map:
                -- creature kills and item loot sources already matched against
                -- the native quest log, each with a .complete flag.
                local resolved = QuestieOcto.Objectives.byQuest[questID]
                if resolved then

                    -- KILL OBJECTIVES
                    for _, entry in pairs(resolved.creature or {}) do
                        if not entry.complete then
                            local npcName = UPCompatQuestieOctoCreatureName(entry.id)
                            if npcName and not UPCompatPfQuestQuestObjectives[npcName] then
                                UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_SWORD_ICON
                            end
                        end
                    end

                    -- LOOT OBJECTIVES
                    for _, item in pairs(resolved.item or {}) do
                        if not item.complete then
                            for _, source in pairs(item.sources or {}) do
                                if source.kind == "creature" then
                                    local npcName = UPCompatQuestieOctoCreatureName(source.id)
                                    if npcName and not UPCompatPfQuestQuestObjectives[npcName] then
                                        UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_BAG_ICON
                                    end
                                end
                            end
                        end
                    end

                end
            end
        end
    end
end

-- Dispatcher: prefer whichever quest addon is actually present.
-- pfQuest takes priority when both are somehow loaded.
local function UPCompatPfQuestScanQuestObjectives()
    if pfDatabase then
        UPCompatPfQuestScanQuestObjectivesPfDB()
    elseif UPCompatQuestieOctoIsLoaded() then
        UPCompatPfQuestScanQuestObjectivesQuestieOcto()
    end
end

-- local function UPCompatPfQuestScanQuestObjectives()
    -- UPCompatPfQuestQuestObjectives = {}

    -- if not pfDB or not pfDB["quests"] or not pfDB["quests"]["data"] or not pfDB["quests"]["enUS"] then
        -- return
    -- end

    -- local activeQuests = {}
    
    -- -- 1. Scan the actual Quest Log
    -- for qid = 1, GetNumQuestLogEntries() do
        -- local questTitle, _, _, _, _, _, complete = GetQuestLogTitle(qid)
        -- if questTitle and complete ~= 1 then
            -- activeQuests[questTitle] = {}
            -- local numObjectives = GetNumQuestLeaderBoards(qid)
			
			-- if (numObjectives == nil) or numObjectives < 1 then
				-- --do nothing
			-- else
				-- for i = 1, numObjectives do
					-- local text, objType, finished = GetQuestLogLeaderBoard(i, qid)
					-- if text and not finished then
						-- -- 1.12 regex is picky; we match the name and the numbers
						-- local _, _, objName, current, total = string.find(text, "(.*):%s*(%d+)%s*/%s*(%d+)")
						
						-- if objName then
							-- objName = string.gsub(objName, "^%s*(.-)%s*$", "%1") -- Trim whitespace
							-- table.insert(activeQuests[questTitle], {
								-- objective = objName,
								-- current = tonumber(current) or 0,
								-- total = tonumber(total) or 1
							-- })
						-- else
							-- -- FALLBACK: If it's a "Talk to" or "Special" objective without 0/1 numbers
							-- table.insert(activeQuests[questTitle], {
								-- objective = text,
								-- current = 0,
								-- total = 1
							-- })
						-- end
					-- end
				-- end
			-- end
        -- end
    -- end

    -- -- 2. Match Quest Log against pfDB
    -- for questId, localizedData in pairs(pfDB["quests"]["enUS"]) do
        -- local questTitle = localizedData["T"]

        -- if questTitle and activeQuests[questTitle] then
            -- local questData = pfDB["quests"]["data"][questId]
            -- if questData and questData["obj"] then
                
				-- -- CASE A: KILL OBJECTIVES
				-- if questData["obj"]["U"] then
					-- for _, unitId in pairs(questData["obj"]["U"]) do
						-- local targetName = pfDB["units"]["enUS"][unitId]
						-- if targetName and activeQuests[questTitle] then
							-- for _, activeObj in ipairs(activeQuests[questTitle]) do
								-- -- VITAL SAFETY CHECK
								-- local objStr = type(activeObj) == "table" and activeObj.objective or activeObj
								-- local current = type(activeObj) == "table" and activeObj.current or 0
								-- local total   = type(activeObj) == "table" and activeObj.total or 1

								-- if type(objStr) == "string" then
									-- -- FIX: Use string.gsub(string, pattern, replacement) instead of string:gsub()
									-- local objNameBase = string.gsub(objStr, " slain$", "")
									-- objNameBase = string.gsub(objNameBase, " killed$", "")
									
									-- if objNameBase == targetName or string.find(objStr, targetName, 1, true) then
										-- if current < total then
											-- UPCompatPfQuestQuestObjectives[targetName] = UPComapt_PFQUEST_SWORD_ICON
										-- end
									-- end
								-- end
							-- end
						-- end
					-- end
				-- end

				-- -- CASE B: LOOT OBJECTIVES
				-- if questData["obj"]["I"] then
					-- for _, itemId in pairs(questData["obj"]["I"]) do
						-- local itemName = pfDB["items"]["enUS"][itemId]
						-- local itemData = pfDB["items"]["data"][itemId]

						-- if itemName and itemData and itemData["U"] then
							-- for unitId, _ in pairs(itemData["U"]) do
								-- local npcName = pfDB["units"]["enUS"][unitId]
								-- if npcName and activeQuests[questTitle] then
									-- for _, activeObj in ipairs(activeQuests[questTitle]) do
										-- local objStr = type(activeObj) == "table" and activeObj.objective or activeObj
										-- local current = type(activeObj) == "table" and activeObj.current or 0
										-- local total   = type(activeObj) == "table" and activeObj.total or 1

										-- -- FIX: Use string.find(string, ...) instead of string:find()
										-- if type(objStr) == "string" and string.find(objStr, itemName, 1, true) then
											-- if current < total then
												-- UPCompatPfQuestQuestObjectives[npcName] = UPComapt_PFQUEST_BAG_ICON
											-- end
										-- end
									-- end
								-- end
							-- end
						-- end
					-- end
				-- end
                
            -- end
        -- end
    -- end
	
	-- -- UPCompatIsFirstPfQuestLoad = false
-- end

-- Variables for pfquest debouncing
local UPCompatPfQuestPendingScan = false
local UPCompatPfQuestDebounceTimer = 0

-- Questie-Octo message-bus listener. QuestieOcto:RegisterMessage expects an
-- owner table plus a method name; it calls owner[method](owner, ...).
local UPCompatQuestieOctoListener = {}
local UPCompatQuestieOctoRegistered = false

function UPCompatQuestieOctoListener.OnObjectivesUpdated(self)
        UPCompatPfQuestPendingScan = true
        UPCompatPfQuestDebounceTimer = 0
end

local function UPCompatQuestieOctoRegisterMessages()
        if UPCompatQuestieOctoRegistered then return end
        if type(QuestieOcto) ~= "table" or type(QuestieOcto.RegisterMessage) ~= "function" then return end

        -- OBJECTIVES_READY  = full objective rebuild finished
        -- OBJECTIVES_CHANGED = individual quest objectives changed
        QuestieOcto:RegisterMessage("OBJECTIVES_READY", UPCompatQuestieOctoListener, "OnObjectivesUpdated")
        QuestieOcto:RegisterMessage("OBJECTIVES_CHANGED", UPCompatQuestieOctoListener, "OnObjectivesUpdated")
        UPCompatQuestieOctoRegistered = true
end

local function UPCompatPfQuestScanWithDebounce()
	-- 1. Do nothing if no scan has been requested
	if not UPCompatPfQuestPendingScan then return end
	
	-- -- 2. Ensure pfQuest has finished building its localization caches
	-- if not (pfDatabase and pfDatabase.localized) then return end
	
	-- 2. Ensure the active quest addon has finished building its caches
	if pfDatabase then
			if not pfDatabase.localized then return end
	elseif UPCompatQuestieOctoIsLoaded() then
			if not UPCompatQuestieOctoIsReady() then return end
	else
			return
	end

	-- 3. Run the debounce timer (arg1 in Vanilla WoW is elapsed time in seconds)
	UPCompatPfQuestDebounceTimer = UPCompatPfQuestDebounceTimer + arg1
	
	-- 4. If 0.2 seconds have passed since the LAST event fired, execute the scan
	if UPCompatPfQuestDebounceTimer > 0.2 then
		UPCompatPfQuestPendingScan = false
		UPCompatPfQuestDebounceTimer = 0
		
		UPCompatPfQuestScanQuestObjectives()
	end
end

local function UPCompatPfQuestOnEvent(event)
	-- Late-bind to Questie-Octo's message bus. Attempted on every event but
	-- only actually registers once, and only after Questie-Octo has loaded.
	UPCompatQuestieOctoRegisterMessages()

	if event == "QUEST_LOG_UPDATE" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		
		-- Assuming you track these variables elsewhere as intended
		if UnitPlatesAddonIsLoaded and UnitPlatesPlayerEnteredWorld then
			
			-- Instead of running the heavy scan directly, we queue it and reset the timer.
			-- This safely merges 15 simultaneous login events into 1 single scan.
			UPCompatPfQuestPendingScan = true
			UPCompatPfQuestDebounceTimer = 0 
			
		end
	end
end

--pfquest compatibility END


--UPCompatFrame
local UPCompatFrame = CreateFrame("Frame", "UPCompatFrameFrame", UIParent)
UPCompatFrame:SetFrameStrata("LOW")
UPCompatFrame.TimeToCheck = 0
UPCompatFrame.numFrames = 0

UPCompatFrame:RegisterEvent("QUEST_LOG_UPDATE")
UPCompatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
UPCompatFrame:RegisterEvent("ZONE_CHANGED")
UPCompatFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

--UPCompatFrame:RegisterEvent("ADDON_LOADED")

UPCompatFrame:SetScript("OnUpdate", function()
	UPCompatPfQuestScanWithDebounce()
end)

UPCompatFrame:SetScript("OnEvent", function()
	UPCompatPfQuestOnEvent(event)
end)
--UPCompatFrame END