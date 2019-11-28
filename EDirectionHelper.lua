local EDirection = require("EDirection")

local function opposite(direction)
    -- check type
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

local directionVectors = {}
directionVectors[EDirection.Up] =           {0, -1}
directionVectors[EDirection.Right]  =       {1, 0}
directionVectors[EDirection.Down] =         {0, 1}
directionVectors[EDirection.Left] =         {-1, 0}
directionVectors[EDirection.UpperRight] =   {1, -1}
directionVectors[EDirection.LowerRight] =   {1, 1}
directionVectors[EDirection.LowerLeft] =    {-1, 1}
directionVectors[EDirection.UpperLeft] =    {-1, -1}

local function offset(direction)
    return directionVectors[direction]
end

return {
    opposite = opposite,
    offset = offset,
}