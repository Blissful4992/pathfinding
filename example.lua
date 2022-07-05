-- Libraries
local pathfinding = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/pathfinding/main/pathfinding.lua"))()
local mapping = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/pathfinding/main/mapping.lua"))()

-- Cached
local V3, CF = Vector3.new, CFrame.new;
local ROUND, HUGE = math.round, math.huge; 
local TINSERT, TFIND, TREMOVE, TSORT = table.insert, table.find, table.remove, table.sort;

-- Visualization Setup
local Lines_Folder = workspace:FindFirstChild("_Lines") or nil;
local World_Points = workspace:FindFirstChild("_Points") or nil;

local function createPart(name, pos, color, size, h)
    local p = Instance.new("Part", World_Points)
    
    p.Name = name
    p.CanCollide = false
    p.Anchored = true
    p.Color = color
    p.Position = pos
    p.Size = size

    if (h) then
        h = Instance.new("Highlight", p)
        
        h.Adornee = p
        h.FillColor = color
    end

    return p
end

if (not Lines_Folder) then
    Lines_Folder = Instance.new("Folder", workspace)
    Lines_Folder.Name = "_Lines"
end
if (not World_Points) then
    World_Points = Instance.new("Folder", workspace)
    World_Points.Name = "_Points"
end

local function removeLines()
    if not Lines_Folder then return end

    local LinesTABLE = Lines_Folder:GetChildren()
    for i = 1, #LinesTABLE do
        LinesTABLE[i]:Destroy()
    end
end

local function removePoints()
    if not World_Points then return end

    local PointsTABLE = World_Points:GetChildren()
    for i = 1, #PointsTABLE do
        PointsTABLE[i]:Destroy()
    end
end

removeLines()
removePoints()

local function newLine(info)
    local PointA = info.PointA or V3(0,0,0)
    local PointB = info.PointB or V3(0,0,0)

    local Line = Instance.new("Part")
    Line.TopSurface = Enum.SurfaceType.Smooth
    Line.Color = info.Color or Color3.fromRGB(0, 255, 0)
    Line.Anchored = true
    Line.CanCollide = false
    Line.Transparency = 0.4
    Line.Material = Enum.Material.Neon
    Line.Name = "Path"
    Line.Parent = Lines_Folder

    local magnitude = (PointA - PointB).magnitude
	Line.Size = V3(info.Thickness, info.Thickness, magnitude)
	Line.CFrame = CF(PointA:Lerp(PointB, 0.5), PointB)

    return Line
end

local Player = game.Players.LocalPlayer
local Separation = V3(1,1,1)

local Root = Player.Character.HumanoidRootPart.CFrame
local Start = (Root * CF(0, -2, 0)).p
local End = (Root * CF(0, -2, -90)).p

-- Visualize Initial Points
createPart("Start", Start, Color3.fromRGB(0,255,0), V3(0.5,0.5,0.5), false)
createPart("End", End, Color3.fromRGB(255,0,0), V3(0.5,0.5,0.5), false)

-- Params for map raycast
local Params = RaycastParams.new()
Params.FilterDescendantsInstances = {Player.Character}
Params.FilterType = Enum.RaycastFilterType.Blacklist

-- Compute Map
local MAP = mapping:createMap(Root.p+V3(-100, 0, -100), Root.p+V3(100, 0, 100), Separation, 5, Params)

-- Visualize Map
for x,_x in pairs(MAP) do
    for y,_y in pairs(_x) do
        for z,_z in pairs(_y) do
            createPart("Node", V3(x,y,z), Color3.fromRGB(0,255,0), V3(0.2,0.2,0.2), false)
        end
    end
end

-- Compute Path
local Path = pathfinding:getPath(MAP, Start, End, Separation, true)

-- Visualize Path
local previous = Path[1];
for _,node in next, Path do
    newLine({
        PointA = previous;
        PointB = node;
        Thickness = 0.15; 
        Color = Color3.fromRGB(255, 0, 255);
    })

    previous = node
end

-- Loop through them and make the player walk to each point like this:
-- for _,p in next, Path do
--     Player.Character.Humanoid:MoveTo(p.Position)
--     Player.Character.Humanoid.MoveToFinished:Wait() -- This yields until the player has reached 'p.Position'
-- end
