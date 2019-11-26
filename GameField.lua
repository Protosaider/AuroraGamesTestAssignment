
local Crystal = require("Crystal")
local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")
local EDirection = require("EDirection")
local Grid = require("Grid")

-- try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys
local GameFieldDumpSettings = {}
setmetatable(GameFieldDumpSettings, {__mode = "k"})

local GameField = {

}

-- Should be private - can call only inside module. Must be declared before usage
local function createRandomCrystal()
    local randomColor = ECrystalColor[math.random(#ECrystalColor)]
    local crystal = Crystal:new(ECrystalType.Base, randomColor)
    return crystal
end

local function createDataForDump(gridWidth, gridHeight, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
-- local function createDataForDump(gridWidth, gridHeight, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
    local columnsHeader = string.rep(indexSpace, 3)

    for i = 1, gridWidth  do
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

function GameField:new(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
-- function GameField:new(width, height, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)
    local o = {}
    o.grid = Grid:new({}, width, height, nil)

    self.__index = self
    setmetatable(o, self)

    o:init()

    local dumpData = createDataForDump(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)

    GameFieldDumpSettings[o] = dumpData
    --GameFieldDumpSettings[self] = dumpData

    -- GameFieldDumpSettings[o] = createDataForDump(width, height, output, indexSpace, separatorItemVertical, separatorItemHorizontal, newline)

    return o
end

function GameField:init()
    for value in self.grid:getIterator() do
        self.grid:setValue(value.x, value.y, createRandomCrystal())
    end
end

function GameField:dump()

    clearConsole()

    print(GameFieldDumpSettings[self].columnsHeader)
    -- GameFieldDumpSettings[self].output:write(GameFieldDumpSettings[self].columnsHeader, GameFieldDumpSettings[self].newline)

    for key, value in ipairs(GameFieldDumpSettings[self].rowHeaders) do
        io.stdout:write(value)
        self.grid:iterateRow(key, function (value)
            io.stdout:write(GameFieldDumpSettings[self].indexSpace, tostring(value.color))
        end)
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


return GameField