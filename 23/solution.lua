package.path = package.path .. ";../?.lua;../?/init.lua"
local set = require("set")

local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local conns = { }
local sizes = { }

local function add (c1, c2)
	if not conns[c1] then
		conns[c1] = { }
		sizes[c1] = 0
	end
	conns[c1][c2] = true
	sizes[c1] = sizes[c1] + 1
end

for line in string.gmatch(content, "[^\n]+") do
	local c1, c2 = string.match(line, "^(%l%l)%-(%l%l)$")
	if c1 and c2 then
		add(c1, c2)
		add(c2, c1)
	end
end

local function isconnected (c1, c2)
	return conns[c1] and conns[c1][c2]
end

local function maybechief (c)
	return string.sub(c, 1, 1) == "t"
end

local set3 = set.empty(function (cs)
	table.sort(cs)
	return table.concat(cs)
end)

for c1 in pairs(conns) do
	for c2 in pairs(conns[c1]) do
		if sizes[c1] < sizes[c2] then
			for c3 in pairs(conns[c1]) do
				if isconnected(c3, c2) then
					if maybechief(c1) or maybechief(c2) or maybechief(c3) then
						set3:add({ c1, c2, c3 })
					end
				end
			end
		else
			for c3 in pairs(conns[c2]) do
				if isconnected(c3, c1) then
					if maybechief(c1) or maybechief(c2) or maybechief(c3) then
						set3:add({ c1, c2, c3 })
					end
				end
			end
		end
	end
end

print(set3:size())

local setmax, sizemax = set.empty(), 0
for c in pairs(conns) do
	local setc = set.one(c)
	for cc in pairs(conns[c]) do
		for cm in pairs(setc) do
			if not isconnected(cc, cm) then
				goto continue
			end
		end
		setc:add(cc)
		::continue::
	end
	local sizec = setc:size()
	if sizec > sizemax then
		setmax, sizemax = setc, sizec
	end
end

local password = { }
for c in pairs(setmax) do
	table.insert(password, c)
end
table.sort(password)
print(table.concat(password, ","))