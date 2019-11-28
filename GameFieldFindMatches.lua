
-- local matchTypes = {
--     matchHorizontal = "MatchHorizontal",
--     matchVertical = "MatchVertical",
-- }

--[[
function findMatch3OrGreaterHorizontal(gameField, width, height, x, y)

local allMatches = {}

local result = {}
local currentType
local currentColor

for i = 1, width do
    local currentValue = gameField.grid:getValue(1, y)
    local isNil = currentValue == nil

    if not isNil and #result == 0 then
        currentType = currentValue.type
        currentColor = currentValue.color
    end

    if (not isNil) and currentValue.type == currentType and currentValue.color == currentColor then
        result[#result+1] = {x = i, y = y}
    else
        if #result >= 3 then
            allMatches[#allMatches+1] = { data = {type = currentType, color = currentColor}, values = result }
        end
        
        if isNil then
            currentType = nil
            currentColor = nil
            result = {}
        else
            currentType = currentValue.type
            currentColor = currentValue.color
            result = {x = i, y = y}
        end
    end
end
return allMatches
end
--]]

--[[
function findMatch3OrGreaterHorizontal(gameField, width, height, x, y)

    local allMatches = {}
    local result = {}
    local currentValue, currentType, currentColor

    for i = 1, width do
        currentValue = gameField.grid:getValue(i, y)
        if currentValue.type == currentType and currentValue.color == currentColor then
            result[#result+1] = {x = i, y = y}
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

function findMatch3OrGreaterVertical(gameField, width, height, x, y)

    local allMatches = {}
    local result = {}
    local currentValue, currentType, currentColor

    for i = 1, height do
        currentValue = gameField.grid:getValue(x, i)
        if currentValue.type == currentType and currentValue.color == currentColor then
            result[#result+1] = {x = x, y = i}
        else
            if #result >= 3 then
                allMatches[#allMatches+1] = { type = currentType, color = currentColor, values = result }
            end
            currentType = currentValue.type
            currentColor = currentValue.color
            result = {x = i, y = y}
        end
    end

    return allMatches
end

function findAllMatches3OrGreater(gameField)
    local allMatches = {}

    for y = 1, gameField.height do
        local result = findMatch3OrGreaterHorizontal(gameField, gameField.width, gameField.height, 1, y)
        if #result > 0 then
            for _, value in ipairs(result) do
                allMatches[#allMatches+1] = value
                -- allMatches[#allMatches+1] = { matchTypes.matchHorizontal, value }
            end
        end
    end

    for x = 1, gameField.width do
        local result = findMatch3OrGreaterVertical(gameField, gameField.width, gameField.height, x, 1)
        if #result > 0 then
            for _, value in ipairs(result) do
                -- allMatches[#allMatches+1] = { matchTypes.matchVertical, value }
                allMatches[#allMatches+1] = value
            end
        end
    end

    return allMatches
end
--]]

function findAllMatches3OrGreater(gameField)

    local allMatches = {}

    local currentVerticalMatches = {}
    local currentMatch = {}
    local currentValue, currentType, currentColor

    for y = 1, gameField.height do
        currentVerticalMatches[y] = {
            type = nil,
            color = nil,
            match = {}
        }
        for x = 1, gameField.width do
            currentValue = gameField.grid:getValue(x, y)

            if currentVerticalMatches[y].type == currentValue.type and currentVerticalMatches[y].color == currentValue.color then
                currentVerticalMatches[y].match[#currentVerticalMatches[y].match+1] = {x = x, y = y}
            else
                if #currentVerticalMatches[y].match >= 3 then
                    allMatches[#allMatches+1] = { type = currentType, color = currentColor, values = currentVerticalMatches[y].match }
                end
                currentVerticalMatches[y].type = currentValue.type
                currentVerticalMatches[y].color = currentValue.color
                currentVerticalMatches[y].match = {x = x, y = y}
            end

            if currentValue.type == currentType and currentValue.color == currentColor then
                currentMatch[#currentMatch+1] = {x = x, y = y}
            else
                if #currentMatch >= 3 then
                    allMatches[#allMatches+1] = { type = currentType, color = currentColor, values = currentMatch }
                end
                currentType = currentValue.type
                currentColor = currentValue.color
                currentMatch = {x = x, y = y}
            end
        end
    end

    return allMatches
end




function checkHorizontal(gameField, width, height, x, y)
    local result = {}

    local value = gameField.grid:getValue(x, y)
    result[#result+1] = { x = x, y = y, value = value }

    local amount = 1

    for dX = 1, width - x do
        local next = gameField.grid:getValue(x + dX, y)
        if next.type == value.type and next.color == value.color then
            result[#result+1] = { x = x + dX, y = y, value = next }
            amount = amount + 1
        else
            break
        end
    end

    for dX = -1, 1 - x, -1 do
        local previous = gameField.grid:getValue(x + dX, y)
        if previous.type == value.type and previous.color == value.color then
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
    result[#result+1] = { x = x, y = y, value = value }

    local amount = 1

    for dY = 1, height - y do
        local next = gameField.grid:getValue(x, y + dY)
        if next.type == value.type and next.color == value.color then
            result[#result+1] = { x = x, y = y + dY, value = next }
            amount = amount + 1
        else
            break
        end
    end

    for dY = -1, 1 - y, -1 do
        local previous = gameField.grid:getValue(x, y + dY)
        if previous.type == value.type and previous.color == value.color then
            result[#result+1] = { x = x, y = y + dY, value = previous }
            amount = amount + 1
        else
            break
        end
    end

    return amount, result
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
    -- matchTypes = matchTypes,
    findAllMatches3OrGreater = findAllMatches3OrGreater,
    match3OrGreater = match3OrGreater,
}

