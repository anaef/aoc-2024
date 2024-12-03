local input = assert(io.open("input.txt"))
local program = input:read("*a")
input:close()

local mulpattern = "mul%((%d%d?%d?),(%d%d?%d?)%)"
local sum = 0
for a, b in string.gmatch(program, mulpattern) do
	sum = sum + tonumber(a) * tonumber(b)
end
print(sum)

local switches = { { index = 1, op = "do" } }
local function scan (pattern, op)
	local index = string.find(program, pattern)
	while index do
		table.insert(switches, { index = index, op = op })
		index = string.find(program, pattern, index + 1)
	end
end
scan("do%(%)", "do")
scan("don't%(%)", "don't")
table.sort(switches, function (a, b) return a.index < b.index end)

local sumactive = 0
local switchindex = 1
local mulindex, _, a, b = string.find(program, mulpattern)
while mulindex do
	while switches[switchindex + 1] and switches[switchindex + 1].index < mulindex do
		switchindex = switchindex + 1
	end
	if switches[switchindex].op == "do" then
		sumactive = sumactive + tonumber(a) * tonumber(b)
	end
	mulindex, _, a, b = string.find(program, mulpattern, mulindex + 1)
end
print(sumactive)
