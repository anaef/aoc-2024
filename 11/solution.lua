local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local function inc (stones, num, count)
	stones[num] = (stones[num] or 0) + count
end

local stones = { }
for number in string.gmatch(content, "%d+") do
	inc(stones, tonumber(number), 1)
end

local function blink ()
	local blinked = { }
	for num, count in pairs(stones) do
		if num == 0 then
			inc(blinked, 1, count)
			goto continue
		end
		local str = tostring(num)
		local len = string.len(str)
		if len % 2 == 0 then
			local left, right = string.sub(str, 1, len / 2), string.sub(str, len / 2 + 1)
			inc(blinked, tonumber(left), count)
			inc(blinked, tonumber(right), count)
			goto continue
		end
		inc(blinked, num * 2024, count)
		::continue::
	end
	stones = blinked
end

local function count ()
	local sum = 0
	for _, _count in pairs(stones) do
		sum = sum + _count
	end
	return sum
end

for i = 1, 25 do
	blink()
end
print(count())
for i = 26, 75 do
	blink()
end
print(count())