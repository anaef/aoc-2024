local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local rules = { }
local jobs = { }
for line in string.gmatch(content, "[^\n\r]+") do
	local before, after = string.match(line, "^(%d+)|(%d+)$")
	if before and after then
		before, after = tonumber(before), tonumber(after)
		if not rules[before] then
			rules[before] = { }
		end
		table.insert(rules[before], after)
	else
		local job = { }
		for page in string.gmatch(line, "%d+") do
			table.insert(job, tonumber(page))
		end
		if #job > 0 then
			assert(#job % 2 == 1)
			table.insert(jobs, job)
		end
	end
end
print("n", #jobs)

local sumcorrect = 0
for _, job in ipairs(jobs) do
	for i, page in ipairs(job) do
		if rules[page] then
			for _, after in ipairs(rules[page]) do
				for j = 1, i - 1 do
					if job[j] == after then
						goto continue
					end
				end
			end
		end
	end
	sumcorrect = sumcorrect + job[(#job + 1) / 2]
	::continue::
end
print(sumcorrect)

local sumfixed = 0
for _, job in ipairs(jobs) do
	local fixed
	::redo::
	for i, page in ipairs(job) do
		if rules[page] then
			for _, after in ipairs(rules[page]) do
				for j = 1, i - 1 do
					if job[j] == after then
						fixed = true
						job[j], job[i] = job[i], job[j]
						goto redo
					end
				end
			end
		end
	end
	if fixed then
		sumfixed = sumfixed + job[(#job + 1) / 2]
	end
end
print(sumfixed)
