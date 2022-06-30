local pathfinding = {}

-- Cached Functions --

local V3 = Vector3.new;
local ROUND, HUGE = math.round, math.huge; 
local TINSERT, TFIND, TREMOVE, TSORT = table.insert, table.find, table.remove, table.sort;

-- Globals --

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
        snap(v.X, separation),
        snap(v.Y, separation),
        snap(v.Z, separation)
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

function pathfinding:getNeighbors(map, node, allow_diagonals, separation)
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
local function sortByScore(node1, node2) -- Comparison function for getting best f_score
    return f_score[node1] < f_score[node2];
end

-- main pathfinding function -> A-Star algorithm (https://en.wikipedia.org/wiki/A*_search_algorithm)
function pathfinding:aStar(map, start_node, end_node, allow_diagonals, separation)
    g_score, f_score = {}, {}
    previous_node, visited = {}, {}

    g_score[start_node] = 0
    f_score[start_node] = getMagnitude(start_node, end_node)

    local nodes, current = {start_node}

    while (#nodes > 0 and current ~= end_node) do
        current = nodes[1]
        TREMOVE(nodes, 1)
        visited[current] = true

        -- End Node is reached
        if (current == end_node) then break end
        
        -- Compute and manage neighbors
        local neighbors = self:getNeighbors(map, current, allow_diagonals, separation)
        for _, neighbor in next, neighbors do
            if visited[neighbor] then continue end

            local tentative_g = g_score[current] + getMagnitude(current, neighbor)
                    
            if tentative_g < (g_score[neighbor] or HUGE) then 
                previous_node[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + getMagnitude(neighbor, end_node)

                if not TFIND(nodes, neighbor) then
                    TINSERT(nodes, neighbor)
                end
            end
        end

        TSORT(nodes, sortByScore)
    end
end

-- Recursive path reconstruction (backtracking from previous_node's)
function pathfinding:reconstructPath(node, start_node, end_node, list)
    if (not previous_node[node]) then return end

    self:reconstructPath(previous_node[node], start_node, end_node, list)

    if (node ~= end_node) then
        TINSERT(list, node)
    end
end

-- Provide a map (3D Array of points with equal separation in 3 axis), a start and end point, the map point separation, and get a path (list of points) in return
function pathfinding:getPath(map, start_point, end_point, allow_diagonals, separation)
    local start_node = addNode(map, snapToGrid(start_point, separation))
    local end_node = addNode(map, snapToGrid(end_point, separation))

    if (not start_node or not end_node) then return {} end
    local path = {}

    self:aStar(map, start_node, end_node, allow_diagonals, separation)  -- Compute the path
    self:reconstructPath(end_node, start_node, end_node, path)          -- Reconstruct the path (Backtracking from previous_node)

    return path
end

return pathfinding
