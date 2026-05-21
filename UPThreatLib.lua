--THIS FILE HAS NO MEANING FOR NOW, it's just potential solutions which I will probably never implement

UPThreatLibThreatData = {
	
} -- Global table to hold active combat data
-- Structure: UPThreatLibThreatData["MobGUID"] = { ["PlayerName"] = 1500, ["PetName"] = 800 }

local THREAT_DECAY_TIME = 30 -- Drop mobs from memory after 30 seconds of no updates

-- Refactored for GUID-only storage
function UPThreatLibAddThreat(mobGUID, sourceGUID, amount)
    if not mobGUID or not sourceGUID or amount == 0 then return end
    
    -- Initialize mob entry
    if not UPThreatLibThreatData[mobGUID] then
        UPThreatLibThreatData[mobGUID] = { lastUpdated = GetTime() }
    end
    
    -- Initialize source entry (your GUID or pet's GUID)
    if not UPThreatLibThreatData[mobGUID][sourceGUID] then
        UPThreatLibThreatData[mobGUID][sourceGUID] = 0
    end
    
    -- Add threat directly to the GUID
    UPThreatLibThreatData[mobGUID][sourceGUID] = UPThreatLibThreatData[mobGUID][sourceGUID] + amount
    UPThreatLibThreatData[mobGUID].lastUpdated = GetTime()
end

-- Create the hidden event frame
local UPThreatLibFrame = CreateFrame("Frame")

-- Register the events where damage/healing numbers actually happen
UPThreatLibFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
UPThreatLibFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
UPThreatLibFrame:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS")
UPThreatLibFrame:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")

UPThreatLibFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF") -- Catches your Mend Pet heals
UPThreatLibFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Catches when you drop out of combat
UPThreatLibFrame:RegisterEvent("PLAYER_TARGET_CHANGED") -- Used to check if your target died
-- Note: To track random players, you'd add CHAT_MSG_COMBAT_PARTY_HITS etc.

UPThreatLibFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Left combat
UPThreatLibFrame:RegisterEvent("PLAYER_TARGET_CHANGED") -- Switched targets

-- The Parser
UPThreatLibFrame:SetScript("OnEvent", function()
    -- 1. HANDLE COMBAT STATE RESETS
    -- If you drop combat (or successfully Feign Death), wipe the entire threat table
    -- if event == "PLAYER_REGEN_ENABLED" then
        -- UPThreatLibThreatData = {} 
        -- return
    -- end
    
    -- -- If you change targets and the new target is dead, clean up its specific memory
    -- if event == "PLAYER_TARGET_CHANGED" then
        -- if UnitIsDead("target") then
            -- local deadGUID = UnitGUID("target")
            -- if deadGUID then UPThreatLibThreatData[deadGUID] = nil end
        -- end
        -- return
    -- end

    local message = arg1
    -- local targetGUID = UnitGUID("target") 
    -- if not targetGUID then return end 
    
    local amount = 0
    -- local unitName = nil
    
    -- 2. HANDLE MELEE HITS
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        -- local _, _, dmg = string.find(message, "You hit .+ for (%d+)")
        -- if dmg then 
            -- amount = tonumber(dmg)
            -- unitName = UnitName("player")
        -- else
            -- _, _, dmg = string.find(message, "You crit .+ for (%d+)")
            -- if dmg then
                -- amount = tonumber(dmg)
                -- unitName = UnitName("player")
            -- end
        -- end
    
    -- 3. HANDLE PET HITS
    elseif event == "CHAT_MSG_COMBAT_PET_HITS" then
        -- local petName = UnitName("pet")
        -- if petName then
            -- local _, _, dmg = string.find(message, petName.." hits .+ for (%d+)")
            -- if dmg then
                -- amount = tonumber(dmg)
                -- unitName = petName
            -- else
                -- _, _, dmg = string.find(message, petName.." crits .+ for (%d+)")
                -- if dmg then
                    -- amount = tonumber(dmg)
                    -- unitName = petName
                -- end
            -- end
        -- end
        
    -- 4. HANDLE SPELL DAMAGE & DISTRACTING SHOT
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        -- local _, _, spellName, dmg = string.find(message, "Your (.+) hits .+ for (%d+)")
        -- if not dmg then
            -- _, _, spellName, dmg = string.find(message, "Your (.+) crits .+ for (%d+)")
        -- end
        
        -- if dmg then
             -- amount = tonumber(dmg)
             -- unitName = UnitName("player")
             
             -- -- APPLY BONUS THREAT MODIFIERS
             -- if spellName == "Distracting Shot" then
                 -- -- Distracting shot generates flat bonus threat based on rank.
                 -- -- Assuming Rank 6 (Max level 60) for a flat addition:
                 -- amount = amount + 600 
             -- end
        -- end
        
    -- 5. HANDLE MEND PET (HEALING)
    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then
        -- -- Matches strings like: "Your Mend Pet heals Fluffy for 250."
        -- local _, _, spellName, heal = string.find(message, "Your (.+) heals .+ for (%d+)")
        -- if heal then
            -- amount = tonumber(heal) * 0.5 -- In Vanilla, 1 point of healing = 0.5 threat
            -- unitName = UnitName("player")
            
            -- -- Note: Healing threat is technically divided evenly among ALL mobs you are in combat with.
            -- -- For a solo tracker, attributing the full 0.5 split to your current target is usually sufficient.
        -- end
    end
    
    -- 6. COMMIT THREAT
    -- if amount > 0 and unitName then
        -- UPThreatLibAddThreat(targetGUID, unitName, amount)
    -- end
	
	-- Prune whenever you drop combat or switch targets, 
    -- as those are the most likely times you've finished with a mob.
    -- if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_TARGET_CHANGED" then
        -- UPThreatLibPruneThreatData()
    -- end
end)


-- Function to clean up stale data
function UPThreatLibPruneThreatData()
    local currentTime = GetTime()
    for guid, data in pairs(UPThreatLibThreatData) do
        if (currentTime - data.lastUpdated) > THREAT_DECAY_TIME then
            UPThreatLibThreatData[guid] = nil
        end
    end
end


local PRUNE_INTERVAL = 5 -- Prune every 5 seconds
local timeSinceLastPrune = 0

UPThreatLibFrame:SetScript("OnUpdate", function()
    timeSinceLastPrune = timeSinceLastPrune + arg1 -- arg1 is elapsed time in 1.12
    
    if timeSinceLastPrune >= PRUNE_INTERVAL then
        -- UPThreatLibPruneThreatData()
        timeSinceLastPrune = 0
    end
end)


-- Inside your UpdatePlate(kuiPlateFrame) or OnUpdate loop:
function UPThreatLibGetMyThreatPercentage(mobGUID)
    -- local mobData = UPThreatLibThreatData[mobGUID]
    -- if not mobData then return 0 end
    
    -- local myThreat = mobData[myGUID] or 0
    -- local highestThreat = 0
    
    -- -- Iterate through the sub-table to find the tank
    -- for guid, threat in pairs(mobData) do
        -- if guid ~= "lastUpdated" and threat > highestThreat then
            -- highestThreat = threat
        -- end
    -- end
    
    -- if highestThreat == 0 then return 0 end
    -- return math.min(100, math.floor((myThreat / highestThreat) * 100))
	
	
	-- if UnitName("targettarget") == UnitName("player") then
	-- else
	-- end
	
	-- if IsUnitTargetingMe(mobGUID) then
		-- return 100
	-- end
	
	return 0
end