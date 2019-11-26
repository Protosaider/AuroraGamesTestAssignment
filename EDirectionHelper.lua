local EDirection = require("EDirection")

local function opposite(direction)
    -- check type
    -- return opposite
    if direction == EDirection.Up then
        return EDirection.Down
    elseif direction == EDirection.Down then
        return EDirection.Up

    elseif direction == EDirection.Right then
        return EDirection.Left
    elseif direction == EDirection.Left then
        return EDirection.Right

    elseif direction == EDirection.UpperRight then
        return EDirection.LowerLeft
    elseif direction == EDirection.LowerLeft then
        return EDirection.UpperRight

    elseif direction == EDirection.LowerRight then
        return EDirection.UpperLeft
    elseif direction == EDirection.UpperLeft then
        return EDirection.LowerRight

    end
end

return {
    opposite = opposite
}