
local Game = require("Game")
local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")

Game.init()

Game.dump()

local isWaitingForInput = true

repeat

    if isWaitingForInput then

        local res = io.stdin:read("l")
        local commandQuit = string.match(res, "^(%s*[q]%s*)$")

        if commandQuit then
            break
        end
        
        local fromX, fromY, moveToDirection = string.match(res, "^%s*[m]%s+(%d+)%s+(%d+)%s+([lrud])%s*$")

        if fromX ~= nil then
            local directionTo

            if moveToDirection == 'l' then
                directionTo = EDirection.Left
            elseif moveToDirection == 'r' then
                directionTo = EDirection.Right
            elseif moveToDirection == 'u' then
                directionTo = EDirection.Up
            elseif moveToDirection == 'd' then
                directionTo = EDirection.Down
            end

            Game.move({x = fromX, y = fromY}, directionTo)
        else
            Game.move(nil, nil)
        end

    end

    isWaitingForInput = Game.tick()

    Game.dump()

until false

