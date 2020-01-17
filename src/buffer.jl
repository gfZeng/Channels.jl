abstract type AbstractBuffer{T} end

# Type: :Fixed, :Sliding, :Dropping
struct Buffer{Type, T}  <: AbstractBuffer{T}
    capacity::Integer
    elements::LinkedList{T}
    Buffer{Type, T}(n::Integer) where {Type, T} = new{Type, T}(n, LinkedList{T}())
    Buffer{T}(n::Integer) where {T} = Buffer{:Fixed, T}(n)
end

Base.isempty(buf::Buffer) = isempty(buf.elements)
isfull(::Buffer) = false
isfull(buf::Buffer{:Fixed}) = buf.capacity == length(buf.elements)

function del!(buf::Buffer)
    isempty(buf.elements) && throw(BoundsError())
    return popfirst!(buf.elements)
end

function add!(buf::Buffer{:Fixed}, e)
    length(buf.elements) == buf.capacity && throw(BoundsError())
    push!(buf.elements, e)
    return buf
end

function add!(buf::Buffer{:Dropping}, e)
    length(buf.elements) == buf.capacity && return buf
    push!(buf.elements, e)
    return buf
end

function add!(buf::Buffer{:Sliding}, e)
    length(buf.elements) == buf.capacity && popfirst!(buf.elements)
    push!(buf.elements, e)
    return buf
end
