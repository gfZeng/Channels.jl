abstract type AbstractList{T} end

mutable struct Node{T}
      e::T
      prev::Union{Node{T}, Nothing}
      next::Union{Node{T}, Nothing}
      Node(e::T) where T = new{T}(e, nothing, nothing)
      Node{T}(e::T) where T = new{T}(e, nothing, nothing)
end

mutable struct LinkedList{T} <: AbstractList{T}
      size::Integer
      head::Union{Node{T}, Nothing}
      tail::Union{Node{T}, Nothing}
      LinkedList{T}() where T = new{T}(0, nothing, nothing)
      function LinkedList(es::T...) where T
            lst = new{T}(0, nothing, nothing)
            for e in es
                  push!(lst, e)
            end
            return lst
      end
end

isempty(lst::AbstractList) = iszero(length(lst))
first(lst::AbstractList) = lst[1]
last(lst::AbstractList) = lst[end]

length(lst::LinkedList) = lst.size
iterate(lst::LinkedList) = (lst.head, 1)

iterate(lst::LinkedList, state = lst.head) = isnothing(state) ? nothing : (state.e, state.next)
iterate(r::Iterators.Reverse{LinkedList{T}}, state = r.itr.tail) where T = isnothing(state) ? nothing : (state.e, state.prev)

lastindex(lst::LinkedList) = lst.size

function getindex(lst::LinkedList, i::Integer)
      i > lst.size && throw(BoundsError(lst, i))
      itr = lst
      if i * 2 > lst.size
            i = lst.size - i + 1
            itr = Iterators.reverse(lst)
      end
      for e in itr
            i -= 1
            iszero(i) && return e
      end
end

function getnode(lst::LinkedList, i::Integer)
      i > lst.size && throw(BoundsError(lst, i))
      if i * 2 > lst.size
            node, i = lst.tail, lst.size - i
            while i > 0
                  node = node.prev
                  i -= 1
            end
            return node
      end
      node, i = lst.head, i - 1
      while i > 0
            node = node.next
            i -= 1
      end
      return node
end

function setindex!(lst::LinkedList{T}, e::T, i::Integer) where T
      node = getnode(lst, i)

      @show node.e
      new = Node{T}(e)
      new.next = node.next
      new.prev = node.prev
      isnothing(node.prev) ? lst.head = new : node.prev.next = new
      isnothing(node.next) ? lst.tail = new : node.next.prev = new
      return lst
end

function push!(lst::LinkedList{T}, e::T) where T
      n = Node{T}(e)
      n.prev = lst.tail

      isempty(lst) ? lst.head = n : lst.tail.next = n

      lst.tail = n
      lst.size += 1
      return lst
end

function pushfirst!(lst::LinkedList{T}, e::T) where T
      n = Node{T}(e)
      n.next = lst.head
      isempty(lst) ? lst.tail = n : lst.head.prev = n
      lst.head = n
      lst.size += 1
      return lst
end

function pop!(lst::LinkedList)
      tail = lst.tail
      lst.tail = tail.prev
      lst.size -= 1
      return tail.e
end

function popfirst!(lst::LinkedList)
      head = lst.head
      lst.head = head.next
      lst.size -= 1
      return head.e
end

function Base.show(io::IO, lst::AbstractList{T}) where T
      println(io, "$(lst.size)-element List{$T}:")
      if (lst.size < 10)
            for e in lst
                  println(io, " $e")
            end
            return
      end

      for i in 1:5
            i > lst.size && return
            println(io, " $(lst[i])")
      end
      println(io, " ⋮")
      for i in 3:-1:0
            println(io, " $(lst[end-i])")
      end
end
