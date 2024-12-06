local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local ybase = { }
local ystart, xstart
for line in string.gmatch(content, "[^\n\r]+") do
	local x = { }
	for char in string.gmatch(line, ".") do
		table.insert(x, char)
		if char == "^" then
			ystart, xstart = #ybase + 1, #x
		end
	end
	assert(#ybase == 0 or #x == #ybase[1])
	table.insert(ybase, x)
end
local ny, nx = #ybase, #ybase[1]
print("n", ny, nx)

local directions = {
	{ -1, 0 },
	{ 0, 1 },
	{ 1, 0 },
	{ 0, -1 },
}

local function patrol (oi, oj)
	local y = { }
	local yd = { }
	for _, x in ipairs(ybase) do
		table.insert(y, { table.unpack(x) })
		table.insert(yd, { })
	end
	if oi and oj then
		y[oi][oj] = "#"
	end
	local sites = 0
	local dindex = 1
	local i, j = ystart, xstart
	while true do
		if y[i][j] ~= "X" then
			y[i][j] = "X"
			sites = sites + 1
		end
		local d = yd[i][j]
		if not d then
			d = { }
			yd[i][j] = d
		end
		if d[dindex] then
			return sites, true, y  -- revisited w/ same direction
		end
		d[dindex] = true
		local direction = directions[dindex]
		i, j = i + direction[1], j + direction[2]
		if i < 1 or i > ny or j < 1 or j > nx then
			return sites, false, y  -- walked off-grid
		end
		if y[i][j] == "#" then
			i, j = i - direction[1], j - direction[2]
			dindex = (dindex % #directions) + 1
		end
	end
end

local sites, loop, ypatrol = patrol()
assert(not loop)
print(sites)

local loops = 0
for i = 1, ny do
	for j = 1, nx do
		if ybase[i][j] == "." and ypatrol[i][j] ~= "." then
			loops = loops + (select(2, patrol(i, j)) and 1 or 0)
		end
	end
end
print(loops)