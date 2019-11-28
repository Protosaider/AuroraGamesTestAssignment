local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")

local potentialMatchTypes = {
    matchHorizontal = "MatchHorizontal",
    matchVertical = "MatchVertical",
    swapVertical = "SwapVertical",
    swapHorizontal = "SwapHorizontal"
}


-- * * * *   A * * *
-- * A A *   * A A *
-- A * * *   * * * *
function checkHorizontalLeft(gameField, width, height, x, y)
    local status = false
    local result = {}

    if (x > 1) and (x < width) then
        local center = gameField.grid:getValue(x, y)
        local right = gameField.grid:getValue(x + 1, y)
        if (center.type == right.type) and (center.color == right.color) then
            if y < height then
                local lowerLeft = gameField.grid:getValue(x - 1, y + 1)
                if (center.type == lowerLeft.type) and (center.color == lowerLeft.color) then
                    status = true
                    result[#result+1] = {from = {x = x - 1, y = y + 1}, to = {x = x - 1, y = y}}
                end
            end
            if y > 1 then
                local upperLeft = gameField.grid:getValue(x - 1, y - 1)
                if (center.type == upperLeft.type) and (center.color == upperLeft.color) then
                    status = true
                    result[#result+1] = {from = {x = x - 1, y = y - 1}, to = {x = x - 1, y = y}}
                end
            end
        end
    end
    
    return status, result
end

-- * * * *   * * * A
-- * A A *   * A A *
-- * * * A   * * * *
function checkHorizontalRight(gameField, width, height, x, y)
    local status = false
    local result = {}

    if (x > 1) and (x < width) then
        local center = gameField.grid:getValue(x, y)
        local left = gameField.grid:getValue(x - 1, y)
        if (center.type == left.type) and (center.color == left.color) then
            if y < height then
                local lowerRight = gameField.grid:getValue(x + 1, y + 1)
                if (center.type == lowerRight.type) and (center.color == lowerRight.color) then
                    status = true
                    result[#result+1] = {from = {x = x + 1, y = y + 1}, to = {x = x + 1, y = y}}
                end
            end
            if y > 1 then
                local upperRight = gameField.grid:getValue(x + 1, y - 1)
                if (center.type == upperRight.type) and (center.color == upperRight.color) then
                    status = true
                    result[#result+1] = {from = {x = x + 1, y = y - 1}, to = {x = x + 1, y = y}}
                end
            end
        end
    end
    
    return status, result
end

-- * * * *   * * * *
-- A A * A   A * A A
-- * * * *   * * * *
function checkHorizontalCenter(gameField, width, height, x, y)
    local status = false
    local result = {}

    if x < width - 2 then
        local left = gameField.grid:getValue(x, y)
        local centerLeft = gameField.grid:getValue(x + 1, y)
        local centerRight = gameField.grid:getValue(x + 2, y)
        local right = gameField.grid:getValue(x + 3, y)

        if  (left.type == centerLeft.type) and
            (left.color == centerLeft.color) and
            (left.type == right.type) and
            (left.color == right.color)
            then
                status = true
                result[#result+1] = {from = {x = x + 3, y = y}, to = {x = x + 2, y = y}}
        end

        if  (left.type == centerRight.type) and
            (left.color == centerRight.color) and
            (left.type == right.type) and
            (left.color == right.color)
            then
                status = true
                result[#result+1] = {from = {x = x, y = y}, to = {x = x + 1, y = y}}
        end
    end
    
    return status, result
end

-- * A * *   * * * *
-- A * A *   A * A *
-- * * * *   * A * *
function checkHorizontalInner(gameField, width, height, x, y)
    local status = false
    local result = {}

    if x < width and x > 1 then
        local center = gameField.grid:getValue(x, y)

        if y < height then
            local lowerLeft = gameField.grid:getValue(x - 1, y + 1)
            local lowerRight = gameField.grid:getValue(x + 1, y + 1)

            if  (center.type == lowerLeft.type) and
                (center.color == lowerLeft.color) and
                (center.type == lowerRight.type) and
                (center.color == lowerRight.color)
                then
                    status = true
                    result[#result+1] = {from = {x = x, y = y}, to = {x = x, y = y + 1}}
            end
        end

        if y > 1 then
            local upperLeft = gameField.grid:getValue(x - 1, y - 1)
            local upperRight = gameField.grid:getValue(x + 1, y - 1)

            if  (center.type == upperLeft.type) and
                (center.color == upperLeft.color) and
                (center.type == upperRight.type) and
                (center.color == upperRight.color)
                then
                    status = true
                    result[#result+1] = {from = {x = x, y = y}, to = {x = x, y = y - 1}}
            end
        end
    end
    
    return status, result
end


-- A * * *   * * A *
-- * A * *   * A * *
-- * A * *   * A * *
function checkVerticalUp(gameField, width, height, x, y)
    local status = false
    local result = {}

    if (y > 1) and (y < height) then
        local center = gameField.grid:getValue(x, y)
        local down = gameField.grid:getValue(x, y + 1)
        if (center.type == down.type) and (center.color == down.color) then
            if x > 1 then
                local upperLeft = gameField.grid:getValue(x - 1, y - 1)
                if (center.type == upperLeft.type) and (center.color == upperLeft.color) then
                    status = true
                    result[#result+1] = {from = {x = x - 1, y = y - 1}, to = {x = x, y = y - 1}}
                end
            end
            if x < width then
                local upperRight = gameField.grid:getValue(x + 1, y - 1)
                if (center.type == upperRight.type) and (center.color == upperRight.color) then
                    status = true
                    result[#result+1] = {from = {x = x + 1, y = y - 1}, to = {x = x, y = y - 1}}
                end
            end
        end
    end
    
    return status, result
end

-- * A * *   * A * *
-- * A * *   * A * *
-- A * * *   * * A *
function checkVerticalDown(gameField, width, height, x, y)
    local status = false
    local result = {}

    if (y > 1) and (y < height) then
        local center = gameField.grid:getValue(x, y)
        local up = gameField.grid:getValue(x, y - 1)
        if (center.type == up.type) and (center.color == up.color) then
            if x > 1 then
                local lowerLeft = gameField.grid:getValue(x - 1, y + 1)
                if (center.type == lowerLeft.type) and (center.color == lowerLeft.color) then
                    status = true
                    result[#result+1] = {from = {x = x - 1, y = y + 1}, to = {x = x, y = y + 1}}
                end
            end
            if x < width then
                local lowerRight = gameField.grid:getValue(x + 1, y + 1)
                if (center.type == lowerRight.type) and (center.color == lowerRight.color) then
                    status = true
                    result[#result+1] = {from = {x = x + 1, y = y + 1}, to = {x = x, y = y + 1}}
                end
            end
        end
    end
    
    return status, result
end


-- * A * *   * A * *
-- * A * *   * * * *
-- * * * *   * A * *
-- * A * *   * A * *
function checkVerticalCenter(gameField, width, height, x, y)
    local status = false
    local result = {}

    if y < height - 2 then
        local up = gameField.grid:getValue(x, y)
        local centerUp = gameField.grid:getValue(x, y + 1)
        local centerDown = gameField.grid:getValue(x, y + 2)
        local down = gameField.grid:getValue(x, y + 3)

        if  (up.type == centerUp.type) and
            (up.color == centerUp.color) and
            (up.type == down.type) and
            (up.color == down.color)
            then
                status = true
                result[#result+1] = {from = {x = x, y = y + 3}, to = {x = x, y = y + 2}}
        end

        if  (up.type == centerDown.type) and
            (up.color == centerDown.color) and
            (up.type == down.type) and
            (up.color == down.color)
            then
                status = true
                result[#result+1] = {from = {x = x, y = y}, to = {x = x, y = y + 1}}
        end
    end
    
    return status, result
end

-- * A * *   * A * *
-- * * A *   A * * *
-- * A * *   * A * *
function checkVerticalInner(gameField, width, height, x, y)
    local status = false
    local result = {}

    if y < height and y > 1 then
        local center = gameField.grid:getValue(x, y)

        if x > 1 then
            local lowerLeft = gameField.grid:getValue(x - 1, y + 1)
            local upperLeft = gameField.grid:getValue(x - 1, y - 1)

            if  (center.type == lowerLeft.type) and
                (center.color == lowerLeft.color) and
                (center.type == upperLeft.type) and
                (center.color == upperLeft.color)
                then
                    status = true
                    result[#result+1] = {from = {x = x, y = y}, to = {x = x - 1, y = y}}
            end
        end

        if x < width then
            local lowerRight = gameField.grid:getValue(x + 1, y + 1)
            local upperRight = gameField.grid:getValue(x + 1, y - 1)

            if  (center.type == lowerRight.type) and
                (center.color == lowerRight.color) and
                (center.type == upperRight.type) and
                (center.color == upperRight.color)
                then
                    status = true
                    result[#result+1] = {from = {x = x, y = y}, to = {x = x + 1, y = y}}
            end
        end
    end
    
    return status, result
end

function checkAllHorizontal(gameField, width, height, x, y)
    local allResults = {}
    local allStatus = false

    local status, result = checkHorizontalLeft(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalRight(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalCenter(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalInner(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    return allStatus, allResults
end

function checkAllVertical(gameField, width, height, x, y)
    local allResults = {}
    local allStatus = false

    local status, result = checkVerticalUp(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalDown(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalCenter(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalInner(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    return allStatus, allResults
end

function findAllPotentialMatches3(gameField, width, height)

    local allPotentialMatches = {}
    local allHorizontal = {}
    local allVertical = {}
    local allStatus = false

    for y = 1, height do
        for x = 1, width do
            local status, result = checkAllHorizontal(gameField, width, height, x, y)
            if status then
                allStatus = true
                for _, value in ipairs(result) do
                    allHorizontal[#allHorizontal+1] = value
                end
            end
            status, result = checkAllVertical(gameField, width, height, x, y)
            if status then
                allStatus = true
                for _, value in ipairs(result) do
                    allVertical[#allVertical+1] = value
                end
            end
        end
    end

    for _, value in ipairs(allHorizontal) do
        allPotentialMatches[#allPotentialMatches+1] = {potentialMatchTypes.matchHorizontal, value}
    end
    for _, value in ipairs(allVertical) do
        allPotentialMatches[#allPotentialMatches+1] = {potentialMatchTypes.matchVertical, value}
    end

    return allStatus, allPotentialMatches
end



function checkVerticalSwap(gameField, width, height, x, y)
    local allResults = {}
    local allStatus = false

    local status, result = checkHorizontalLeft(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalRight(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalCenter(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalInner(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    return allStatus, allResults
end

function checkHorizontalSwap(gameField, width, height, x, y)
    local allResults = {}
    local allStatus = false

    local status, result = checkVerticalUp(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalDown(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkHorizontalCenter(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    status, result = checkVerticalInner(gameField, width, height, x, y)
    if status then
        allStatus = true
        for _, value in ipairs(result) do
            allResults[#allResults+1] = value
        end
    end
    return allStatus, allResults
end

function findAllPotentialMatches3Swap(gameField)

    local allPotentialMatches = {}
    local allHorizontal = {}
    local allVertical = {}
    local allStatus = false

    for y = 1, gameField.height do
        for x = 1, gameField.width do
            local status, result = checkVerticalSwap(gameField, gameField.width, gameField.height, x, y)
            if status then
                allStatus = true
                for _, value in ipairs(result) do
                    allVertical[#allVertical+1] = value
                end
            end
            status, result = checkHorizontalSwap(gameField, gameField.width, gameField.height, x, y)
            if status then
                allStatus = true
                for _, value in ipairs(result) do
                    allHorizontal[#allHorizontal+1] = value
                end
            end
        end
    end


    allPotentialMatches[potentialMatchTypes.swapVertical] = allVertical
    allPotentialMatches[potentialMatchTypes.swapHorizontal] = allHorizontal

    return allStatus, allPotentialMatches
end



return {
    potentialMatchTypes = potentialMatchTypes,

    findAllPotentialMatches3 = findAllPotentialMatches3,
    findAllPotentialMatches3Swap = findAllPotentialMatches3Swap,
}

