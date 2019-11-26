local enum = require("Enum")

local directions = {
    "Up",
    "Right",
    "Down",
    "Left",
    "UpperRight",
    "LowerRight",
    "LowerLeft",
    "UpperLeft",
}

local EDirection = enum.new("EDirection", directions)

return EDirection