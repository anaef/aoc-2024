local linear = require("linear")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local machines, machine = { }, nil
for line in string.gmatch(content, "[^\r\n]+") do
	local button, x, y = string.match(line, "^Button (%u): X%+(%d+), Y%+(%d+)$")
	if button then
		if not machine then
			machine = { }
		end
		machine[button] = {
			x = tonumber(x),
			y = tonumber(y)
		}
	end
	x, y = string.match(line, "^Prize: X=(%d+), Y=(%d+)$")
	if x then
		machine.prize = {
			x = tonumber(x),
			y = tonumber(y)
		}
		table.insert(machines, machine)
		machine = nil
	end
end
print("n", #machines)

local function probableinteger (n)
	local res = n % 1
	return math.min(res, 1 - res) < 1e-3
end

local function solve ()
	local cost = 0
	local A = linear.matrix(2, 2)
	local B = linear.matrix(2, 1)
	local x, y = A[1], A[2]
	local b = linear.tvector(B, 1)
	for _, _machine in ipairs(machines) do
		x[1], x[2] = _machine.A.x, _machine.B.x
		y[1], y[2] = _machine.A.y, _machine.B.y
		b[1], b[2] = _machine.prize.x, _machine.prize.y
		if linear.gesv(A, B) then
			local na, nb = b[1], b[2]
			if probableinteger(na) and probableinteger(nb) then
				cost = cost + math.floor(na + 0.5) * 3 + math.floor(nb + 0.5)
			end
		else
			-- Note: this ignores cases where matrix A does not have full rank, i.e., is singular.
		end
	end
	return cost
end

print(solve())

for _, _machine in ipairs(machines) do
	_machine.prize.x = _machine.prize.x + 10000000000000
	_machine.prize.y = _machine.prize.y + 10000000000000
end

print(solve())