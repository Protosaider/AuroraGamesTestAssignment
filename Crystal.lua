-- @TODO Make readonly struct

local ECrystalType = require("ECrystalType")
local ECrystalColor = require("ECrystalColor")

local Crystal = {
    -- type = "Base",
    -- color = '@'
}


-- local OnCrystalDestroyed = {}
-- setmetatable(OnCrystalDestroyed, {__mode = "k"})

-- function Crystal:setOnCrystalDestroyed(func)
--     if type(func) == 'function' then
--         OnCrystalDestroyed[self] = func
--         return true
--     end
--     return false
-- end

-- function Crystal:callOnCrystalDestroyed(...)
--     return OnCrystalDestroyed[self](...)
-- end


function Crystal:new(crystalType, color)
    local o = {}

    assert(type(crystalType) == type(ECrystalType), "CrystalType is not a ECrystalType")
    assert(type(color) == type(ECrystalColor), "Color is not a ECrystalColor")

    o.type = crystalType
    o.color = color

    -- OnCrystalDestroyed[o] = function ()
    --     return nil
    -- end

    self.__index = self
    self.__tostring = function ()
        return '{' .. tostring(o.type) .. ", " .. tostring(o.color) .. '}'
    end
    setmetatable(o, self)
    return o
end


return Crystal