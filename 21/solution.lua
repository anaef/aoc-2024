local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local codes = { }
for code in string.gmatch(content, "[^\n]+") do
	table.insert(codes, code)
end

local numpad = {
	["7"] = { x = 0, y = 0 },
	["8"] = { x = 1, y = 0 },
	["9"] = { x = 2, y = 0 },
	["4"] = { x = 0, y = 1 },
	["5"] = { x = 1, y = 1 },
	["6"] = { x = 2, y = 1 },
	["1"] = { x = 0, y = 2 },
	["2"] = { x = 1, y = 2 },
	["3"] = { x = 2, y = 2 },
	["0"] = { x = 1, y = 3 },
	["A"] = { x = 2, y = 3 },
}

local dirpad = {
	["^"] = { x = 1, y = 0 },
	["A"] = { x = 2, y = 0 },
	["<"] = { x = 0, y = 1 },
	["v"] = { x = 1, y = 1 },
	[">"] = { x = 2, y = 1 },
}

local function haskey (keypad, x, y)
	for _, key in pairs(keypad) do
		if key.x == x and key.y == y then
			return true
		end
	end
	return false
end

local moves = {
	{ dx = 1, dy = 0, stroke = ">" },
	{ dx = 0, dy = 1, stroke = "v" },
	{ dx = -1, dy = 0, stroke = "<" },
	{ dx = 0, dy = -1, stroke = "^" }
}

local function sgn (x)
	return x < 0 and -1 or x > 0 and 1 or x
end

local len  -- forward declaration

local function bfs (padsremaining, pad, x, y, sx, sy)
	local result = math.huge
	local queue = { { x = x, y = y, strokes = "" } }
	while #queue > 0 do
		local node = table.remove(queue, 1)
		if node.x ~= sx or node.y ~= sy then
			for _, move in ipairs(moves) do
				if move.dx ~= 0 and sgn(move.dx) == sgn(sx - node.x)
						or move.dy ~= 0 and sgn(move.dy) == sgn(sy - node.y) then  -- monotonic
					local mx, my = node.x + move.dx, node.y + move.dy
					if haskey(pad, mx, my) then
						local strokes = node.strokes .. move.stroke
						table.insert(queue, { x = mx, y = my, strokes = strokes })
					end
				end
			end
		else
			result = math.min(result, len(padsremaining - 1, node.strokes .. "A"))
		end
	end
	return result
end

local cache = { }

len = function (padsremaining, strokes)
	local cachekey = string.format("%d:%s", padsremaining, strokes)
	local result = cache[cachekey]
	if not result then
		if padsremaining == 1 then
			result = string.len(strokes)
		else
			result = 0
			local x, y = dirpad["A"].x, dirpad["A"].y  -- holds as strokes terminate with 'A'
			for stroke in string.gmatch(strokes, ".") do
				local sx, sy = dirpad[stroke].x, dirpad[stroke].y
				result = result + bfs(padsremaining, dirpad, x, y, sx, sy)
				x, y = sx, sy
			end
		end
		cache[cachekey] = result
	end
	return result
end

local function complexity (padsremaining, code)
	local codelen = 0
	local x, y = numpad["A"].x, numpad["A"].y
	for stroke in string.gmatch(code, ".") do
		local sx, sy = numpad[stroke].x, numpad[stroke].y
		codelen = codelen + bfs(padsremaining, numpad, x, y, sx, sy)
		x, y = sx, sy
	end
	return codelen * tonumber(string.match(code, "^%d+"))
end

local function sumcomplexity (padsremaining)
	local sum = 0
	for _, code in ipairs(codes) do
		sum = sum + complexity(padsremaining, code)
	end
	return sum
end

print(sumcomplexity(1 + 2 + 1))
print(sumcomplexity(1 + 25 + 1))