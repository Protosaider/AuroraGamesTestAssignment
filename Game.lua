local N = 10
local M = 12

local indexSpace = ' '
local separatorItemVertical = '|'
local separatorItemHorizontal = '-'
local newline = '\n'
local nilItem = '*'

--@TODO Put inside the tick() function
local sleepTime = 0.25

local function sleep(s)
    local ntime = os.clock() + s / 10
    repeat until os.clock() > ntime
end


local GameField = require("GameField")
local GameFieldVisualizer = require("GameFieldVisualizer")

local EDirection = require("EDirection")
local EDirectionHelper = require("EDirectionHelper")

local gameField = GameField:new(N, M)
local visualizer = GameFieldVisualizer:new(N, M, indexSpace, separatorItemVertical, separatorItemHorizontal, newline, nilItem)

local function tick()
    local isWaitingForInput = gameField:tick()
    if not isWaitingForInput then
        sleep(sleepTime)
    end
    return isWaitingForInput
end

local function init()
    gameField:init()
end

local function move(from, to)
    if from == nil then
        visualizer:setMessage("Wrong input")
        return
    end

    local oppositeDirection = EDirectionHelper.opposite(to)
    local toOffset = EDirectionHelper.offset(to)

    local fromData = {
        x = from.x,
        y = from.y,
        direction = to
    }

    local toData = {
        x = from.x + toOffset[1],
        y = from.y + toOffset[2],
        direction = oppositeDirection
    }

    local msg = gameField:move(fromData, toData)
    visualizer:setMessage(msg)
end

return {
    dump = function ()
        visualizer:dump(gameField)
    end,
    init = init,
    tick = tick,
    move = move,
}