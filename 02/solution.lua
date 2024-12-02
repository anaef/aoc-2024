local input = assert(io.open("input.txt"))
local lines = input:read("*a")
input:close()

local sequences = { }
for line in string.gmatch(lines, "[^\r\n]+") do
	local levels = { }
	for level in string.gmatch(line, "%d+") do
		table.insert(levels, tonumber(level))
	end
	table.insert(sequences, levels)
end
print("n", #sequences)

local function safe (levels)
	local direction, previous
	for i, level in ipairs(levels) do
		if previous then
			local difference = level - previous
			if direction then
				if (difference > 0) ~= (direction > 0) then
					return false
				end
			else
				direction = difference
			end
			local absdifference = math.abs(difference)
			if absdifference < 1 or absdifference > 3 then
				return false
			end
		end
		previous = level
	end
	return true
end

local count = 0
for _, levels in ipairs(sequences) do
	count = count + (safe(levels) and 1 or 0)
end
print(count)

local countdampened = 0
for _, levels in ipairs(sequences) do
	if safe(levels) then
		countdampened = countdampened + 1
		goto continue
	end

	-- Brute-forcing the check as removing a level may change the direction
	for i in ipairs(levels) do
		local levelsdampened = { table.unpack(levels) }
		table.remove(levelsdampened, i)
		if safe(levelsdampened) then
			countdampened = countdampened + 1
			goto continue
		end
	end
	::continue::
end
print(countdampened)
