local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local rega, regb, regc, list = string.match(content, "(%d+)[^%d]+(%d+)[^%d]+(%d+)[^%d]+([%d,]+)")
rega, regb, regc = tonumber(rega), tonumber(regb), tonumber(regc)
local program = { }
for code in string.gmatch(list, "%d") do
	table.insert(program, tonumber(code))
end

local function run (inita, initb, initc)
	local a = inita
	local b = initb
	local c = initc
	local ip = 1
	local output = { }
	local function combo (operand)
		if operand <= 3 then
			return operand
		elseif operand == 4 then
			return a
		elseif operand == 5 then
			return b
		elseif operand == 6 then
			return c
		else
			assert(false, "bad combo")
		end
	end
	while ip < #program do
		local opcode = program[ip]
		local operand = program[ip + 1]
		if opcode == 0 then
			a = a >> combo(operand)
		elseif opcode == 1 then
			b = b ~ operand
		elseif opcode == 2 then
			b = combo(operand) % 8
		elseif opcode == 3 then
			if a ~= 0 then
				ip = operand + 1
				goto continue
			end
		elseif opcode == 4 then
			b = b ~ c
		elseif opcode == 5 then
			table.insert(output, combo(operand) % 8)
		elseif opcode == 6 then
			b = a >> combo(operand)
		elseif opcode == 7 then
			c = a >> combo(operand)
		else
			assert(false, "bad opcode")
		end
		ip = ip + 2
		::continue::
	end
	return output
end

print(table.concat(run(rega, regb, regc), ","))

local function search (base, suffix)
	for i = 0, 7 do
		local a = base * 8 + i
		local output = run(a, regb, regc)
		for j = 2, suffix do
			assert(output[j] == program[#program - suffix + j])  -- fundamental invariant
		end
		if output[1] == program[#program - suffix + 1] then
			if suffix == #program then
				return a
			else
				local result = search(a, suffix + 1)
				if result then
					return result
				end
			end
		end
	end
	return nil
end

print(search(0, 1))