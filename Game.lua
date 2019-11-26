
--initialization

--first dump


-- --@TODO Put inside the tick() function
-- local sleepTime = 0.3

-- local function sleep(s)
--     local ntime = os.clock() + s/10
--     repeat until os.clock() > ntime
-- end

repeat
    --if gameState == still then
    local res = io.stdin:read("l")
    local commandQuit = string.match(res, "^(%s*[q]%s*)$")
    if commandQuit then
        break
    end

    local cellX, cellY, moveToDirection = string.match(res, "^%s*[m]%s+(%d+)%s+(%d+)%s+([lrud])%s*$")
    --local result = move(cellX, cellY, moveToDirection)
    --gameState = tick()
    --dump()

    if cellX ~= nil then
        print("duh")
    else
        print("Wrong input")
    end

until false

