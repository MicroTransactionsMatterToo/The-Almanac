-- Debugging --

-- Mod Namespace --
Almanac = {}

-- Fields --
Almanac.__initialised = false
Almanac.PreviousFrame = {
    ["item_count"] = 0,
    ["held_items"] = {}
}
Almanac.CurrentFrame = {
    ["item_count"] = 0,
    ["held_items"] = {}
}
Almanac.Player = nil
Almanac.Conflicts = {
    [118] = { -- Brimstone --
        369, -- Continuum --
        410, -- Evil Eye --
        374 , -- Holy Light --
        494, -- Jacob's Ladder --
        115, -- Ouija Board --
        379, -- Pupula Duplex --
        104, -- The Parasite --
    },
    [69] = { -- Chocolate Milk --
        222 -- Anti-Gravity --
    },
    [316] = { -- Cursed Eye --
        222 -- Anti-Gravity --
    },
    [329] = { -- Ludovico Technique --
        222, -- Anti-Gravity --
        224, -- Cricket's Body --
        149, -- Ipecac --
        397 -- Tractor Beam --
    },
    [186] = { -- Epic Fetus -- 
        222, -- Anti-Gravity --
        316, -- Cursed Eye --
        118, -- Brimstone --
        114, -- Mom's Knife --
        366, -- Scatter Bombs --
        329, -- Ludovico Technique --
        233 -- Tiny Planet --
    },
    [114] = { -- Mom's Knife -- 
        52, -- Dr. Fetus --
        401, -- Explosivo --
        462, -- Eye of Belial --
        374, -- Holy Light --
        317, -- Mysterious Liquid --
        104, -- The Parasite --
        221, -- Rubber Cement --
        305 -- Scorpio --
    },
    [229] = { -- Monstro's Lung --
        222, -- Anti-Gravity --
        316, -- Cursed Eye --
        394 -- Marked --
    }
}

-- ## Capped Stack ## --
Queue = {}

--- Returns a new Queue, of given length
-- @param length Maximum number of items allowed in queue
function Queue.New(length)
    local queue = {}
    queue.first = 0
    queue.last = length

    --- Add item and pop last item
    -- @param value value to add
    function queue:queue(value)
        queue:pushleft(value)
        queue:popright()
    end

    --- Add item to the left of the queue
    -- @param value value to add
    function queue:pushleft(value)
        local first = queue.first - 1
        queue.first = first
        queue[first] = value
    end 

    --- Add item to the right of the queue
    -- @param value value to add
    function queue:pushright(value)
        local last = queue.last + 1
        queue.last = last
        queue[last] = vale
    end

    --- Remove item from the left of the queue
    function queue:popleft()
        local first = queue.first
        if first > queue.last then error("Queue is Empty") end
        local value = queue[first]
        queue[first] = nil
        queue.first = first + 1
        return value
    end

    --- Remove item from the left of the queue
    function queue:popright()
        local last = queue.last
        if queue.first > queue.last then error("Queue is empty") end
        local value = queue[last]
        queue[last] = nil
        queue.last = last - 1
        return value
    end

    --- Prints the queue
    function queue:print()
        for index = queue.first, queue.last do
            if queue[index] ~= nil then
                print(queue[index])
            end
        end
    end

    return queue
end 







local mod = RegisterMod("The Almanac", 1)

-- Logging Subsystem --
local log = Queue.New(20)

--- Handles UI side of logging
-- @param _mod placeholder for callback
local function LogUI(_mod)
    local height = 15
    for index = log.first, log.last do
        if log[index] ~= nil then
            Isaac.RenderText(log[index], 50, height, 255, 255, 255, 255)
            height = height + 15
        end
    end

end

--- Logs the given message to screen and log file
-- @param message string to display
local function Log(message)
    log:queue(message)
    Isaac.DebugString(string.format("[MOD]: %s", message))
end




function Almanac:Initialise(_fromsave)
    Log("Beginning Initialisation")
    Almanac.Player = Isaac.GetPlayer(0)
    Almanac.PreviousFrame["item_count"] = Almanac.Player:GetCollectibleCount()
    Almanac.CurrentFrame = Almanac.PreviousFrame
    for itemID = 1,525 do
        if Almanac.Player:GetCollectibleNum(itemID) > 0 then
            Almanac.PreviousFrame["held_items"][itemID] = Almanac.Player:GetCollectibleNum(itemID)
            Isaac.DebugString(string.format("Player now holds collectible with id of %d", itemID))
        end
    end
    Log(string.format("%d | %d", Almanac.Player:GetCollectibleCount(), Almanac.PreviousFrame["item_count"]))
    Almanac.__initialised = true
    Log("Initialisation Finished")
end

function Almanac:UpdateValues()
    if Almanac.__initialised then
        Almanac.PreviousFrame = Almanac.CurrentFrame
        if Almanac.PreviousFrame["item_count"] ~= Almanac.Player:GetCollectibleCount() then
            Log("Player's Collectible count has changed, updating held_items and item_count")
            Almanac.CurrentFrame["item_count"] = Almanac.Player:GetCollectibleCount()
            for itemID = 1,525 do
                if Almanac.Player:GetCollectibleNum(itemID) > 0 then
                    Almanac.CurrentFrame["held_items"][itemID] = Almanac.Player:GetCollectibleNum(itemID)
                end
            end
        end
        if #Almanac.CurrentFrame > 0 then
            for key, value in pairs(Almanac.CurrentFrame["held_items"]) do
                if value ~= Almanac.Player:GetCollectibleNum(key) then
                    Log("Player's number of a held item has changed, updating held_items and item_count")
                    Almanac.CurrentFrame["item_count"] = Almanac.Player:GetCollectibleCount()
                    for itemID = 1,525 do
                        if Almanac.Player:GetCollectibleNum(itemID) > 0 then
                            Almanac.CurrentFrame["held_items"][itemID] = Almanac.Player:GetCollectibleNum(itemID)
                            Isaac.DebugString(string.format("Player now holds collectible with id of %d", itemID))
                        end
                    end
                end
            end
        end
    end
end 




mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Almanac.Initialise)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, LogUI)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Almanac.UpdateValues)

