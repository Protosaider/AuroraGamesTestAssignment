
local Crystal = require("Crystal")
local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")
local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")
local Grid = require("Grid")

-- try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys

local GameFieldData = {}
setmetatable(GameFieldData, {__mode = "k"})

local GameField = {}

-- Should be private - can call only inside module. Must be declared before usage
local function createRandomCrystal()
    local randomColor = ECrystalColor[math.random(#ECrystalColor)]
    local crystal = Crystal:new(ECrystalType.Base, randomColor)
    return crystal
end

--@TODO Use only for checks after mix and init functions
local function addFindMatches(o, key, func)
    GameFieldData[o].findMatch[key] = func
end
-- @TODO Use only find potential matches and record them (which cell and in which direction must move)
-- @TODO If it happens -> fire functions etc.

local function addFindPotentialMatches(o, key, func)
    GameFieldData[o].findPotentialMatches[key] = func
end

local function addOnCrystalDestroy(o, key, func)
    GameFieldData[o].onCrystalDestroy[key] = func
end

local function addModify(o, item)
    GameFieldData[o].modify[#GameFieldData[o].modify + 1] = item
end

local function removeModify(o, index)
    local item = GameFieldData[o].modify[index]
    GameFieldData[o].modify[index] = nil
    return item
end

local onModifyFunctions = {
    Swap = function (x, y, direction)
        
    end
}

local function switchState(o, state)
    GameFieldData[o].state = state
end

local function state(o)
    return GameFieldData[o].state
end

local swapped = "Swapped"
local undoSwap = "UndoSwap"
local still = "Still"
local changing = "Changing"

function GameField:new(width, height)
    local o = {}
    o.grid = Grid:new({}, width, height, nil)

    self.__index = self
    setmetatable(o, self)

    o:init()

    GameFieldData[o] = {
        state = still,

        findMatch = {},
        findPotentialMatches = {},
        onCrystalDestroy = {},

        modify = {},
        destroy = {},
    }

    return o
end

function GameField:init()
    for value in self.grid:getIterator() do
        self.grid:setValue(value.x, value.y, createRandomCrystal())
    end
end

-- from {x, y}; to {x, y}
-- from {x, y}; to {direction}
function GameField:move(from, to)
    local status, result = self.grid:swap(from.x, from.y, to)

    if not status then
        if result == "From" then
            --write message
        else
            print()
        end
    end

    addModify(self, { x = result.from.x, y = result.from.y, direction = to })
    addModify(self, { x = result.to.x, y = result.to.y, direction = EDirectionHelper.opposite(to) })

    switchState(self, swapped)
end

function GameField:tick(status)
    -- if makingTurn return false and wait for durationSeconds
    if state(self) == still then
        return true
    end

    if state(self) == swapped then
        -- check if coordinates are inside potential Matches)
        --if hasPotentialMatches then
        --switchState(self, changing)
        --else
        -- switchState(self, undoSwap)
        --end
        return false
    end

    if state(self) == undoSwap then
        --swap items
        local from = removeModify(self, 1)
        local to = removeModify(self, 2)
        addModify(self, { x = from.x, y = from.y, direction = to.direction })
        addModify(self, { x = to.x, y = to.y, direction = from.direction })
        switchState(self, still)
        return false
    end

end

-- 0) swap
-- 1) check matches/combos
-- 2) decide which match/combo function to call (MAYBE IT HAS PRIORITY because different match function may have different priority)
-- 3) call function --> do smth with field (modify, delete) --> write down cells coordinates and function to execute
-- 4) traverse all cells that needs to be modified --> modify them
-- 5) traverse all cells that needs to be destroyed --> destroy items AND execute function onCrystDestrFunc
-- 6) return to 1

function GameField:checkMatch(x, y, swapDirection)
    -- iterate all functions to match / combos
    -- collect table of results
    -- sort in order of execution or choose most valuable match / combo
    -- do actions
end




function GameField:mix()
    
end



return GameField