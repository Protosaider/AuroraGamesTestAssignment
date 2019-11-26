-- @TODO Make readonly struct

local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")

local Crystal = {
    -- type = "Base",
    -- color = '@'
}

function Crystal:new(crystalType, color)
    local o = {}

    assert(type(crystalType) == type(ECrystalType), "CrystalType is not a ECrystalType")
    assert(type(color) == type(ECrystalColor), "Color is not a ECrystalColor")

    o.type = crystalType
    o.color = color

    self.__index = self
    self.__tostring = function ()
        return '{' .. tostring(o.type) .. ", " .. tostring(o.color) .. '}'
    end
    setmetatable(o, self)
    return o
end

return Crystal