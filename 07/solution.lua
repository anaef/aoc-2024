local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local equations = { }
for line in string.gmatch(content, "[^\n\r]+") do
	local index = string.find(line, ":")
	if not index then
		goto continue
	end
	local test = tonumber(string.sub(line, 1, index - 1))
	local terms = { }
	for term in string.gmatch(string.sub(line, index + 1), "%d+") do
		table.insert(terms, tonumber(term))
	end
	table.insert(equations, {
		test = test,
		terms = terms
	})
	::continue::
end

local reducers = {
	function (acc, term) return acc + term end,
	function (acc, term) return acc * term end,
}

local function reduce (acc, equation, index)
	local term = equation.terms[index]
	for _, reducer in ipairs(reducers) do
		local result = reducer(acc, term)
		if index < #equation.terms then
			if reduce(result, equation, index + 1) then
				return true
			end
		elseif result == equation.test then
			return true
		end
	end
	return false
end

local result = 0
for _, equation in ipairs(equations) do
	result = result + (reduce(equation.terms[1], equation, 2) and equation.test or 0)
end
print(result)

table.insert(reducers, function (acc, term) return tonumber(tostring(acc) .. tostring(term)) end)

local result2 = 0
for _, equation in ipairs(equations) do
	result2 = result2 + (reduce(equation.terms[1], equation, 2) and equation.test or 0)
end
print(result2)