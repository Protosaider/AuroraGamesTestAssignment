
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

function match3OrGreater(gameField, width, height, x, y)
    if width <= 2 then
        return nil
    end

    local value = gameField.grid:getValue(x + 1, y)
end

return {

}

