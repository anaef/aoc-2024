package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local g = grid.create(content, function (height) return tonumber(height) end)
print("n", g.nx, g.ny)

function step (ctx)
	if ctx.value == ctx.prev.value + 1 then
		if ctx.value == 9 then
			g:inc("peak", ctx.x, ctx.y, 1)
		else
			g:step(ctx.x, ctx.y, ctx, step)
		end
	end
end

local ctx = {
	dirs = {
		{ x = 0, y = 1 },
		{ x = 0, y = -1 },
		{ x = 1, y = 0 },
		{ x = -1, y = 0 }
	},
}
local count, sum = 0, 0
g:apply(function (height, x, y)
	if height == 0 then
		g:reset("peak")
		g:step(x, y, ctx, step)
		count = count + g:count("peak")
		sum = sum + g:sum("peak")
	end
end)
print(count)
print(sum)