_ENV = setmetatable({ }, { __index = _ENV })

-- Set methods
local SET_METHODS = {
	add = function (s, e)
		s[getmetatable(s).h(e)] = true
	end,
	remove = function (s, e)
		s[getmetatable(s).h(e)] = nil
	end,
	contains = function (s, e)
		return s[getmetatable(s).h(e)]
	end,
	union = function (s, s1)
		assert(getmetatable(s) == getmetatable(s1))
		for k in pairs(s1) do
			s[k] = true
		end
	end,
	intersect = function (s, s1)
		assert(getmetatable(s) == getmetatable(s1))
		for k in pairs(s) do
			if not s1[k] then
				s[k] = nil
			end
		end
	end,
	size = function (s)
		local size = 0
		for _ in pairs(s) do
			size = size + 1
		end
		return size
	end,
	copy = function (s)
		local result = { }
		for k in pairs(s) do
			result[k] = true
		end
		return setmetatable(result, getmetatable(s))
	end,
}

-- Creates an empty set
function empty (h)
	if h == nil then
		h = function (e) return e end
	elseif type(h) == "string" then
		local key = h
		h = function (e) return e[key] end
	end
	return setmetatable({ }, {
		__index = SET_METHODS,
		h = h
	})
end

-- Creates a set of one
function one (e, h)
	local result = empty(h)
	result:add(e)
	return result
end

-- Return module
return _ENV