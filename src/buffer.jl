abstract type AbstractBuffer end

# Type: :Fixed, :Sliding, :Dropping
struct Buffer{Type, T}  <: AbstractBuffer
    capacity::Integer
    elements::LinkedList{T}
    Buffer{Type, T}(n::Integer) where {Type, T} = new{Type, T}(n, LinkedList{T}())
    Buffer{T}(n::Integer=0) where {T} = Buffer{:Fixed, T}(n)
end

Base.isempty(buf::Buffer) = isempty(buf.elements)
isfull(::Buffer) = false
isfull(buf::Buffer{:Fixed}) = buf.capacity == length(buf.elements)
