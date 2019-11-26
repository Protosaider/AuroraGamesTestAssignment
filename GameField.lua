
local Crystal = require("Crystal")
local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")
local EDirection = require("EDirection")
local Grid = require("Grid")

-- try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys
local GameFieldDumpSettings = {}
setmetatable(GameFieldDumpSettings, {__mode = "k"})

local GameFieldData = {}
setmetatable(GameFieldData, {__mode = "k"})

local GameField = {

}


GameFieldState = "Changing"
GameFieldState = "Still"


-- Should be private - can call only inside module. Must be declared before usage
local function createRandomCrystal()
    local randomColor = ECrystalColor[math.random(#ECrystalColor)]
    local crystal = Crystal:new(ECrystalType.Base, randomColor)
    return crystal
end

local function createDataForDump(gridWidth, gridHeight, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)
-- local function createDataForDump(gridWidth, gridHeight, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
    local columnsHeader = string.rep(indexSpace, 3)

    for i = 1, gridWidth do
        columnsHeader = columnsHeader .. (i - 1)
        if (i / 10) <= 1 then
            columnsHeader = columnsHeader .. indexSpace
        end
    end

    local separator = ""

    for i = 1, #columnsHeader do
        separator = separator .. separatorItemHorizontal
    end

    columnsHeader =  columnsHeader .. newline .. separator

    local rowHeaders = {}

    for i = 1, gridHeight do
        rowHeaders[i] = ""
        if (i / 10) <= 1 then
            rowHeaders[i] = rowHeaders[i] .. indexSpace
        end
        rowHeaders[i] = rowHeaders[i] .. (i - 1) .. separatorItemVertical
    end

    return {
        columnsHeader = columnsHeader,
        rowHeaders = rowHeaders,
        indexSpace = indexSpace,
        nilItem = nilItem,
        -- output = output,
        -- newline = newline,
    }
end

local function clearConsole()
    --clear console
    if not os.execute("clear") then
        os.execute("cls")
    end
end

local function addFindMatchesFunction(o, key, func)
    GameFieldData[o].findMatch[key] = func
end

local function addOnCrystalDestroyFunction(o, key, func)
    GameFieldData[o].onCrystalDestroy[key] = func
end

function GameField:new(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)
-- function GameField:new(width, height, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
    local o = {}
    o.grid = Grid:new({}, width, height, nil)

    self.__index = self
    setmetatable(o, self)

    o:init()

    o.grid:setValue(1, 2, nil)

    local dumpData = createDataForDump(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)
    GameFieldDumpSettings[o] = dumpData

    -- GameFieldDumpSettings[o] = createDataForDump(width, height, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
    
    GameFieldData[o] = {
        state = "Still",
        findMatch = {},
        onCrystalDestroy = {},
    }

    return o
end

function GameField:init()
    for value in self.grid:getIterator() do
        self.grid:setValue(value.x, value.y, createRandomCrystal())
    end
end

-- @TODO Into separate module
function GameField:dump()

    clearConsole()

    print(GameFieldDumpSettings[self].columnsHeader)
    -- GameFieldDumpSettings[self].output:write(GameFieldDumpSettings[self].columnsHeader, GameFieldDumpSettings[self].newline)

    for key, value in ipairs(GameFieldDumpSettings[self].rowHeaders) do
        io.stdout:write(value)
        self.grid:iterateRow(key, function (value)
                io.stdout:write(GameFieldDumpSettings[self].indexSpace)
                io.stdout:write(tostring(value.color or GameFieldDumpSettings[self].nilItem))
            end
        )
        print()
    end

    -- for y = 1, self.grid.height do
    --     -- GameFieldDumpSettings[self].output:write(GameFieldDumpSettings[self].rowHeaders[y])
    --     io.stdout:write(GameFieldDumpSettings[self].rowHeaders[y])
    --     self.grid:iterateRow(y, function (value)
    --         io.stdout:write(GameFieldDumpSettings[self].indexSpace, value.color)
    --         -- GameFieldDumpSettings[self].output:write(GameFieldDumpSettings[self].indexSpace, value.color)
    --     end)
    --     print()
    -- end

end

-- function onDestroyCrystal => handles different behaviour of different crystal types

-- function to check for possible combos

-- if there are no such possibilities => mix

-- MIXING existing crystals in such fashion that there are no combinations


-- from {x, y}; to {x, y}
-- from {x, y}; to {direction}
function GameField:move(from, to)
    local result, errorCode = self.grid:swap(from.x, from.y, to.x, to.y)

    --@ TODO Need to save items that was swapped (lastSwapped or smth like that)
    if not result then
        if errorCode == "From" then
            --state of field don't changed
            return
        end
        if errorCode == "To" then
            --state of field changed
            return
        end
    end

    -- check for matches

    -- if not then self.grid:swap(from.x, from.y, to.x, to.y) end

end

-- when you make a combo, for example a fourth in a row => there are a power crystal spawned
-- it happens because one of the crystals contains function that fires on crystal destruction

-- for it we needed: a table with functions for combos ?

-- 0) swap items

-- 1) check all possible matches

----- maybe: checkMatch => func(grid, ...) -> return T/F, "ComboReaction", "onCrysDestFunc for current cells" ??

-- checkMatch => func(grid, ...) -> return T/F, "ComboName"
--------------
-- "checkMatch3" => func(grid, x, y, swapDir) --> return T/F, "Default"
-- "checkMatch4" => func(grid, x, y, swapDir, swapCrysColor) --> return T/F, "bomb+color"
-- "checkMatch3+Bomb" => func(grid, x, y, etc?) --> return T/F, "colorDestroy"

-- 2) if has some - set onCrysDestFunc to the corresponding crys

-- combo\match name | onCrystalDestroyFunction
-----------------------------------------
-- "match-3" => default
-- "bomb+color" => default (return nil)
-- "match-4" => func(color) --> return bombTypeCrystal
-- "colorDestroy" => func(gameField, color) --> gameField.grid:findAll(value.color == color), gameField:addToDestroy(finded), return nil

-- 3) add to the list of crystalsToBeDestroyed
-- 4) get all crystals from list and execute all onCrystDestrFunc !!!!!!!!!!! what arguments do we need in each cases ?
-- 5)


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

function GameField:tick()
    -- if makingTurn return false and wait for durationSeconds
end






return GameField