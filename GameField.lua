local Crystal = require("Crystal")
local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")
local EDirection = require("EDirection")
local Grid = require("Grid")

local GameFieldFindMatches = require("GameFieldFindMatches")
local GameFieldFindPotentialMatches = require("GameFieldFindPotentialMatches")


-- I'll try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys?
local GameFieldData = {}
setmetatable(GameFieldData, {__mode = "k"})

local GameField = {}

-- Should be private - can call only inside module. Must be declared before usage
local function createRandomCrystal(restrictedCrystals)
    local randomColor

    if #(restrictedCrystals or {}) > 0 then
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


local function switchState(o, state) GameFieldData[o].currentState = state end
local function currentState(o) return GameFieldData[o].currentState end

local state = {
    still = "Still",
    endMove = "EndMove",
    tryToSwap = "TryToSwap",
    tryToUndoSwap = "TryToUndoSwap",
    undoSwap = "UndoSwap",
    changing = "Changing",
}


function GameField:new(width, height)
    local o = {}
    o.grid = Grid:new({}, width, height, nil)
    o.width = o.grid.width
    o.height = o.grid.height

    self.__index = self
    setmetatable(o, self)

    GameFieldData[o] = {
        currentState = state.still,
        potentialMatch = {},
        moveData = {},
        toCheckMatch = {},
        toModify = {},
        toMove = {},
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

    FindAllPotentialMatches(self)
end


function FindAllPotentialMatches(gameField)
    local hasMatches
    hasMatches, GameFieldData[gameField].potentialMatch = GameFieldFindPotentialMatches.findAllPotentialMatches3Swap(gameField)
    return hasMatches
end

--Enulates external file, like GameFieldPotentialMatches
local onMoveFunctionsHolder = {
    Swap = function (o, from, to)
        o.grid:swap(from.x, from.y, to.x, to.y)
    end,
}
function MakeMove(gameField, moveData)
    -- add here functions from additional module or smth like this\
    local functionType
    if moveData.from.value.type == ECrystalType.Base and
        moveData.to.value.type == ECrystalType.Base
     then
        functionType = "Swap"
    end
    return onMoveFunctionsHolder[functionType](gameField, moveData.from, moveData.to)
end

function CheckSwapMatches(gameField)
    local from = GameFieldData[gameField].moveData.from
    local to = GameFieldData[gameField].moveData.to
    local direction = GameFieldData[gameField].moveData.from.direction

    if direction == EDirection.Up or direction == EDirection.Down then
        direction = GameFieldFindPotentialMatches.potentialMatchTypes.swapVertical
    else
        direction = GameFieldFindPotentialMatches.potentialMatchTypes.swapHorizontal
    end

    for _, value in ipairs(GameFieldData[gameField].potentialMatch[direction]) do
        if (value.from.x == from.x and value.from.y == from.y and value.to.x == to.x and value.to.y == to.y) or
        (value.from.x == to.x and value.from.y == to.y and value.to.x == from.x and value.to.y == from.y)
        then
            GameFieldData[gameField].toCheckMatch[#GameFieldData[gameField].toCheckMatch+1] = from
            GameFieldData[gameField].toCheckMatch[#GameFieldData[gameField].toCheckMatch+1] = to
            return true
        end
    end
    return false
end


local onCheckMatchesFunctionsHolder = {
    --{ x = x + dX, y = y, value = previous }
    Match = function (o, result)
        if #result > 0 then
            for _, match in ipairs(result) do
                for _, value in ipairs(match.values) do
                    GameFieldData[o].toModify[#GameFieldData[o].toModify+1] = value
                end
            end
        end
    end
}
function CheckMatches(gameField, toCheckMatch)

    local matchType
    local result
    -- add here functions from additional module or smth like this
    for key, value in ipairs(toCheckMatch) do
        matchType, result = GameFieldFindMatches.match3OrGreater(gameField, value)

        -- then next function, than deside, which function should be used (or reorder findMatches function in such way)
        onCheckMatchesFunctionsHolder[matchType](gameField, result)

        toCheckMatch[key] = nil
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
    local functionType
    
    for key, value in ipairs(GameFieldData[gameField].toModify) do

        -- add here functions from additional module or smth like this
        if value.value.type == ECrystalType.Base
        then
            functionType = "DestroyBase"
            
            local result = onModifyFunctionsHolder[functionType](gameField, value)
            destroyed[#destroyed+1] = result
        end

        GameFieldData[gameField].toModify[key] = nil
    end

    --handle destroyed objects
    table.sort(destroyed, function (a, b)
        if a.x ~= b.x then
            return a.x < b.x
        end
        return a.y > b.y
    end)

    local lowestDestroyed = {}
    local x = 0
    for _, value in ipairs(destroyed) do
        if x < value.x then
            x = value.x
            lowestDestroyed[#lowestDestroyed+1] = {x = value.x, y = value.y, countEmpty = 1}
        else
            lowestDestroyed[#lowestDestroyed].countEmpty = lowestDestroyed[#lowestDestroyed].countEmpty + 1
        end
    end

    for key, value in ipairs(lowestDestroyed) do
        for keyMove, valueMove in ipairs(GameFieldData[gameField].toMove) do
            if valueMove.x == value.x then
                if value.y > valueMove.y then
                    GameFieldData[gameField].toMove[keyMove].y = value.y
                    GameFieldData[gameField].toMove[keyMove].countEmpty = valueMove.countEmpty + value.countEmpty
                    lowestDestroyed[key] = nil
                    break
                end
            end
        end
    end

    for _, value in ipairs(lowestDestroyed) do
        GameFieldData[gameField].toMove[#GameFieldData[gameField].toMove+1] = value
    end

end



function Scroll(gameField)
    --{x = value.x, y = value.y, count = 1}
    for key, value in ipairs(GameFieldData[gameField].toMove) do
        for y = value.y, 2, -1 do
            gameField.grid:swap(value.x, y, value.x, y - 1)
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

        GameFieldData[gameField].toMove[key].countEmpty = value.countEmpty - 1

        if GameFieldData[gameField].toMove[key].countEmpty == 0 then
            GameFieldData[gameField].toMove[key] = nil
        end
    end
end


function FindAllMatches(gameField)
    -- can add here functions from additional module or smth like this
    local allMatches
    allMatches = GameFieldFindMatches.findAllMatches3OrGreater(gameField)
    return allMatches
end

function GameField:move(from, to)

    local status = self.grid:isOutside(from.x, from.y)

    if status then
        return "Can't move crystal: starting coordinates (" .. from.x .. ", " .. from.y .. ") are out of bounds"
    end

    status = self.grid:isOutside(to.x, to.y)

    if status then
        return "Can't move crystal: ending coordinates (" .. to.x .. ", " .. to.y .. ") are out of bounds"
    end

    local fromValue = self.grid:getValue(from.x, from.y)
    local toValue = self.grid:getValue(to.x, to.y)

    local data = {
        from = { x = from.x, y = from.y, direction = from.direction, value = fromValue },
        to = { x = to.x, y = to.y, direction = to.direction, value = toValue },
    }

    GameFieldData[self].moveData = data

    switchState(self, state.tryToSwap)

end

function GameField:tick()

    if currentState(self) == state.still then
        return true
    end

    if currentState(self) == state.tryToSwap then
        MakeMove(self, GameFieldData[self].moveData)
        switchState(self, state.tryToUndoSwap)
        return false
    end

    if currentState(self) == state.tryToUndoSwap then
        local swap = CheckSwapMatches(self)
        if not swap then
            switchState(self, state.undoSwap)
        else
            switchState(self, state.changing)
        end
    end

    if currentState(self) == state.undoSwap then
        MakeMove(self, GameFieldData[self].moveData)
        switchState(self, state.still)
        return false
    end

    if currentState(self) == state.changing then

        --check matches for each cell
        CheckMatches(self, GameFieldData[self].toCheckMatch)

        --they go to toModify (to be destroyed, or transformed, or else)
        Modify(self)

        --move crystals and spawn new
        Scroll(self)

        local hasToCheckMatches = #GameFieldData[self].toCheckMatch > 0
        local hasToModify = #GameFieldData[self].toModify > 0
        local hasToMove = #GameFieldData[self].toMove > 0

        if not (hasToCheckMatches or hasToModify or hasToMove) then
            switchState(self, state.endMove)
        end

        return false
    end

    if currentState(self) == state.endMove then
        local hasPotentialMatches = FindAllPotentialMatches(self)

        while not hasPotentialMatches do
            self:mix()
            hasPotentialMatches = FindAllPotentialMatches(self)
        end
        switchState(self, state.still)
        return true
    end

end


local function contains(table, item)
    for _, value in ipairs(table) do
        if value == item then
            return true
        end
    end
    return false
end
local function remove(table, item)
    for key, value in ipairs(table) do
        if value == item then
            local temp = value
            table[key] = nil
            return temp
        end
    end
    return nil
end

function GameField:mix()

    self.grid:shuffle()

    while true do
        --{ type, color, values = {x, y} }
        local allMatches = FindAllMatches(self)

        if #allMatches == 0 then
            break
        end

        local item, from, to
        local acceptableColors
        
        for _, match in ipairs(allMatches) do
            acceptableColors = {}

            for i = 1, #ECrystalColor do
                local color = ECrystalColor[i]
                if match.color ~= color then
                    acceptableColors[#acceptableColors+1] = color
                end
            end
            
            while true do
                while true do
                    item = self.grid:getRandom()
                    from = {x = item.x, y = item.y}
                    if not contains(match.values, from) and contains(acceptableColors, item.value.color) then
                        break
                    end
                end
        
                to = match.values[math.random(#match.values)]

                CheckMatches(self, {from})
                if #GameFieldData[self].toModify ~= 0 then
                    remove(acceptableColors, item.value.color)
                end
        
                CheckMatches(self, {to})
                
                if #GameFieldData[self].toModify == 0 then
                    break
                else
                    for key, _ in ipairs(GameFieldData[self].toModify) do
                        GameFieldData[self].toModify[key] = nil
                    end
                end
            end
        end
    end

end


return GameField