package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")
local pqueue = require("pqueue")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local g = grid.create(content)

local ctx = {
	dirs = {
		{ x = 1, y = 0 },
		{ x = -1, y = 0 },
		{ x = 0, y = 1 },
		{ x = 0, y = -1 },
	}
}

local start = g:list("S")[1]
local exit = g:list("E")[1]

local function h (stepctx)
	return math.abs(stepctx.x - exit.x) + math.abs(stepctx.y - exit.y)
end

local function findpath ()
	local q = pqueue.empty("hcost")
	q:insert({
		x = start.x,
		y = start.y,
		hcost = 0
	})
	g:mark("cost", start.x, start.y, 0)
	while #q > 0 do
		local node = q:pop()
		if g:mark("visited", node.x, node.y) then
			goto continue
		end
		g:mark("visited", node.x, node.y, true)
		if node.x == exit.x and node.y == exit.y then
			break
		end
		local cost = g:mark("cost", node.x, node.y)
		g:step(node.x, node.y, ctx, function (stepctx)
			if stepctx.value == "#" then
				return
			end
			if g:mark("visited", stepctx.x, stepctx.y) then
				return
			end
			local stepcost = cost + 1
			if stepcost < (g:mark("cost", stepctx.x, stepctx.y) or math.huge) then
				g:mark("cost", stepctx.x, stepctx.y, stepcost)
				g:mark("parent", stepctx.x, stepctx.y, node)
			end
			local hcost = stepcost + h(stepctx)
			if hcost < (g:mark("hcost", stepctx.x, stepctx.y) or math.huge) then
				g:mark("hcost", stepctx.x, stepctx.y, hcost)
				q:insert({
					x = stepctx.x,
					y = stepctx.y,
					hcost = hcost
				})
			end
		end)
		::continue::
	end
	local result = { { x = exit.x, y = exit.y }}
	while true do
		local parent = g:mark("parent", result[1].x, result[1].y)
		if not parent then
			break
		end
		table.insert(result, 1, parent)
	end
	return result
end

local path = findpath()
local pathindexes = { }
for i, pos in ipairs(path) do
	pathindexes[g:pos(pos.x, pos.y)] = i
end

local function cheats (duration, threshold)
	local count = 0
	for i, pos in ipairs(path) do
		local function step (stepctx)
			if g:mark("visited", stepctx.x, stepctx.y) then
				return
			end
			g:mark("visited", stepctx.x, stepctx.y, true)
			local elapsed = math.abs(stepctx.x - pos.x) + math.abs(stepctx.y - pos.y)
			if stepctx.value ~= "#" then
				local pathindex = pathindexes[g:pos(stepctx.x, stepctx.y)]
				local saving = (pathindex - i) - elapsed
				if saving >= threshold then
					count = count + 1
				end
			end
			if elapsed < duration then
				g:step(stepctx.x, stepctx.y, ctx, step)
			end
		end
		g:reset("visited")
		g:step(pos.x, pos.y, ctx, step)
	end
	return count
end

print(cheats(2, 100))
print(cheats(20, 100))