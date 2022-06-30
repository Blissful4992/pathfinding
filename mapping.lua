local mapping = {}

-- Globals --
local RAY_PRECISION = 1.0e-4;

-- Cached Functions --

local V3 = Vector3.new;
local ROUND, MIN = math.round, math.min; 
local TINSERT = table.insert;

-- Utility Functions --

local function snap(a, b)
    return ROUND(a/b)*b;
end
-- Snaps a point to a virtual game grid (simple function used by a various of 3d building games e.g, bloxburg)
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
local function addNode(map, v)
    map[v.X] = map[v.X] or {}
    map[v.X][v.Y] = map[v.X][v.Y] or {}
    map[v.X][v.Y][v.Z] = map[v.X][v.Y][v.Z] or v
    return v
end

-- Mapping Functions --

--[[
    recursiveRay() will find all intersect points of all parts between points 'from' and 'to'
]]
function mapping:recursiveRay(from, to, results, raycast_params, c, reverse)
    c = c + 1
    if c > 100 then return end
    
    local result = workspace:Raycast(from, to-from, raycast_params)
    
    if (result) then
        local intersect = result.Position

        if (reverse) then self:recursiveRay(intersect + getUnit(intersect, to)*RAY_PRECISION, to, results, raycast_params, c, reverse) end

        if (not hasProperty(result.Instance, "CanCollide") or result.Instance.CanCollide == true) then
            TINSERT(results, intersect)
        end

        if (not reverse) then self:recursiveRay(intersect + getUnit(intersect, to)*RAY_PRECISION, to, results, raycast_params, c, reverse) end
    end
end

--[[
    Key relation between top and bottom of parts:
        if part.top is top_intersects[i] ...
        then part.bottom is bottom_intersects[i]
    Therefore the key relation between top and bottom of open spaces between these parts:
        if space.top is top_intersects[i] ...
        then space.bottom is bottom_intersects[i-1] (if both lists are ordered by descending Y position)
]]
function mapping:getValidIntersects(top_intersects, bottom_intersects, intersect_count, agent_height)
    local valid = {}

    for i = 1, intersect_count do
        local top = top_intersects[i]
        local bottom = bottom_intersects[i-1]

        local size = bottom.y-top.y
        if size < agent_height then continue end -- Space is either size 0, negative, or too small to be inside of

        TINSERT(valid, top)
    end

    return valid
end

--[[
    A Traversable spot is a open spot for the player to traverse between either:
        - the bottom of 1 object and the top of 1 object below it ...
        - the top of the world and the top of 1 object below it
]]
function mapping:getTraversableSpots(pos, agent_height, raycast_params)
    local from = V3(pos.x, 1000, pos.z)
    local to = V3(pos.x, -1000, pos.z)

    local top_intersects = {}
    self:recursiveRay(from, to, top_intersects, raycast_params, 0, false)

    local bottom_intersects = {}
    self:recursiveRay(to, from, bottom_intersects, raycast_params, 0, true) -- Reverse is true because we want it ordered by descending Y position

    local top_count = #top_intersects
    local bottom_count = #bottom_intersects

    if top_count == 0 then return {} end
    if top_count ~= bottom_count then top_count = MIN(top_count, bottom_count) end

    bottom_intersects[0] = from

    return self:getValidIntersects(top_intersects, bottom_intersects, top_count, agent_height)
end

function mapping:createMap(p1, p2, separation, agent_height, raycast_params)
    local map = {}

    raycast_params = raycast_params or RaycastParams.new()

    local diffx, diffz = p2.x-p1.x, p2.z-p1.z;
    local dx, dz = diffx < 0 and -1 or 1, diffz < 0 and -1 or 1;

    for x = 0, diffx, separation do
        for z = 0, diffz, separation do
            local new_x, new_z = p1.x+x*dx, p1.z+z*dz
            local snapped = snapToGrid(V3(new_x, 0, new_z), separation)

            for _, v in next, self:getTraversableSpots(snapped, agent_height, raycast_params) do
                addNode(map, snapToGrid(v, separation))
            end
        end
    end

    return map
end

return mapping
