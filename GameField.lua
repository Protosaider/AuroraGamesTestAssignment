local Crystal = require("Crystal")
local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")
local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")
local Grid = require("Grid")

local GameFieldFindMatches = require("GameFieldFindMatches")
local GameFieldFindPotentialMatches = require("GameFieldFindPotentialMatches")
local GameFieldOnCrystalDestroy = require("GameFieldOnCrystalDestroy")

-- I'll try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys?
local GameFieldData = {}
setmetatable(GameFieldData, {__mode = "k"})

local GameField = {}

-- Should be private - can call only inside module. Must be declared before usage
local function createRandomCrystal(restrictedCrystals)
    local randomColor

    if #restrictedCrystals > 0 then
        while true do
            local out = true
            randomColor = ECrystalColor[math.random(#ECrystalColor)]
            for _, value in ipairs(restrictedCrystals) do
                if value.color == randomColor then
                    out = false
                end
            end
            if out then
                break
            end
        end
    else
        randomColor = ECrystalColor[math.random(#ECrystalColor)]
    end

    local crystal = Crystal:new(ECrystalType.Base, randomColor)
    return crystal
end


local function switchState(o, state) GameFieldData[o].state = state end
local function state(o) return GameFieldData[o].state end
local still = "Still"
local endMove = "EndMove"
local tryToSwap = "Swapped"
local tryToUndoSwap = "UndoSwap"
local undoSwap = "UndoSwap"
local changing = "Changing"

function GameField:new(width, height)
    local o = {}
    o.grid = Grid:new({}, width, height, nil)
    o.width = o.grid.width
    o.height = o.grid.height

    self.__index = self
    setmetatable(o, self)

    GameFieldData[o] = {
        state = still,

        potentialMatch = {},

        moveData = {},
        undoSwap = {},

        toCheckMatch = {},
        toMove = {},
        toModify = {},
    }

    return o
end

function GameField:init()
    for value in self.grid:getIterator() do
        local restrictedCrystals = {}

        if value.x > 2 then
            local prePrevious = self.grid:getValue(value.x - 2, value.y)
            local previous = self.grid:getValue(value.x - 1, value.y)
    
            if (prePrevious.type == previous.type and prePrevious.color == previous.color) then
                restrictedCrystals[#restrictedCrystals+1] = {type = previous.type, color = previous.color}
            end
        end
    
        if value.y > 2 then
            local prePrevious = self.grid:getValue(value.x, value.y - 2)
            local previous = self.grid:getValue(value.x, value.y - 1)
    
            if (prePrevious.type == previous.type and prePrevious.color == previous.color) then
                restrictedCrystals[#restrictedCrystals+1] = {type = previous.type, color = previous.color}
            end
        end
        
        self.grid:setValue(value.x, value.y, createRandomCrystal(restrictedCrystals))
    end

    FindPotentialMatches(self)
end



local onMoveFunctionsHolder = {
    Swap = function (o, from, to)
        o.grid:swapUnsafe(from.x, from.y, to.x, to.y)
        -- GameFieldData[gameField].toCheckMatch[#GameFieldData[o].toCheckMatch+1] = from
        -- GameFieldData[gameField].toCheckMatch[#GameFieldData[o].toCheckMatch+1] = to
    end,
}
function MakeMove(gameField, moveData)
    -- add here functions from additional module or smth like this
    if moveData.from.value.type == ECrystalType.Base and
        moveData.to.value.type == ECrystalType.Base
     then
        return onMoveFunctionsHolder["Swap"](gameField, moveData.from, moveData.to)
    end
end

function FindPotentialMatches(gameField)
    GameFieldData[gameField].potentialMatch = GameFieldFindPotentialMatches.findPotentialMatch3Swap(gameField)
end

function CheckSwapMatches(gameField)
    local from = GameFieldData[gameField].moveData.from
    local to = GameFieldData[gameField].moveData.to
    local direction = GameFieldData[gameField].moveData.from.direction

    if direction == EDirection.Up or direction == EDirection.Down then
        direction = "SwapVertical"
    else
        direction = "SwapHorizontal"
    end

    for _, value in ipairs(GameFieldData[gameField].potentialMatch[direction]) do
        if (value.from.x == from.x and value.from.x == from.y and value.to.x == to.x and value.to.y == to.y) or
        (value.from.x == to.x and value.from.x == to.y and value.to.x == from.x and value.to.y == from.y)
        then
            GameFieldData[gameField].toCheckMatch[#GameFieldData[gameField].toCheckMatch+1] = from
            GameFieldData[gameField].toCheckMatch[#GameFieldData[gameField].toCheckMatch+1] = to
            return true
        end
    end
    return false
end


local onFindMatchesFunctionsHolder = {
    --{ x = x + dX, y = y, value = previous }
    Match = function (o, result)
        if #result > 0 then
            for _, value in ipairs(result.values) do
                GameFieldData[o].toModify[#GameFieldData[o].toModify+1] = value
            end
        end
    end
}
function FindMatches(gameField)
    -- add here functions from additional module or smth like this
    for _, value in ipairs(GameFieldData[gameField].toCheckMatch) do
        local matchType, result = GameFieldFindMatches.match3OrGreater(gameField, value)
        -- then next function, than deside, which function should be used (or reorder findMatches function in such way)

        onFindMatchesFunctionsHolder[matchType](gameField, result)
    end
end




local onModifyFunctionsHolder = {
    --{ x = x + dX, y = y, value = previous }
    DestroyBase = function (o, value)
        o.grid:setValue(value.x, value.y, nil)
        return {x = value.x, y = value.y}
    end,
}
function Modify(gameField)
    local destroyed = {}
    for _, value in ipairs(GameFieldData[gameField].toModify) do

        -- add here functions from additional module or smth like this
        if value.value.type == ECrystalType.Base
        then
            local result = onModifyFunctionsHolder["DestroyBase"](gameField, value)
            destroyed[#destroyed+1] = result
        end
    end

    --handle destroyed objects
    table.sort(destroyed, function (a, b)
        if a.x ~= b.x then
            return a.x < b.x
        end
        return a.y > b.y
    end)

    local lowest = {}
    local x = 0
    for _, value in ipairs(destroyed) do
        if x < value.x then
            x = value
            lowest[#lowest+1] = {x = value.x, y = value.y, count = 1}
        else
            lowest[#lowest].count = lowest[#lowest].count + 1
        end
    end

    for _, value in ipairs(lowest) do
        GameFieldData[gameField].toMove[#GameFieldData[gameField].toMove+1] = value
    end

end


function Scroll(gameField)
    --{x = value.x, y = value.y, count = 1}
    for key, value in ipairs(GameFieldData[gameField].toMove) do
        for y = value.y, 2, -1 do
            gameField.grid:swapUnsafe(value.x, y, value.x, y - 1)
        end

        gameField.grid:setValue(value.x, 1, createRandomCrystal())
        
        for y = value.y, 1, -1 do
            local temp = gameField.grid:getValue(value.x, y)
            if temp == nil then
                GameFieldData[gameField].toMove[key].y = y
                break
            end
            GameFieldData[gameField].toCheckMatch[#GameFieldData[gameField].toCheckMatch+1] = {x = value.x, y = y, value = temp}
        end

        GameFieldData[gameField].toMove[key].count = value.count - 1

        -- if GameFieldData[gameField].toMove[key].count == 0 then delete end
        
    end
end


local onEndMoveFunctions = FindPotentialMatches


function GameField:move(from, to)

    local status = self.grid:isOutside(from.x, from.y)

    if not status then
        return "Can't move crystal: starting coordinates (" .. from.x .. ", " .. from.y .. ") are out of bounds"
    end

    status = self.grid:isOutside(to.x, to.y)

    if not status then
        return "Can't move crystal: ending coordinates (" .. to.x .. ", " .. to.y .. ") are out of bounds"
    end

    local fromValue = self.grid:getValue(from.x, from.y)
    local toValue = self.grid:getValue(to.x, to.y)

    local data = {
        from = { x = from.x, y = from.y, direction = from.direction, value = fromValue },
        to = { x = to.x, y = to.y, direction = to.direction, value = toValue },
    }

    GameFieldData[self].moveData = data

    switchState(self, tryToSwap)

end

function GameField:tick()

    if state(self) == still then
        return true
    end

    if state(self) == tryToSwap then
        MakeMove(self, GameFieldData[self].moveData)
        switchState(self, tryToUndoSwap)
        return false
    end

    if state(self) == tryToUndoSwap then
        local swap = CheckSwapMatches(self)
        if not swap then
            switchState(self, undoSwap)
        else
            switchState(self, changing)
        end
    end

    if state(self) == undoSwap then
        MakeMove(self, GameFieldData[self].moveData)
        switchState(self, still)
        return false
    end

    if state(self) == changing then

        --check matches for all
        FindMatches(self)
        
        --they go to toModify
        
        --modification
        Modify(self)

        --move crystals
        Scroll(self)

        return false
    end

    if state(self) == endMove then
        onEndMoveFunctions(self)
        switchState(self, still)
        return false
    end

end


function GameField:mix()
-- for each cell, we get a random tile type that we compare with the previous 2 cells left [row][col-1] & [row][col-2] 
-- as well as with the 2 cells down [row-1][col] & [row-2][col];
-- if the random tile type is the same as for any of these other cells, we loop until there is no matching.
end


return GameField