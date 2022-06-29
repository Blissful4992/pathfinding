local mapping = {}
local RAY_PRECISION = 1.0e-5;

--
local NEW = Instance.new;
local V3, CF = Vector3.new, CFrame.new;
local ROUND, HUGE = math.round, math.huge; 
local TINSERT, TFIND, TREMOVE, TSORT = table.insert, table.find, table.remove, table.sort;
local RGB = Color3.fromRGB;
--

local function snap(a, b)
    return ROUND(a/b)*b;
end
local function snapToGrid(v, separation)
    return V3(
        snap(v.X, separation),
        snap(v.Y, separation),
        snap(v.Z, separation)
    )
end
local function getUnit(a, b)
    return (b-a).unit;
end
local function hasProperty(object, property)
    local success, value = pcall(function()
        return object[property]
    end)
    return success and value ~= object:FindFirstChild(property)
end

--

function mapping:recursiveRay(from, to, results, params, c)
    c = c + 1
    if c > 100 then return end
    
    local result = workspace:Raycast(from, to-from, params)
    
    if (result) then
        local intersect = result.Position
        if (not hasProperty(result.Instance, "CanCollide") or result.Instance.CanCollide == true) then
            TINSERT(results, intersect)
        end

        self:recursiveRay(intersect + getUnit(intersect, to)*RAY_PRECISION, to, results, params, c)
    end
end

--[[
    Key relation between top and bottom of parts:
        if part.top is topIntersects[i] ...
        then part.bottom is bottomIntersects[i]
    Therefore the key relation between top and bottom of open spaces between these parts:
        if space.top is topIntersects[i] ...
        then space.bottom is bottomIntersects[i-1] (if both lists are ordered by descending Y position)
]]
function mapping:getValidIntersects(topIntersects, bottomIntersects, intersectCount, agentHeight)
    local minHeight = agentHeight

    local valid = {}

    for i = 1, intersectCount do

        local top = topIntersects[i]
        local bottom = bottomIntersects[intersectCount-i+2]

        local size = bottom.y-top.y
        if size < minHeight then continue end -- Space is either size 0 or too small to be inside of

        TINSERT(valid, top)
    end

    return valid
end

function mapping:getTraversableSpots(pos, params, agentHeight)
    local from = V3(pos.x, 10000, pos.z)
    local to = V3(pos.x, -10000, pos.z)

    local topIntersects = {}
    self:recursiveRay(from, to, topIntersects, params, 0)

    local bottomIntersects = {}
    self:recursiveRay(to, from, bottomIntersects, params, 0)

    local intersectCount = #topIntersects -- Either one

    if intersectCount == 0 or intersectCount ~= #bottomIntersects then return {} end

    TINSERT(bottomIntersects, from)

    return self:getValidIntersects(topIntersects, bottomIntersects, intersectCount, agentHeight)
end

function mapping:addNode(map, v)
    map[v.X] = map[v.X] or {}
    map[v.X][v.Y] = map[v.X][v.Y] or {}
    map[v.X][v.Y][v.Z] = map[v.X][v.Y][v.Z] or v
    return v
end

function mapping:createMap(p1, p2, separation, agentHeight)
    local map = {}

    local diffx, diffz = p2.x-p1.x, p2.z-p1.z;
    local dx, dz = diffx < 0 and -1 or 1, diffz < 0 and -1 or 1;

    for x = 0, diffx, separation do
        for z = 0, diffx, separation do
            local p = snapToGrid(V3(p1.x+x*dx, p1.y, p1.z+z*dz), separation)

            for _, v in next, self:getTraversableSpots(p, agentHeight) do
                self:addNode(map, snapToGrid(v, separation))
            end
        end
    end

    return map
end

return mapping
