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
	--[[
		# 'heap' is a heap at all indices >= startpos, except possibly for pos.  pos
		# is the index of a leaf with a possibly out-of-order value.  Restore the
		# heap invariant.
		def _siftdown(heap, startpos, pos):
		    newitem = heap[pos]
		    # Follow the path to the root, moving parents down until finding a place
		    # newitem fits.
		    while pos > startpos:
		        parentpos = (pos - 1) >> 1
		        parent = heap[parentpos]
		        if newitem < parent:
		            heap[pos] = parent
		            pos = parentpos
		            continue
		        break
		    heap[pos] = newitem
	]]
	
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

	--[[
		def heappush(heap, item):
		    """Push item onto heap, maintaining the heap invariant."""
		    heap.append(item)
		    _siftdown(heap, 0, len(heap)-1)		
	]]

	if heap.position[item] then error 'Duplicated item' 
	else
		local lst = heap.lst
		table.insert(lst, item)
		local len = heap.size + 1
		heap.size = len
		heap.position[item] = len
		siftdown(heap.lst, 1, len, heap.position, heap.key)
	end
end

local function siftup(heap, endpos, pos, position, key)
	--[[
		def _siftup(heap, pos):
		    endpos = len(heap)
		    startpos = pos
		    newitem = heap[pos]
		    # Bubble up the smaller child until hitting a leaf.
		    childpos = 2*pos + 1    # leftmost child position
		    while childpos < endpos:
		        # Set childpos to index of smaller child.
		        rightpos = childpos + 1
		        if rightpos < endpos and not heap[childpos] < heap[rightpos]:
		            childpos = rightpos
		        # Move the smaller child up.
		        heap[pos] = heap[childpos]
		        pos = childpos
		        childpos = 2*pos + 1
		    # The leaf at pos is empty now.  Put newitem there, and bubble it up
		    # to its final resting place (by sifting its parents down).
		    heap[pos] = newitem
		    _siftdown(heap, startpos, pos)
	]]
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

function heapq.pop(heap)

	--[[
		def heappop(heap):
		    """Pop the smallest item off the heap, maintaining the heap invariant."""
		    lastelt = heap.pop()    # raises appropriate IndexError if heap is empty
		    if heap:
		        returnitem = heap[0]
		        heap[0] = lastelt
		        _siftup(heap, 0)
		        return returnitem
		    return lastelt		
	]]
	
	local lst = heap.lst
	local lastelt = table.remove(lst)
	local size = heap.size - 1
	heap.size = size
	
	local position = heap.position
	
	if size > 0 then
		local returnitem = lst[1]
		
		lst[1] = lastelt
		position[returnitem] = nil
		position[lastelt] = 1
		
		siftup(lst, size, 1, position, heap.key)
		
		return returnitem
	else
		position[lastelt] = nil
		
		local k, i = next(position)
		assert (not k)
		
		return lastelt
	end
end

function heapq.heapify(heap)
	--[[
		def heapify(x):
		    """Transform list into a heap, in-place, in O(len(x)) time."""
		    n = len(x)
		    # Transform bottom-up.  The largest index there's any point to looking at
		    # is the largest with a child index in-range, so must have 2*i + 1 < n,
		    # or i < (n-1)/2.  If n is even = 2*j, this is (2*j-1)/2 = j-1/2 so
		    # j-1 is the largest, which is n//2 - 1.  If n is odd = 2*j+1, this is
		    # (2*j+1-1)/2 = j so j-1 is the largest, and that's again n//2-1.
		    for i in reversed(range(n//2)):
		        _siftup(x, i)
	]]
	
	local lst = heap.lst
	local size = heap.size
	local position = heap.position
	local key = heap.key
	
	for i = size >> 1, 1, -1 do
		siftup(lst, size, i, position, key)
	end
	
	return heap
end

function heapq.sort(heap)

	local sorted = {}
	
	while heap.size > 0 do table.insert(sorted, heap:pop()) end

	return sorted
end

--[[

function heapq.sort(heap)
	
	local n = #heap
	
	for i=-n, -1 do
		heap[i] = heapq.pop(heap)
	end

	table.move(heap, -n, -1, 1)
end

]]

return heapq -- finally return the module

