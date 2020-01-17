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
      first::Union{Node{T}, Nothing}
      last::Union{Node{T}, Nothing}
      LinkedList{T}() where T = new{T}(0, nothing, nothing)
      function LinkedList(es::T...) where T
            lst = new{T}(0, nothing, nothing)
            for e in es
                  push!(lst, e)
            end
            return lst
      end
end

Base.isempty(lst::AbstractList) = iszero(length(lst))
Base.first(lst::AbstractList) = lst[1]
Base.last(lst::AbstractList) = lst[end]

Base.length(lst::LinkedList) = lst.size

Base.iterate(lst::LinkedList, state = lst.first) = isnothing(state) ? nothing : (state.e, state.next)
Base.iterate(r::Iterators.Reverse{LinkedList{T}}, state = r.itr.last) where T = isnothing(state) ? nothing : (state.e, state.prev)

Base.lastindex(lst::LinkedList) = lst.size

Base.empty(::LinkedList{T}) where T = LinkedList{T}()
Base.empty!(lst::LinkedList) = (lst.size = 0; lst.first = nothing; lst.last = nothing; lst)
Base.eltype(::Type{LinkedList{T}}) where T = T

function getnode(lst::LinkedList, i::Integer)
      (i <= 0 || i > lst.size) && throw(BoundsError(lst, i))
      if i * 2 > lst.size
            node, i = lst.last, lst.size - i
            while i > 0
                  node = node.prev
                  i -= 1
            end
            return node
      end
      node, i = lst.first, i - 1
      while i > 0
            node = node.next
            i -= 1
      end
      return node
end

Base.getindex(lst::LinkedList, i::Integer) = getnode(lst, i).e

function Base.setindex!(lst::LinkedList{T}, e::T, i::Integer) where T

      i == 0 && return pushfirst!(lst, e)
      i == lst.size + 1 && return push!(lst, e)

      node = getnode(lst, i)

      new = Node{T}(e)
      new.next = node.next
      new.prev = node.prev
      isnothing(node.prev) ? lst.first = new : node.prev.next = new
      isnothing(node.next) ? lst.last = new : node.next.prev = new
      return lst
end

function Base.push!(lst::LinkedList{T}, e::T) where T
      n = Node{T}(e)
      n.prev = lst.last

      isempty(lst) ? lst.first = n : lst.last.next = n

      lst.last = n
      lst.size += 1
      return lst
end

function Base.pushfirst!(lst::LinkedList{T}, e::T) where T
      n = Node{T}(e)
      n.next = lst.first
      isempty(lst) ? lst.last = n : lst.first.prev = n
      lst.first = n
      lst.size += 1
      return lst
end

function Base.pop!(lst::LinkedList)
      last = lst.last
      lst.last = last.prev
      lst.last === nothing || (lst.last.next = nothing)
      lst.size -= 1
      return last.e
end

function Base.popfirst!(lst::LinkedList)
      first = lst.first
      lst.first = first.next
      lst.first === nothing || (lst.first.prev = nothing)
      lst.size -= 1
      return first.e
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
