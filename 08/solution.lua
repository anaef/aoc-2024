local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local ybase = { }
for line in string.gmatch(content, "[^\n\r]+") do
	local x = { }
	for char in string.gmatch(line, ".") do
		table.insert(x, char)
	end
	assert(#ybase == 0 or #x == #ybase[1])
	table.insert(ybase, x)
end
local ny, nx = #ybase, #ybase[1]
print("n", ny, nx)

local frequencies = { }
for i, x in ipairs(ybase) do
	for j, c in ipairs(x) do
		if c == "." then
			goto continue
		end
		local antennas = frequencies[c]
		if not antennas then
			antennas = { }
			frequencies[c] = antennas
		end
		table.insert(antennas, { x = j, y = i })
		::continue::
	end
end

local count, sites = 0, { }
local function add (x, y)
	if x < 1 or x > nx or y < 1 or y > ny then
		return false
	end
	local key = string.format("%d,%d", x, y)
	if not sites[key] then
		sites[key] = true
		count = count + 1
	end
	return true
end
for _, antennas in pairs(frequencies) do
	for i, antenna in ipairs(antennas) do
		local x, y = antenna.x, antenna.y
		for j = i + 1, #antennas do
			local dx, dy = antennas[j].x - x, antennas[j].y - y
			add(x - dx, y - dy)
			add(x + 2 * dx, y + 2 * dy)
		end
	end
end
print(count)

count, sites = 0, { }
for _, antennas in pairs(frequencies) do
	for i, antenna in ipairs(antennas) do
		for j = i + 1, #antennas do
			local x, y = antenna.x, antenna.y
			local dx, dy = antennas[j].x - x, antennas[j].y - y
			while add(x, y) do
				x, y = x + dx, y + dy
			end
			x, y = antenna.x, antenna.y
			repeat
				x, y = x - dx, y - dy
			until not add(x, y)
		end
	end
end
print(count)