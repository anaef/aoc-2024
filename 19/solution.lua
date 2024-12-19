package.path = package.path .. ";../?.lua;../?/init.lua"

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local tcontent, pcontent = string.match(content, "^(.+)\n\n(.+)$")

local towels = { }
for towel in string.gmatch(tcontent, "%l+") do
	table.insert(towels, towel)
end
local patterns = { }
for pattern in string.gmatch(pcontent, "%l+") do
	table.insert(patterns, pattern)
end
print("n", #towels, #patterns)

local function completions (pattern, index, cache)
	if index == string.len(pattern) + 1 then
		return 1
	end
	local suffix = string.sub(pattern, index)
	if cache[suffix] then
		return cache[suffix]
	end
	local count = 0
	for _, towel in ipairs(towels) do
		if string.sub(pattern, index, index + string.len(towel) - 1) == towel then
			count = count + completions(pattern, index + string.len(towel), cache)
		end
	end
	cache[suffix] = count
	return count
end

local feasibles, variants = 0, 0
local cache = { }
for _, pattern in ipairs(patterns) do
	local _completions = completions(pattern, 1, cache)
	feasibles = feasibles + (_completions > 0 and 1 or 0)
	variants = variants + _completions
end
print(feasibles, variants)