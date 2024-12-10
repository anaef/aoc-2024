_ENV = setmetatable({ }, { __index = _ENV })

-- Grid methods
local GRID_METATABLE
local GRID_METHODS = {
	apply = function (g, f)
		for x = 1, g.nx do
			for y = 1, g.ny do
				f(g[x][y], x, y)
			end
		end
	end,
	map = function (g, f)
		local gm = setmetatable({
			nx = g.nx,
			ny = g.ny,
			marks = { },
			stacks = { },
		}, GRID_METATABLE)
		for x = 1, g.nx do
			local gmy = { }
			for y = 1, g.ny do
				gmy[y] = f(g[x][y], x, y)
			end
			table.insert(gm, gmy)
		end
		return gm
	end,
	list = function (g, f)
		local result = { }
		for x = 1, g.nx do
			for y = 1, g.ny do
				local value = f(g[x][y], x, y)
				if value then
					table.insert(result, { value = value, x = x, y = y })
				end
			end
		end
		return result
	end,
	mark = function (g, key, x, y, value)
		local marks = g.marks[key]
		if not marks then
			marks = { }
			g.marks[key] = marks
		end
		local pos = (y - 1) * g.nx + x
		if value then
			marks[pos] = value
		end
		return marks[pos]
	end,
	inc = function (g, key, x, y, inc)
		return g:mark(key, x, y, (g:mark(key, x, y) or 0) + inc)
	end,
	push = function (g, key)
		local stack = g.stacks[key]
		if not stack then
			stack = { }
			g.stacks[key] = stack
		end
		local copy = { }
		local marks = g.marks[key]
		if marks then
			for pos, value in pairs(marks) do
				copy[pos] = value
			end
		end
		table.insert(stack, copy)
	end,
	pop = function (g, key)
		g.marks[key] = table.remove(g.stacks[key])
	end,
	reset = function (g, key)
		g.marks[key] = nil
		g.stacks[key] = nil
	end,
	count = function (g, f)
		local count = 0
		if type(f) == "string" then
			for x = 1, g.nx do
				for y = 1, g.ny do
					if g:mark(f, x, y) then
						count = count + 1
					end
				end
			end
		elseif type(f) == "function" then
			for x = 1, g.nx do
				for y = 1, g.ny do
					if f(g[x][y], x, y) then
						count = count + 1
					end
				end
			end
		end
		return count
	end,
	sum = function (g, f)
		local sum = 0
		if type(f) == "string" then
			for x = 1, g.nx do
				for y = 1, g.ny do
					sum = sum + (g:mark(f, x, y) or 0)
				end
			end
		elseif type(f) == "function" then
			for x = 1, g.nx do
				for y = 1, g.ny do
					sum = sum + (f(g[x][y], x, y) or 0)
				end
			end
		end
		return sum
	end,
	step = function (g, x, y, ctx, f)
		local prev = {
			value = g[x][y],
			x = x,
			y = y
		}
		for _, dir in ipairs(ctx.dirs) do
			local sx, sy = x + dir.x, y + dir.y
			if sx >= 1 and sx <= g.nx and sy >= 1 and sy <= g.ny then
				local sctx = {
					value = g[sx][sy],
					x = sx,
					y = sy,
					prev = prev,
					dir = dir
				}
				for key, value in pairs(ctx) do
					if sctx[key] == nil then
						sctx[key] = value
					end
				end
				f(sctx)
			end
		end
	end,
}
GRID_METATABLE = {
	__index = GRID_METHODS,
}

-- Creates a grid
function create (input, map)
	local gy = { }
	for line in string.gmatch(input, "[^\n\r]+") do
		local x = { }
		for char in string.gmatch(line, ".") do
			table.insert(x, map and map(char) or char)
		end
		assert(#gy == 0 or #x == #gy[1])
		table.insert(gy, x)
	end
	local ny, nx = #gy, #gy[1]
	local gx = {
		nx = nx,
		ny = ny,
		marks = { },
		stacks = { }
	}
	for x = 1, nx do
		local gxy = { }
		for y = 1, ny do
			gxy[y] = gy[y][x]
		end
		table.insert(gx, gxy)
	end
	return setmetatable(gx, GRID_METATABLE)
end

-- Return module
return _ENV