-- try to use DualRepresentation p. 197 RobertoIerusalimschy-Pro.InLua
-- Use weak keys
local GridDumpSettings = {}
setmetatable(GridDumpSettings, {__mode = "k"})

local GameFieldVisualizer = {}

local function createDataForDump(gridWidth, gridHeight, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)
    local columnsHeader = string.rep(indexSpace, 4)

    for i = 1, gridWidth  do
        columnsHeader = columnsHeader .. i
        if (i + 1) / 10 < 1 then
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
        if (i / 10) < 1 then
            rowHeaders[i] = rowHeaders[i] .. indexSpace
        end
        rowHeaders[i] = rowHeaders[i] .. i .. separatorItemVertical
    end

    return {
        columnsHeader = columnsHeader,
        rowHeaders = rowHeaders,
        indexSpace = indexSpace,
        nilItem = nilItem,

        message = "",
    }
end

local function clearConsole()
    if not os.execute("clear") then
        os.execute("cls")
    end
end

function GameFieldVisualizer:new(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)
    local o = {}

    self.__index = self
    setmetatable(o, self)

    GridDumpSettings[o] = createDataForDump(width, height, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)

    return o
end

-- @TODO Create iterator in gameField, instead of using gameField itself
function GameFieldVisualizer:dump(gameField)
    clearConsole()

    print(GridDumpSettings[self].columnsHeader)

    for key, value in ipairs(GridDumpSettings[self].rowHeaders) do
        io.stdout:write(value)
        gameField.grid:iterateRow(key, function (value)
                io.stdout:write(GridDumpSettings[self].indexSpace)
                io.stdout:write(tostring(value.color or GridDumpSettings[self].nilItem))
            end
        )
        print()
    end
    
    print(GridDumpSettings[self].message)
end

function GameFieldVisualizer:setMessage(message)
    GridDumpSettings[self].message = message
end

return GameFieldVisualizer