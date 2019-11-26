return function()
	local functions = {}
	local meta = {
		__add = function(delegates, func)
			functions[#functions + 1] = func
			return delegates
		end,
		__sub = function(delegates, func)
			for i, f in ipairs(functions) do
				if f == func then
					table.remove(functions, i)
				end
			end
			return delegates
        end,
        -- @TODO Try to create a iterator
		__call = function(delegates, ...)
			for _, f in ipairs(functions) do
				f(...)
			end
		end
	}
	return setmetatable({}, meta)
end