local N = 10
local M = 12

math.randomseed(1000)

local indexSpace = ' '
local separatorItemVertical = '|'
local separatorItemHorizontal = '-'
local newline = '\n'
local nilItem = '*'

local sleepTime = 0.55

local function sleep(s)
    -- io.stdin:read("l")
    local ntime = os.clock() + s
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
    visualizer:setMessage(msg or "")
end

local function dump()
    visualizer:dump(gameField)
end

return {
    dump = dump,
    init = init,
    tick = tick,
    move = move,
}