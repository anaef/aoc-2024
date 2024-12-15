package.path = package.path .. ";../?.lua;../?/init.lua"
local grid = require("grid")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local gcontent, mcontent = string.match(content, "^(.+)\n\n(.+)$")

local moves = { }
for m in string.gmatch(mcontent, "[<>%^v]") do
	table.insert(moves, m)
end
print("moves", #moves)

local g = grid.create(gcontent)
print("grid", g.nx, g.ny)

local start = g:list("@")[1]
local x, y = start.x, start.y
g[x][y] = "."

local ds = {
	["<"] = { -1, 0 },
	[">"] = { 1, 0 },
	["^"] = { 0, -1 },
	["v"] = { 0, 1 },
}

for _, move in ipairs(moves) do
	local dx, dy = table.unpack(ds[move])
	local nx, ny = x + dx, y + dy
	if g[nx][ny] == "." then
		x, y = nx, ny
	elseif g[nx][ny] == "O" then
		local length = 1
		while g[nx + length * dx][ny + length * dy] == "O" do
			length = length + 1
		end
		if g[nx + length * dx][ny + length * dy] == "." then
			g[nx + length * dx][ny + length * dy], g[nx][ny] = "O", "."
			x, y = nx, ny
		end
	elseif g[nx][ny] == "#" then
		-- Skip
	end
end

local function gpssum (box)
	return g:sum(function (c, x, y)
		if c == box then
			return (y - 1) * 100 + (x - 1)
		end
	end)
end
print(gpssum("O"))

gcontent = string.gsub(gcontent, "#", "##")
gcontent = string.gsub(gcontent, "O", "[]")
gcontent = string.gsub(gcontent, "%.", "..")
gcontent = string.gsub(gcontent, "@", "@.")
g = grid.create(gcontent)
print("grid", g.nx, g.ny)

start = g:list("@")[1]
x, y = start.x, start.y
g[x][y] = "."

local debug = false

-- Checks the grid integrity as regards the boxes
local function check ()
	if debug then
		g:apply(function (c, x, y)
			assert(c ~= "[" or g[x + 1][y] == "]")
			assert(c ~= "]" or g[x - 1][y] == "[")
		end)
	end
end

-- Tests if a move can take place
local function canmove (x, y, dx, dy)
	assert(g[x][y] == "[" or g[x][y] == "]")
	if g[x][y] == "]" then
		x = x - 1
	end
	if dy ~= 0 then
		if g[x][y + dy] == "." and g[x + 1][y + dy] == "." then
			return true
		end
		if g[x][y + dy] == "#" or g[x + 1][y + dy] == "#" then
			return false
		end
		if g[x][y + dy] == "[" then
			return canmove(x, y + dy, dx, dy)
		else
			if g[x][y + dy] == "]" and not canmove(x - 1, y + dy, dx, dy) then
				return false
			end
			if g[x + 1][y + dy] == "[" and not canmove(x + 1, y + dy, dx, dy) then
				return false
			end
			return true
		end
	else
		if dx == 1 then
			if g[x + 2][y] == "." then
				return true
			end
			if g[x + 2][y] == "[" then
				return canmove(x + 2, y, dx, dy)
			end
		else
			if g[x - 1][y] == "." then
				return true
			end
			if g[x - 1][y] == "]" then
				return canmove(x - 2, y, dx, dy)
			end
		end
		return false
	end
end

-- Applies the move
local function domove (x, y, dx, dy)
	assert(g[x][y] == "[" or g[x][y] == "]")
	if g[x][y] == "]" then
		x = x - 1
	end
	if dy ~= 0 then
		if g[x][y + dy] == "[" then
			domove(x, y + dy, dx, dy)
		else
			if g[x][y + dy] == "]" then
				domove(x - 1, y + dy, dx, dy)
			end
			if g[x + 1][y + dy] == "[" then
				domove(x + 1, y + dy, dx, dy)
			end
		end
		g[x][y + dy], g[x + 1][y + dy] = "[", "]"
		g[x][y], g[x + 1][y] = ".", "."
	else
		if dx == 1 then
			if g[x + 2][y] == "[" then
				domove(x + 2, y, dx, dy)
			end
			g[x][y], g[x + 1][y], g[x + 2][y] = ".", "[", "]"
		else
			if g[x - 1][y] == "]" then
				domove(x - 1, y, dx, dy)
			end
			g[x - 1][y], g[x][y], g[x + 1][y] = "[", "]", "."
		end
	end
end

for _, move in ipairs(moves) do
	check()
	assert(g[x][y] == ".")
	local dx, dy = table.unpack(ds[move])
	local nx, ny = x + dx, y + dy
	if g[nx][ny] == "." then
		if debug then
			print("freemove", x, y, dx, dy)
		end
		x, y = nx, ny
	elseif g[nx][ny] == "[" or g[nx][ny] == "]" then
		if canmove(nx, ny, dx, dy) then
			if debug then
				print("move", x, y, dx, dy)
			end
			domove(nx, ny, dx, dy)
			if debug then
				g:dump(nx, ny, "@")
			end
			x, y = nx, ny
		end
	elseif g[nx][ny] == "#" then
		-- Skip
	end
end

print(gpssum("["))