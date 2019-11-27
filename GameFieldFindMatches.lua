
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
            -- result[#result+1] = next
            result[#result+1] = { x = x + dX, y = y, value = next }
            amount = amount + 1
        else
            break
        end
    end

    for dX = -1, 1 - x, -1 do
        local previous = gameField.grid:getValue(x + dX, y)
        if previous.type == value.type and previous.color == value.color then
            -- result[#result+1] = previous
            result[#result+1] = { x = x + dX, y = y, value = previous }
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
            -- result[#result+1] = next
            result[#result+1] = { x = x, y = y + dY, value = next }
            amount = amount + 1
        else
            break
        end
    end

    for dY = -1, 1 - y, -1 do
        local previous = gameField.grid:getValue(x, y + dY)
        if previous.type == value.type and previous.color == value.color then
            -- result[#result+1] = previous
            result[#result+1] = { x = x, y = y + dY, value = previous }
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

    local allMatches = {}

    local result = {}
    local currentValue = gameField.grid:getValue(1, y)
    local currentType = currentValue.type
    local currentColor = currentValue.color
    result[#result+1] = {x = 1, y = y}

    for i = 2, width do
        currentValue = gameField.grid:getValue(i, y)
        if currentValue.type == currentType and currentValue.color == currentColor then
            result[#result+1] = {x = i, y = y}
        else
            if #result >= 3 then
                -- for _, value in ipairs(result) do
                --     allMatches[#allMatches+1] = value
                -- end
                allMatches[#allMatches+1] = { data = {type = currentType, color = currentColor}, values = result }
            end
            currentType = currentValue.type
            currentColor = currentValue.color
            result = {x = i, y = y}
        end
    end

    return allMatches
end

function findMatch3OrGreaterVertical(gameField, width, height, x, y)
    local allMatches = {}

    local result = {}
    local currentValue = gameField.grid:getValue(x, 1)
    local currentType = currentValue.type
    local currentColor = currentValue.color
    result[#result+1] = {x = x, y = 1}

    for i = 2, height do
        currentValue = gameField.grid:getValue(x, i)
        if currentValue.type == currentType and currentValue.color == currentColor then
            result[#result+1] = {x = x, y = i}
        else
            if #result >= 3 then
                allMatches[#allMatches+1] = { data = {type = currentType, color = currentColor}, values = result }
            end
            currentType = currentValue.type
            currentColor = currentValue.color
            result = {x = i, y = y}
        end
    end

    return allMatches
end

function findAllMatches3OrGreater(gameField, width, height)
    local allMatches = {}

    for y = 1, height do
        local result = findMatch3OrGreaterHorizontal(gameField, width, height, 1, y)
        if #result > 0 then
            for _, value in ipairs(result) do
                allMatches[#allMatches+1] = { matchTypes.matchHorizontal, value }
            end
        end
    end

    for x = 1, width do
        local result = findMatch3OrGreaterVertical(gameField, width, height, x, 1)
        if #result > 0 then
            for _, value in ipairs(result) do
                allMatches[#allMatches+1] = { matchTypes.matchVertical, value }
            end
        end
    end

    return allMatches

end


function match3OrGreater(gameField, data)

    local allMatches = {}
    local count = 0
    local result = {}

    count, result = checkVertical(gameField, gameField.width, gameField.height, data.x, data.y)
    if count >= 3 then
        allMatches[#allMatches+1] = { count = count, values = result }
    end

    count, result = checkHorizontal(gameField, gameField.width, gameField.height, data.x, data.y)
    if count >= 3 then
        allMatches[#allMatches+1] = { count = count, values = result }
    end
    
    table.sort(allMatches, function (a, b)
        return a.count > b.count --from biggest to lowest
    end)

    return "Match", allMatches
end


return {
    matchTypes = matchTypes,

    potentialMatch3OrGreater = match3OrGreaterResolvePotentialMatch,
    findAllMatches3OrGreater = findAllMatches3OrGreater,
    match3OrGreater = match3OrGreater,
}

