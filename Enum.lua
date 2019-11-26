--[[
    Copyright 2017 Stefano Mazzucco (https://github.com/stefano-m)
    Modified by Protosaider

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--]]

local function createMetatableForEnumValue(enumName, enumType, enumValue, enumValueIndex)
    return {
        __index = {
            value = enumValue,
            index = enumValueIndex,
            type = enumType,
            isSameEnumType = function (other)
                return type(other) == "table" and other.type ~= nil and getmetatable(other).__type == enumType
            end
        },
        __newindex = function ()
            print("in enum value, newindex")
            return nil
        end,
        __eq = function (this, other)
            return this.type == other.type and this.value == other.value
        end,
        __tostring = function ()
            -- return enumName .. ": (" .. enumValue .. " = " .. enumValueIndex .. ")"
            return enumValue
        end,
        __type = enumType,
    }
end

local function createMetatableForEnumProxy(enumName, enumLength)
    return {
        __index = function (t, k)
            -- local value = t[k]
            print("in Proxy index, go to rawget")
            local value = rawget(t, k)
            if value == nil then
                error "Invalid key"
            end
            return value
        end,
        __newindex = function (t, k, v)
            print("in Proxy newindex")
            error("Attempt to update a read-only table", 2)
        end,
        __tostring = function ()
            return tostring(enumName)
        end,
        __len = function ()
            return enumLength
        end
    }
end

local function new(name, values)

    -- public readonly table http://lua-users.org/wiki/ReadOnlyTables
    local proxy = {}
    local enumType = {}

    -- find duplicates
    local checkedValues = {}
    for _, value in ipairs(values) do
        print("enum"..type(value).." "..value) ---!!!!!!!!!!!!!!!!!!!!!!
        if type(value) ~= "string" then
            error("Invalid enum value type: string expected", 2)
        end

        if checkedValues[value] ~= nil then
            error("Found enum's value duplicate: " .. value , 2)
        end

        checkedValues[value] = true
    end

    for enumIndex, enumValue in ipairs(values) do
        -- PROBLEM, THAT CANNOT BE SOLVED: in objects or in debug mode enum's values will be shown as nil
        local o = {}

        local mt = createMetatableForEnumValue(name, enumType, enumValue, enumIndex)
        setmetatable(o, mt)
        proxy[enumValue] = o
        proxy[enumIndex] = o

        -- local originalType = type  -- saves `type` function
        -- -- monkey patch type function
        -- type = function(obj)
        --     local _type = originalType(obj)
        --     if _type == "table" and getmetatable(obj).__type == enumType then
        --         return enumType
        --     end
        -- end
        
        print("enum index and value " .. enumIndex .. " " .. enumValue)

        function o.enumType(o)
            return getmetatable(o).__type
        end
    end


    local proxyMt = createMetatableForEnumProxy(name, #values)
    setmetatable(proxy, proxyMt)

    -- http://lua-users.org/wiki/ReadOnlyTables
    -- return proxy of proxy, so tables, that are associated as enum's value will be readonly
    return setmetatable({}, {
        __index = proxy,
        __newindex = function(table, key, value)
            print("proxy of proxy newindex")
            error("Attempt to modify read-only table")
        end,
        __metatable = false,
        __len = getmetatable(proxy).__len,
      })
end


return {
    new = new,
}
