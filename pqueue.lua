_ENV = setmetatable({ }, { __index = _ENV })

-- Returns the parent index
local function parent (index)
	return index // 2
end

-- Return the left child index
local function left (index)
	return 2 * index
end

-- Returns the right child index
local function right (index)
	return 2 * index + 1
end

-- Priority queue methods
local PQUEUE_METHODS = {
	insert = function (h, v)
		table.insert(h, v)
		local p = getmetatable(h).p
		local index = #h
		while index > 1 and p(h[parent(index)]) > p(h[index]) do
			local parentindex = parent(index)
			h[index], h[parentindex] = h[parentindex], h[index]
			index = parentindex
		end
	end,
	pop = function (h)
		local len = #h
		local p = getmetatable(h).p
		local index = 1
		local v = h[1]
		h[1] = h[len]
		h[len] = nil
		len = len - 1
		while true do
			local indexmin = index
			local indexleft = left(index)
			if indexleft <= len and p(h[indexleft]) < p(h[indexmin]) then
				indexmin = indexleft
			end
			local indexright = right(index)
			if indexright <= len and p(h[indexright]) < p(h[indexmin]) then
				indexmin = indexright
			end
			if indexmin == index then
				break
			end
			h[index], h[indexmin] = h[indexmin], h[index]
			index = indexmin
		end
		return v
	end,
}

-- Returns an empty priority queue
function empty (p)
	if p == nil then
		p = function (v) return v end
	elseif type(p) == "string" then
		local key = p
		p = function (v) return v[key] end
	end
	return setmetatable({ }, {
		__index = PQUEUE_METHODS,
		p = p
	})
end

return _ENV