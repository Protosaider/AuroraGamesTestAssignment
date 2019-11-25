local Grid = {

}

local NIL = "nil"

function Grid:new(o, width, height, defaultValue)
    o = o or {}
    -- @TODO check type
    o.width = width or 0
    o.height = height or 0
    o.values = {}

    if o.width == o.height and o.width == 0 then
        return nil
    end

    o.defaultValue = defaultValue and defaultValue or NIL

    -- initialize
    for x = 1, o.width do
        o.values[x] = {}
    end

    o:setAllDefault()

    self.__index = self
    setmetatable(o, self)
    return o
end

function Grid:isOutside(x, y)
    -- @TODO check types
    if x <= 0 or x > self.width or y <= 0 or y > self.height then
        return true
    end
    return false
end

function Grid:getValue(x, y)
    if self.isOutside(x, y) == false then
        return false, self.defaultValue
    end

    return true, self.values[x][y]
end

function Grid:setValue(x, y, value)
    if self.isOutside(x, y) == false then
        return false
    end

    self.values[x][y] = value and value or self.defaultValue
    return true
end

function Grid:setAll(value)
    local valueToSet = value and value or self.defaultValue

    for y = 1, self.height do
        for x = 1, self.width do
            self.values[x][y] = valueToSet
        end
    end
end

function Grid:getAll()
    local allValues = {}
    for _, value in ipairs(self.values) do
        for _, val in ipairs(value) do
            allValues[#allValues+1] = val
        end
    end
    return allValues
end


function Grid:getRow(y)
    local row = {}

    if y > 0 and y <= self.height then
        for x = 1, self.width do
            row[#row+1] = self.values[x][y]
        end
    end

    return row
end

function Grid:getColumn(x)
    local column = {}

    if x > 0 and x <= self.width then
        column = self.values[x]
    end

    return column
end

local EDirection = require("EDirection")

local directionVectors = {}
directionVectors[EDirection.Up] =           {0, -1}
directionVectors[EDirection.Right]  =       {1, 0}
directionVectors[EDirection.Down] =         {0, 1}
directionVectors[EDirection.Left] =         {-1, 0}
directionVectors[EDirection.UpperRight] =   {1, -1}
directionVectors[EDirection.LowerRight] =   {1, 1}
directionVectors[EDirection.LowerLeft] =    {-1, 1}
directionVectors[EDirection.UpperLeft] =    {-1, -1}

function Grid:getNeighbour(x, y, direction)
    assert(type(direction) == type(EDirection), "direction value is not a EDirection")

    if self:isOutside(x, y) then
        error "Coordinates are outside the grid"
    end

    local neighbourX = x + directionVectors[direction][1]
    local neighbourY = y + directionVectors[direction][2]

    local result, value = self:getValue(neighbourX, neighbourY)

    if not result then
        error "Neighbour's coordinates are outside the grid"
    end

    return value
end

function Grid:swap(fromX, fromY, toX, toY)

    local result, swap = self.values[fromX][fromY]

    if not result then
        error "Coordinates (from) are outside the grid"
    end

    result, self.values[fromX][fromY] = self.values[toX][toY]

    if not result then
        self.values[fromX][fromY] = swap
        error "Coordinates (to) are outside the grid"
    end

    self.values[toX][toY] = swap

end

-- --verticalAndHorizontal, Diagonal, Both
-- function Grid:getNeighbours(x, y, neighboursLocation)
    
-- end

return Grid