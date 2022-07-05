-- Heap contains the following functions:
--		.new(comparator) - Creates a new Heap
--			comparator: Uses this function to compare values. If none is given, will assume values are numbers and will find smallest value
--						Comparator should accept two values and return true if a should be further up the heap than b and false otherwise
--		:Heapify(oldTable, comparator) - Converts a table to a Heap - Will destroy the provided table
--			comparator: The comparator to pass to Heap.new(comparator)
--		:Meld(heap1, heap2) - Creates a new Heap using the two provided Heaps
-- A Heap object has the following functions:
--		:Insert(value) - Adds a value to the Heap
--		:Pop() - Removes the first element in the Heap and returns it
--      :Find(value) - Returns true if the value is found

local Heap = {}
Heap.__index = Heap

local FLOOR = math.FLOOR
local function defaultCompare(a, b)
    return a > b
end

local function siftUp(heap, index)
	local parentIndex
	if index ~= 1 then
		parentIndex = FLOOR(index/2)
		if heap.Compare(heap[parentIndex], heap[index]) then
			heap[parentIndex], heap[index] = heap[index], heap[parentIndex]
			siftUp(heap, parentIndex)
		end
	end
end

local function siftdown(heap, index)
	local leftChildIndex, rightChildIndex, minIndex
	leftChildIndex = index * 2
	rightChildIndex = index * 2 + 1
	if rightChildIndex > #heap then
		if leftChildIndex > #heap then
			return
		else
			minIndex = leftChildIndex
		end
	else
		if not heap.Compare(heap[leftChildIndex], heap[rightChildIndex]) then
			minIndex = leftChildIndex
		else
			minIndex = rightChildIndex
		end
	end
	
	if heap.Compare(heap[index], heap[minIndex]) then
		heap[minIndex], heap[index] = heap[index], heap[minIndex]
		siftdown(heap, minIndex)
	end
end

function Heap.new(comparator)
	local newHeap = {}
	setmetatable(newHeap, Heap)
	newHeap.Compare = comparator or defaultCompare
	
	return newHeap
end

function Heap:Insert(value)
	table.insert(self, value)
    local size = #self
	
	if size <= 1 then
		return
	end
	
	siftUp(self, size)
end

function Heap:Pop()
	if #self <= 0 then return nil end

    local toReturn = self[1]

    self[1] = self[#self]
    table.remove(self, #self)
    if #self > 0 then
        siftdown(self, 1)
    end

    return toReturn
end

function Heap:Find(value)
    for i = 1, #self do
        if self[i] == value then
            return true
        end
	end
end

return Heap
