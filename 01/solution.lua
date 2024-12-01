local input = assert(io.open("input.txt"))
local lines = input:read("*a")
input:close()

local list1, list2 = { }, { }
for id1, id2 in string.gmatch(lines, "(%d+)%s+(%d+)") do
	table.insert(list1, tonumber(id1))
	table.insert(list2, tonumber(id2))
end
print("n", #list1, #list2)

table.sort(list1)
table.sort(list2)

local dSum = 0
for i, id1 in ipairs(list1) do
	dSum = dSum + math.abs(id1 - list2[i])
end
print(dSum)

local aggregate2 = { }
for _, id2 in ipairs(list2) do
	aggregate2[id2] = (aggregate2[id2] or 0) + 1
end

local sSum = 0
for _, id1 in ipairs(list1) do
	sSum = sSum + id1 * (aggregate2[id1] or 0)
end
print(sSum)
