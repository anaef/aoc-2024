local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local y = { }
for line in string.gmatch(content, "[^\n\r]+") do
	local x = { }
	for char in string.gmatch(line, "%u") do
		table.insert(x, char)
	end
	table.insert(y, x)
end
local ny, nx = #y, #y[1]
print("n", ny, nx)

local function search (i, j, word, k, di, dj)
	if y[i] and y[i][j] == word[k] then
		if k == #word then
			return true
		end
		return search(i + di, j + dj, word, k + 1, di, dj, word)
	end
	return false
end

local word = { "X", "M", "A", "S" }
local directions = {
	{ 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 },
	{ 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 }
}
local count = 0
for i = 1, ny do
	for j = 1, nx do
		for _, direction in ipairs(directions) do
			if search(i, j, word, 1, table.unpack(direction)) then
				count = count + 1
			end
		end
	end
end
print(count)

local word2 = { "M", "A", "S" }
local directions2 = { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } }
local count2 = 0
local centers = { }
for i = 1, ny do
	for j = 1, nx do
		for _, direction in ipairs(directions2) do
			if search(i, j, word2, 1, table.unpack(direction)) then
				local ci = i + direction[1]
				local cj = j + direction[2]
				local key = string.format("%d,%d", ci, cj)
				if centers[key] then
					count2 = count2 + 1
				else
					centers[key] = true
				end
			end
		end
	end
end
print(count2)
