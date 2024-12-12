package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local g = grid.create(content)
print("n", g.nx, g.ny)

local directions = {
	{ x = -1, y = 0 },
	{ x = 0, y = -1 },
	{ x = 1, y = 0 },
	{ x = 0, y = 1 }
}

local function price (tier)
	local sumproduct = 0
	for x = 1, g.nx do
		for y = 1, g.ny do
			if g:mark("visited", x, y) then
				goto continue
			end
			local variety = g[x][y]
			local area, length = 0, 0
			local function same (x, y)
				if x < 1 or x > g.nx or y < 1 or y > g.ny then
					return false
				end
				if g[x][y] ~= variety then
					return false
				end
				return true
			end
			local function search (x, y)
				g:mark("visited", x, y, true)
				area = area + 1
				for _, d in ipairs(directions) do
					local nx, ny = x + d.x, y + d.y
					if same(nx, ny) then
						if not g:mark("visited", nx, ny) then
							search(nx, ny)
						end
					else
						if tier == 1 then
							length = length + 1
						elseif tier == 2 then
							-- Check for "continuations" based on two same/not-same patches
							local xs = d.x ~= 0 and x or x - 1
							local ys = d.y ~= 0 and y or y - 1
							local xns = d.x ~= 1 and x - 1 or x + 1
							local yns = d.y ~= 1 and y - 1 or y + 1
							local continuation = same(xs, ys) and not same(xns, yns)
							if not continuation then
								length = length + 1
							end
						end
					end
				end
			end
			search(x, y)
			sumproduct = sumproduct + length * area
			::continue::
		end
	end
	return sumproduct
end

print(price(1))

g:reset("visited")
print(price(2))