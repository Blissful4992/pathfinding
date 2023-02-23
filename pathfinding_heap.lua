local pathfinding = {}
local heap = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/pathfinding/main/binary_heap.lua"))()

-- Cached Functions --
local V3 = Vector3.new;
local ROUND, HUGE = math.round, math.huge; 
local TINSERT, TFIND, TREMOVE, TSORT = table.insert, table.find, table.remove, table.sort;

-- List of midpoints of Faces (6), Edges (12), Vertices (8) of a cube in Euclidean Geometry ..
-- Diagonal Moves are moves where more than one axis presents a change in position
local MOVES, DIAGONAL_MOVES = {
    V3(-1,0,0),V3(0,-1,0),V3(0,0,-1),V3(0,0,1),V3(0,1,0),V3(1,0,0)
}, {
    V3(-1,-1,-1),V3(-1,-1,0),V3(-1,-1,1),V3(-1,0,-1),V3(-1,0,1),V3(-1,1,-1),V3(-1,1,0),V3(-1,1,1),V3(0,-1,-1),V3(0,-1,1),V3(0,1,-1),V3(0,1,1),V3(1,-1,-1),V3(1,-1,0),V3(1,-1,1),V3(1,0,-1),V3(1,0,1),V3(1,1,-1),V3(1,1,0),V3(1,1,1)
}

-- Utility Functions --

local function getMagnitude(a, b)
    return (b-a).magnitude;
end
local function snap(a, b)
    return ROUND(a/b)*b;
end
-- Snaps a point to a virtual game grid (simple function used by a various of 3d building games e.g, bloxburg)
local function snapToGrid(v, separation)
    return V3(
        snap(v.X, separation.X),
        snap(v.Y, separation.Y),
        snap(v.Z, separation.Z)
    )
end
local function vectorToMap(map, v)
    return (map[v.X] and map[v.X][v.Y] and map[v.X][v.Y][v.Z]) or false
end
local function addNode(map, v)
    map[v.X] = map[v.X] or {}
    map[v.X][v.Y] = map[v.X][v.Y] or {}
    map[v.X][v.Y][v.Z] = map[v.X][v.Y][v.Z] or v
    return v
end
-- Pathfinding Functions --

function pathfinding:getNeighbors(map, node, separation, allow_diagonals)
    local neighbors = {}

    for _,m in next, MOVES do
        TINSERT(neighbors, vectorToMap(map, node + m*separation) or nil)
    end
    if (allow_diagonals) then 
        for _,m in next, DIAGONAL_MOVES do
            TINSERT(neighbors, vectorToMap(map, node + m*separation) or nil)
        end
    end
    
    return neighbors;
end

local g_score, f_score, previous_node, visited;
local function comparator(a, b)
    return f_score[a] > f_score[b]
end

-- main pathfinding function -> A-Star algorithm (https://en.wikipedia.org/wiki/A*_search_algorithm)
function pathfinding:aStar(map, start_node, end_node, separation, allow_diagonals, time_limit)
    if (#(self:getNeighbors(map, start_node, separation, allow_diagonals)) == 0) then
        return false
    end
    if (#(self:getNeighbors(map, end_node, separation, allow_diagonals)) == 0) then
        return false
    end

    time_limit = time_limit or HUGE

    g_score, f_score = {}, {}
    previous_node, visited = {}, {}

    g_score[start_node] = 0
    f_score[start_node] = getMagnitude(start_node, end_node)

    local nodes, current = heap.new(comparator)
    nodes:Insert(start_node)

    local start = os.clock()
    while (#nodes > 0 and current ~= end_node) do
        local current, currentIndex = nodes:Pop()
        visited[current] = true

        -- End Node is reached
        if (current == end_node) then
            return true
        end

        -- Exceeded time frame
        if (os.clock()-start > time_limit) then
            return false
        end
        
        -- Compute and manage neighbors
        local neighbors = self:getNeighbors(map, current, separation, allow_diagonals)
        for _, neighbor in next, neighbors do
            if visited[neighbor] then continue end

            local tentative_g = g_score[current] + getMagnitude(current, neighbor)
                    
            if tentative_g < (g_score[neighbor] or HUGE) then 
                previous_node[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + getMagnitude(neighbor, end_node)

                if not nodes:Find(neighbor) then
                    nodes:Insert(neighbor)
                end
            end
        end
    end

    return true
end

-- Recursive path reconstruction (backtracking from previous_node's)
function pathfinding:reconstructPath(node, start_node, end_node, list)
    if (not previous_node[node]) then return end

    self:reconstructPath(previous_node[node], start_node, end_node, list)

    if (node ~= start_node and node ~= end_node) then -- only insert path nodes
        TINSERT(list, node)
    end
end

-- Provide a map (3D Array of points with constant separations in 3 axes), a start and end point, the map point separation, and get a path (list of points) in return
function pathfinding:getPath(map, start_point, end_point, separation, allow_diagonals)
    local start_node = addNode(map, snapToGrid(start_point, separation))
    local end_node = addNode(map, snapToGrid(end_point, separation))

    if (not start_node or not end_node) then
        return {}
    end

    -- Compute the path
    if (not self:aStar(map, start_node, end_node, separation, allow_diagonals)) then
        return {}
    end

    local path = {}
    -- Reconstruct the path (Backtracking from previous_node)
    self:reconstructPath(end_node, start_node, end_node, path)
    return path
end

return pathfinding
