
abstract type AbstractBuffer{T} end
@enum BufferType Fixed Dropping Sliding

struct Buffer{C, T} <: AbstractBuffer{T}
      sz::Integer
      xs::LinkedList{T}
      Buffer{T}(sz::Integer) where T = new{Fixed, T}(sz, LinkedList{T}())
      Buffer{C, T}(sz::Integer) where {C, T} = new{C, T}(sz, LinkedList{T}())
end

isfull(buf::Buffer{C}) where C = C == Fixed && buf.xs.size == buf.sz
isempty(buf::Buffer) = isempty(buf.xs)
push!(buf::Buffer{Fixed, T},    x::T) where T = push!(buf.xs, x)
push!(buf::Buffer{Dropping, T}, x::T) where T = buf.xs.size == buf.sz && push!(buf.xs, x)
push!(buf::Buffer{Sliding, T},  x::T) where T = begin
      buf.xs.size == buf.sz && popfirst!(buf.xs)
      push!(buf.xs, x)
end
pop!(buf::Buffer) = popfirst!(buf.xs)


mutable struct PromiseBuffer{T} <: AbstractBuffer{T}
      x::Union{T, Nothing}
      PromiseBuffer{T}() where T = new(Promise)
end
isfull(::PromiseBuffer) = false
isempty(p::PromiseBuffer) = p.x === nothing
push!(p::PromiseBuffer{T}, x::T) where T = p.x === nothing && (p.x = t)
pop!(p::PromiseBuffer) = p.x

Base.show(io::IO, buf::AbstractBuffer) = print(io, " $(typeof(buf))($(buf.sz))")
