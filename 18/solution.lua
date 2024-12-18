package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")
local pqueue = require("pqueue")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local g = grid.full(71, 71, ".")

local partition = 1024

local bytes = { }
for x, y in string.gmatch(content, "(%d+),(%d+)") do
	table.insert(bytes, { x = tonumber(x), y = tonumber(y) })
end

local dirs = {
	{ x = 1, y = 0 },
	{ x = -1, y = 0 },
	{ x = 0, y = 1 },
	{ x = 0, y = -1 },
}
local ctx = {
	dirs = dirs,
}

local start = { x = 1, y = 1 }
local exit = { x = g.nx, y = g.ny }

local function getstate (_ctx)
	local state = g:mark("state", _ctx.x, _ctx.y)
	if not state then
		state = {
			visited = false,
			cost = _ctx.x == start.x and _ctx.y == start.y and 0 or math.huge,
			hcost = _ctx.x == start.x and _ctx.y == start.y and 0 or math.huge,
		}
		g:mark("state", _ctx.x, _ctx.y, state)
	end
	return state
end

local function h (_ctx)
	return math.abs(exit.x - _ctx.x) + math.abs(exit.y - _ctx.y)
end

function astarsearch ()
	g:reset("state")
	local q = pqueue.empty("hcost")
	q:insert({
		x = start.x,
		y = start.y,
		hcost = 0
	})
	while #q > 0 do
		local node = q:pop()
		local state = getstate(node)
		if state.visited then
			goto continue
		end
		state.visited = true
		if node.x == exit.x and node.y == exit.y then
			break
		end
		g:step(node.x, node.y, ctx, function (_ctx)
			if _ctx.value == "#" then
				return
			end
			local dirstate = getstate(_ctx)
			if dirstate.visited then
				return
			end
			local cost = state.cost + 1
			if cost < dirstate.cost then
				dirstate.cost = cost
			end
			local hcost = cost + h(_ctx)
			if hcost < dirstate.hcost then
				dirstate.hcost = hcost
				q:insert({
					x = _ctx.x,
					y = _ctx.y,
					hcost = hcost
				})
			end
		end)
		::continue::
	end
	return g:mark("state", g.nx, g.ny)
end

for i, b in ipairs(bytes) do
	g[b.x + 1][b.y + 1] = "#"
	if i == partition then
		break
	end
end
print(astarsearch().cost)

local lower, upper = partition + 1, #bytes
while lower <= upper do
	local median = math.floor((lower + upper) / 2)
	for i = lower, median do
		local b = bytes[i]
		g[b.x + 1][b.y + 1] = "#"
	end
	if astarsearch() then
		lower = median + 1
	else
		upper = median - 1
		for i = lower, median do
			local b = bytes[i]
			g[b.x + 1][b.y + 1] = "."
		end
	end
end
print(string.format("%d,%d", bytes[lower].x, bytes[lower].y))