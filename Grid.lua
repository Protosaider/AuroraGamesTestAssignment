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

    self.__index = self
    setmetatable(o, self)

    o:setAll()

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
    local value = self.values[x][y]
    if value == NIL then
        return nil
    end
    return value
end

function Grid:getValueSafe(x, y)
    if self:isOutside(x, y) then
        return false, self.defaultValue
    end
    return true, self.values[x][y]
end

function Grid:setValue(x, y, value)
    self.values[x][y] = value and value or self.defaultValue
end

function Grid:setValueSafe(x, y, value)
    if self:isOutside(x, y) then
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

    local result, value = self:getValueSafe(x, y)

    if not result then
        error "Coordinates are outside the grid"
    end

    local neighbourX = x + directionVectors[direction][1]
    local neighbourY = y + directionVectors[direction][2]

    result, value = self:getValueSafe(neighbourX, neighbourY)

    if not result then
        error "Neighbour's coordinates are outside the grid"
    end

    return value
end

function Grid:swapSafe(fromX, fromY, direction)
    local toX = fromX + directionVectors[direction][1]
    local toY = fromY + directionVectors[direction][2]
    return self:swapSafe(fromX, fromY, toX, toY)
end

function Grid:swapSafe(fromX, fromY, toX, toY)
    local result, temp = self:getValueSafe(fromX, fromY)

    if not result then
        -- error "Coordinates (from) are outside the grid"
        return false, "From"
    end

    result, self.values[fromX][fromY] = self:getValueSafe(toX, toY)

    if not result then
        self.values[fromX][fromY] = temp
        -- error "Coordinates (to) are outside the grid"
        return false, "To"
    end

    self.values[toX][toY] = temp

    return true, {from = {x = fromX, y = fromY}, to = {x = toX, y = toY}}
end

function Grid:swap(fromX, fromY, direction)
    local toX = fromX + directionVectors[direction][1]
    local toY = fromY + directionVectors[direction][2]
    return self:swap(fromX, fromY, toX, toY)
end

function Grid:swap(fromX, fromY, toX, toY)
    local temp = self.values[fromX][fromY]
    self.values[fromX][fromY] = self.values[toX][toY]
    self.values[toX][toY] = temp
    return {from = {x = fromX, y = fromY}, to = {x = toX, y = toY}}
end

function Grid:findValues(filter)
    local values = {}

    for y, value in ipairs(self.values) do
        for x, val in ipairs(value) do
            if filter(val) then
                values[#values+1] = {x = x, y = y, value = val}
            end
        end
    end

    return values
end

function Grid:iterate(predicate)
    assert(type(predicate) == "function", "Predicate must be a function")
    for y = 1, self.height do
        for x = 1, self.width do
            predicate(self.values[x][y])
        end
    end
end

function Grid:iterateRow(y, predicate)
    assert(type(predicate) == "function", "Predicate must be a function")

    if self:isOutside(1, y) then
        error "Y coordinate is outside of grid"
    end

    for x = 1, self.width do
        predicate(self.values[x][y])
    end
end

-- ?????????? I suppose, it's okay
function Grid:getIterator()
    local initialState = {x = 0, y = 1}

    local function iterator(state)
        while true do
            state.x = state.x + 1
            if state.x > self.width then
                state.y = state.y + 1
                if state.y > self.height then
                    break
                end
                state.x = 1
            end
            return {x = state.x, y = state.y, value = self.values[state.x][state.y]}
        end
        return nil
    end

    return iterator, initialState
end

function Grid:getRandom()
    local x = math.random(self.width)
    local y = math.random(self.height)
    return { x = x, y = y, value = self.values[math.random(self.width)][math.random(self.height)] }
end

-- Fisher-Yates
function Grid:shuffle()

    local size = self.height * self.width

    -- for i from n−1 downto 1 do
    --     j ← random integer such that 0 ≤ j ≤ i
    --     exchange a[j] and a[i]

    for i = size - 1, 2, -1 do
        local fromY = (i // self.width) + 1; --height
        local fromX = (i % self.width) + 1; --width

        local random = math.random(0, i)
        local toY = (random // self.width) + 1;
        local toX = (random % self.width) + 1;

        local temp = self.values[fromY][fromX]
        self.values[fromY][fromX] = self.values[toY][toX]
        self.values[toY][toX] = temp
    end

end


-- --verticalAndHorizontal, Diagonal, Both
-- function Grid:getNeighbours(x, y, neighboursLocation)
    
-- end

return Grid