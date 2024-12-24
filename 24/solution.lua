package.path = package.path .. ";../?.lua;../?/init.lua"
local alg = require("alg")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local assignments, logic = string.match(content, "^(.+)\n\n(.+)$")

local inputs = { }
for line in string.gmatch(assignments, "[^\n]+") do
	local key, value = string.match(line, "^(%w+):%s+(%d)$")
	inputs[key] = tonumber(value)
end

local circuit, nodes = { }, { }
for line in string.gmatch(logic, "[^\n]+") do
	local op1, gate, op2, target = string.match(line, "^(%w+)%s(%w+)%s(%w+) %-> (%w+)$")
	local node =  {
		op1 = op1,
		op2 = op2,
		gate = gate,
		target = target,
		deps = { op1, op2 }
	}
	table.insert(circuit, node)
	nodes[target] = node
end

local function run ()
	if not alg.tsort(circuit, "target", "deps") then
		return nil
	end
	local values = { }
	for key, value in pairs(inputs) do
		values[key] = value
	end
	for _, node in ipairs(circuit) do
		local value
		if node.gate == "AND" then
			value = values[node.op1] & values[node.op2]
		elseif node.gate == "OR" then
			value = values[node.op1] | values[node.op2]
		elseif node.gate == "XOR" then
			value = values[node.op1] ~ values[node.op2]
		end
		values[node.target] = value
	end
	return values
end

local function regkey (prefix, index)
	return string.format("%s%.2d", prefix, index)
end

local function regvalue (prefix, values)
	local result = 0
	for i = 45, 0, -1 do
		result = (result << 1) | (values[regkey(prefix, i)] or 0)
	end
	return result
end

print(regvalue("z", run()))

--[[
A ripple carry adder operates as follows:
x00 AND y00 -> c00  -- initial carry

x01 XOR y01 -> t1   -- temp 1
c00 XOR t1  -> z01  -- result bit
x01 AND y01 -> t2   -- temp 2
c00 AND t1  -> t3   -- temp 3
t2  OR  t3  -> c01  -- next carry

The subsequent logic repairs intra-level swaps which is apparently sufficient.
]]

local function hasops (node, op1, op2)
	return node.op1 == op1 and node.op2 == op2 or node.op1 == op2 and node.op2 == op1
end

local function findops (op1, gate, op2)
	for _, node in ipairs(circuit) do
		if node.gate == gate and hasops(node, op1, op2) then
			return node
		end
	end
	return nil
end

local function findtarget (gate, target)
	for _, node in ipairs(circuit) do
		if node.gate == gate and node.target == target then
			return node
		end
	end
	return nil
end

local swaps = { }

local function swap (target1, target2)
	nodes[target1].target, nodes[target2].target = nodes[target2].target, nodes[target1].target
	nodes[target1], nodes[target2] = nodes[target2], nodes[target1]
	table.insert(swaps, target1)
	table.insert(swaps, target2)
end

-- Repair
local prevcarry = findops(regkey("x", 0), "AND", regkey("y", 0))
assert(prevcarry, 0)
for i = 1, 44 do
	local zkey = regkey("z", i)
	::redo::
	local temp1 = findops(regkey("x", i), "XOR", regkey("y", i))
	assert(temp1, i)
	local result = findops(prevcarry.target, "XOR", temp1.target)
	if not result then  -- temp1 is swapped with the non-carry operand of the result bit
		result = findtarget("XOR", zkey)
		assert(result, i)
		swap(temp1.target, result.op1 == prevcarry.target and result.op2 or result.op1)
		goto redo
	end
	local temp2 = findops(regkey("x", i), "AND", regkey("y", i))
	local temp3 = findops(prevcarry.target, "AND", temp1.target)
	local carry = temp2 and temp3 and findops(temp2.target, "OR", temp3.target)
	if result.target ~= zkey then
		if temp1.target == zkey then
			swap(temp1.target, result.target)
		elseif temp2 and temp2.target == zkey then
			swap(temp2.target, result.target)
		elseif temp3 and temp3.target == zkey then
			swap(temp3.target, result.target)
		elseif carry and carry.target == zkey then
			swap(carry.target, result.target)
		else
			assert(false, i)
		end
		goto redo
	end
	prevcarry = carry
end
assert(#swaps == 8)

-- Verify repaired adder
assert(regvalue("z", run()) == regvalue("x", inputs) + regvalue("y", inputs))

-- Output
table.sort(swaps)
print(table.concat(swaps, ","))