module Channels
import Base: isempty, length, first, last,
             lock, unlock, trylock, islocked,
             getindex, setindex!, iterate, lastindex,
             push!, pushfirst!, popfirst!, pop!, put!, take!


include("list.jl")
include("buffer.jl")
include("channel.jl")
end
