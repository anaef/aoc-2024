local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local disk = { }
local isfile = true
local fileid = -1
local freelist = { }
local filelist = { }
for digit in string.gmatch(content, "%d") do
	digit = tonumber(digit)
	if isfile then
		fileid = fileid + 1
		table.insert(filelist, { off = #disk + 1, num = digit })
		for i = 1, digit do
			table.insert(disk, fileid)
		end
	else
		table.insert(freelist, { off = #disk + 1, num = digit })
		for i = 1, digit do
			table.insert(disk, -1)
		end
	end
	isfile = not isfile
end
local backup = { table.unpack(disk) }

local insert = 1
local remove = #disk
while remove > insert do
	if disk[remove] == -1 then
		remove = remove - 1
	elseif disk[insert] ~= -1 then
		insert = insert + 1
	else
		disk[insert], disk[remove] = disk[remove], -1
		insert, remove = insert + 1, remove - 1
	end
end

local function checksum ()
	local checksum = 0
	for i, id in ipairs(disk) do
		if id ~= -1 then
			checksum = checksum + (i - 1) * id
		end
	end
	return checksum
end
print(checksum())

disk = { table.unpack(backup) }
for i = #filelist, 1, -1 do
	local file = filelist[i]
	for j, free in ipairs(freelist) do
		if free.off >= file.off then
			break
		end
		if free.num >= file.num then
			for k = 0, file.num - 1 do
				disk[free.off + k], disk[file.off + k] = disk[file.off + k], -1
			end
			free.num, free.off = free.num - file.num, free.off + file.num
			if free.num == 0 then
				table.remove(freelist, j)
			end
			break
		end
	end
end
print(checksum())