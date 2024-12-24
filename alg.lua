_ENV = setmetatable({ }, { __index = _ENV })

-- Performs a topological sort
function tsort (t, k, d)
	local values = { }
	local degrees = { }
	local blocklists = { }
	for _, value in ipairs(t) do
		local key = value[k]
		assert(values[key] == nil, "duplicate key")
		values[key] = value
		blocklists[key] = { }
	end
	local resolved = { }
	for key, value in pairs(values) do
		for _, dep in ipairs(value[d]) do
			local blocklist = blocklists[dep]
			if blocklist then
				table.insert(blocklist, key)
				degrees[key] = (degrees[key] or 0) + 1
			end
		end
		if not degrees[key] then
			table.insert(resolved, key)
		end
	end
	local index = 0
	while #resolved > 0 do
		local key = table.remove(resolved)
		local value = values[key]
		index = index + 1
		t[index] = value
		for _, dep in ipairs(blocklists[key]) do
			degrees[dep] = degrees[dep] - 1
			if degrees[dep] == 0 then
				table.insert(resolved, dep)
				degrees[dep] = nil
			end
		end
	end
	local cyclical
	for key in pairs(degrees) do
		cyclical = true
		index = index + 1
		t[index] = values[key]
	end
	return not cyclical
end

-- Uniform cost
local COST_UNIFORM = {
	insert = 1,
	delete = 1,
	substitute = 1
}

-- Calculates the edit distance
function editdistance (a, b, cost)
	cost = cost or COST_UNIFORM
	local m, n = string.len(a), string.len(b)
	local dp = { }
	for i = 0, m do
		dp[i] = { }
		for j = 0, n do
			if i == 0 then
				dp[i][j] = j * cost.insert
			elseif j == 0 then
				dp[i][j] = i * cost.delete
			else
				dp[i][j] = 0
			end
		end
	end
	for i = 1, m do
		for j = 1, n do
			if string.sub(a, i, i) == string.sub(b, j, j) then
				dp[i][j] = dp[i - 1][j - 1]
			else
				dp[i][j] = math.min(
					dp[i - 1][j - 1] + cost.substitute,
					dp[i][j - 1] + cost.insert,
					dp[i - 1][j] + cost.delete
				)
			end
		end
	end
	return dp[m][n]
end

-- Return module
return _ENV