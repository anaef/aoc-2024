local input = assert(io.open("input.txt"))
local content = input:read("*a")
input:close()

local nx, ny = 101, 103

local robots = { }
for line in string.gmatch(content, "[^\r\n]+") do
	local x, y, vx, vy = string.match(line, "^p=(%d+),(%d+) v=(%-?%d+),(%-?%d+)$")
	if x then
		table.insert(robots, {
			x = tonumber(x),
			y = tonumber(y),
			vx = tonumber(vx),
			vy = tonumber(vy)
		})
	end
end
print("n", #robots)

local epoch = 0
local found
repeat
	epoch = epoch + 1
	local grid = { }
	for _, robot in ipairs(robots) do
		robot.x = (robot.x + robot.vx) % nx
		robot.y = (robot.y + robot.vy) % ny
		if not grid[robot.y] then
			grid[robot.y] = { }
		end
		grid[robot.y][robot.x] = true
	end
	if epoch == 100 then
		local q1, q2, q3, q4 = 0, 0, 0, 0
		for _, robot in ipairs(robots) do
			if robot.x < (nx - 1) // 2 then
				if robot.y < (ny - 1) // 2 then
					q1 = q1 + 1
				elseif robot.y > (ny - 1) // 2 then
					q2 = q2 + 1
				end
			elseif robot.x > (nx - 1) // 2 then
				if robot.y < (ny - 1) // 2 then
					q3 = q3 + 1
				elseif robot.y > (ny - 1) // 2 then
					q4 = q4 + 1
				end
			end
		end
		print("factor", q1 * q2 * q3 * q4)
	end
	local numlong = 0
	for y = 1, ny do
		local length = 0
		local long
		for x = 1, nx do
			if grid[y] and grid[y][x] then
				if grid[y][x - 1] then
					length = length + 1
					if length >= 10 then
						long = true
					end
				else
					length = 1
				end
			else
				length = 0
			end
		end
		if long then
			numlong = numlong + 1
		end
	end
	if numlong >= 10 and not found then
		print("epoch", epoch)
		found = true
	end
until epoch >= 100 and (epoch >= nx * ny or found)