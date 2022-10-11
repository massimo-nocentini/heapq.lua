--[[

Implementation of an heap, based on the Python implementation.
	
--]]

local operator = require 'operator'

local heapq = {}

local mt = { __index = heapq }

function isheapq(obj)
	return getmetatable(obj) == mt
end

function heapq.create (lst, key)
	
	local position = {}
	local key = key or operator.lt
	local size = 0

	for i, v in ipairs(lst) do 
		if position[v] then error 'Duplicated item.'
		else 
			position[v] = i 
			size = size + 1
		end
	end

	H = {lst = lst, position = position, key = key, size = size}
	setmetatable(H, mt)

	return H
end

local function siftdown(heap, startpos, pos, position, key)
	
	local newitem = heap[pos]
	
	-- Follow the path to the root, moving parents down until finding a place newitem fits.
	while pos > startpos do
		local parentpos = pos >> 1
		local parent = heap[parentpos]

		if key(newitem, parent) then
            heap[pos] = parent
			position[parent] = pos
            pos = parentpos
            goto continue
		end

		break
		
		::continue::
	end

	heap[pos] = newitem
	position[newitem] = pos
end


function heapq.push(heap, item)

	if heap.position[item] then error 'Duplicated item'
	else
		local lst = heap.lst
		table.insert(lst, item)
		local len = heap.size + 1
		heap.size = len
		heap.position[item] = len
		siftdown(heap.lst, 1, len, heap.position, heap.key)
	end

	return heap
end

local function siftup(heap, endpos, pos, position, key)
	
	local startpos, newitem, childpos = pos, heap[pos], pos << 1
	
	-- Bubble up the smaller child until hitting a leaf.
	while childpos <= endpos do
	
		-- Set childpos to index of smaller child.
		local rightpos = childpos + 1
		if rightpos <= endpos and 
			not key(heap[childpos], heap[rightpos]) then childpos = rightpos end
		
		-- Move the smaller child up.
		local v = heap[childpos]
        heap[pos] = v
		position[v] = pos
        pos = childpos
		childpos = pos << 1
	end
	
	-- The leaf at pos is empty now.  Put newitem there, and bubble it up
	-- to its final resting place (by sifting its parents down).
	heap[pos] = newitem
	position[newitem] = pos
	siftdown(heap, startpos, pos, position, key)
	
end

function heapq.invariant(heap)
	for i, v in ipairs(heap) do
		assert(heap.position[v] == i)
	end
end

function heapq.isempty (heap)

	return heap.size == 0
end

function heapq.pop(heap)

	assert (not heap:isempty ())

	local lst = heap.lst
	local lastelt = table.remove(lst)
	local size = heap.size - 1
	heap.size = size
	
	local position = heap.position
	
	if heap:isempty() then
		position[lastelt] = nil
		
		local k, i = next(position)
		assert (not k)
		
		return lastelt
	else
		local returnitem = lst[1]
		
		lst[1] = lastelt
		position[lastelt] = 1
		position[returnitem] = nil
		
		siftup(lst, size, 1, position, heap.key)
		
		return returnitem
	end
end

function heapq.heapify(heap)
	
	local lst = heap.lst
	local size = heap.size
	local position = heap.position
	local key = heap.key
	
	for i = size >> 1, 1, -1 do	siftup(lst, size, i, position, key)	end
	
	return heap
end

function heapq.replace (heap, item)

	assert (not heap:isempty ())

	local lst = heap.lst
	local key = heap.key

	if key (lst[1], item) then
	
		local returnitem = lst[1]
		lst[1] = item
		siftup (lst, heap.size, 1, heap.position, key)

		return returnitem
	else return item end
end

function heapq.update (heap, item)

	local position = heap.position
	local i = position[item]
	if i then
		local size = heap.size
		local key = heap.key
		local lst = heap.lst
		local p = i >> 1
		local cl = i << 1
		local cr = cl + 1
		if p > 0 and key (item, lst[p]) then siftup (lst, size, p, position, key)
		elseif (cl <= size and key (lst[cl], item)) then siftdown(lst, 1, cl, position, key)
		elseif (cr <= size and key (lst[cr], item)) then siftdown(lst, 1, cr, position, key)
		else end
	else error 'Item not in the heap.' end
end

function heapq.sort(heap)

	local sorted = {}
	
	while heap.size > 0 do table.insert(sorted, heap:pop()) end

	return sorted
end

return heapq -- finally return the module

