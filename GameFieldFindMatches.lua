
local matchTypes = {
    matchHorizontal = "MatchHorizontal",
    matchVertical = "MatchVertical",
}

function checkHorizontal(gameField, width, height, x, y)
    local result = {}

    local value = gameField.grid:getValue(x, y)
    result[#result+1] = value

    local amount = 1

    for dX = 1, width - x do
        local next = gameField.grid:getValue(x + dX, y)
        if next.type == value.type and next.color == value.color then
            result[#result+1] = next
            amount = amount + 1
        else
            break
        end
    end

    for dX = -1, 1 - x, -1 do
        local previous = gameField.grid:getValue(x + dX, y)
        if previous.type == value.type and previous.color == value.color then
            result[#result+1] = previous
            amount = amount + 1
        else
            break
        end
    end

    return amount, result
end

function checkVertical(gameField, width, height, x, y)
    local result = {}

    local value = gameField.grid:getValue(x, y)
    result[#result+1] = value

    local amount = 1

    for dY = 1, height - y do
        local next = gameField.grid:getValue(x, y + dY)
        if next.type == value.type and next.color == value.color then
            result[#result+1] = next
            amount = amount + 1
        else
            break
        end
    end

    for dY = -1, 1 - y, -1 do
        local previous = gameField.grid:getValue(x, y + dY)
        if previous.type == value.type and previous.color == value.color then
            result[#result+1] = previous
            amount = amount + 1
        else
            break
        end
    end

    return amount, result
end

-- gameField, (matchType, x, y)
function match3OrGreaterResolvePotentialMatch(gameField, width, height, x, y, matchType)

    local amount = 0
    local result = {}

    if matchType == matchTypes.matchVertical then
        amount, result = checkVertical(gameField, width, height, x, y)
    elseif matchType == matchTypes.matchHorizontal then
        amount, result = checkHorizontal(gameField, width, height, x, y)
    end

    return amount, result
end

function findMatch3OrGreaterHorizontal(gameField, width, height, x, y)
    
end

function findMatch3OrGreaterVertical(gameField, width, height, x, y)
    
end

function findMatch3OrGreater(gameField, width, height)

end

return {
    matchTypes = matchTypes,

    potentialMatch3OrGreater = match3OrGreaterResolvePotentialMatch,
    findMatch3OrGreater = findMatch3OrGreater,
}

