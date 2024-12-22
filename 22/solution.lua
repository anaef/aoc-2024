local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local numbers = { }
for line in string.gmatch(content, "[^\n]+") do
	table.insert(numbers, tonumber(line))
end
print("n", #numbers)

local function mix (n, s)
	return n ~ s
end

local function prune (n)
	return n % 16777216
end

local function marketseq (s)
	s = prune(mix(s * 64, s))
	s = prune(mix(s // 32, s))
	s = prune(mix(s * 2048, s))
	return s
end

local function marketsim (n)
	for _ = 1, 2000 do
		n = marketseq(n)
	end
	return n
end

local function marketsum ()
	local sum = 0
	for _, n in ipairs(numbers) do
		sum = sum + marketsim(n)
	end
	return sum
end

print(marketsum())

local function price (s)
	return s % 10
end

local function char (c)
	return string.char(65 + (c + 9))
end

local function pricehistory (s)
	local result = { }
	local p = price(s)
	for _ = 1, 2000 do
		s = marketseq(s)
		local pnext = price(s)
		table.insert(result, { price = pnext, change = pnext - p })
		p = pnext
	end
	local str = { }
	for _, obs in ipairs(result) do
		table.insert(str, char(obs.change))
	end
	result.str = table.concat(str)
	return result
end

local pricehistories = { }
for _, n in ipairs(numbers) do
	table.insert(pricehistories, pricehistory(n))
end

local function tradesim (seq)
	local str = { }
	for _, c in ipairs(seq) do
		table.insert(str, char(c))
	end
	str = table.concat(str)
	local sum = 0
	for _, h in ipairs(pricehistories) do
		local index = string.find(h.str, str)
		if index then
			sum = sum + h[index + 3].price
		end
	end
	return sum
end

local function backtest (lower, upper)
	local max = -math.huge
	for a = lower, upper do
		for b = lower, upper do
			for c = lower, upper do
				for d = lower, upper do
					max = math.max(max, tradesim({ a, b, c, d }))
				end
			end
		end
	end
	return max
end

for i = 1, 9 do
	print(i, backtest(-i, i))  -- central limit theorem: price changes are ~ N(0, some std)
end