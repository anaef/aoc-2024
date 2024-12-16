package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")
local pqueue = require("pqueue")
local set = require("set")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local g = grid.create(content)

local dirs = {
	{ x = 1, y = 0 },
	{ x = -1, y = 0 },
	{ x = 0, y = 1 },
	{ x = 0, y = -1 },
}
local ctx = {
	dirs = dirs,
}

local start = g:list("S")[1]
local exit = g:list("E")[1]

local q = pqueue.empty("cost")
q:insert({
	x = start.x,
	y = start.y,
	dir = dirs[1],
	cost = 0
})

local path = set.empty(function (e) return string.format("%d,%d", e.x, e.y) end)

local function getstate (_ctx)
	local state = g:mark(_ctx.dir, _ctx.x, _ctx.y)
	if not state then
		state = {
			visited = false,
			cost = _ctx.x == start.x and _ctx.y == start.y and _ctx.dir == dirs[1] and 0
					or math.huge,
			path = path:copy()
		}
		g:mark(_ctx.dir, _ctx.x, _ctx.y, state)
	end
	return state
end

while #q > 0 do
	local node = q:pop()
	local state = getstate(node)
	if state.visited then
		goto continue
	end
	state.visited = true
	state.path:add({ x = node.x, y = node.y })
	g:step(node.x, node.y, ctx, function (_ctx)
		if _ctx.value == "#" then
			return
		end
		local dirstate = getstate(_ctx)
		if dirstate.visited then
			return
		end
		local cost = state.cost + 1
		if _ctx.dir ~= node.dir then
			cost = cost + 1000
		end
		if cost <= dirstate.cost then
			if cost < dirstate.cost then
				dirstate.path = state.path:copy()
				dirstate.cost = cost
				q:insert({
					x = _ctx.x,
					y = _ctx.y,
					dir = _ctx.dir,
					cost = cost
				})
			else
				dirstate.path:union(state.path)
			end
		end
	end)
	::continue::
end

local cost = math.huge
local best
for _, dir in ipairs(dirs) do
	local state = g:mark(dir, exit.x, exit.y)
	if state and state.cost <= cost then
		if state.cost < cost then
			cost = state.cost
			best = state.path:copy()
		else
			best:union(state.path)
		end
	end
end
print(cost)
print(best:size())