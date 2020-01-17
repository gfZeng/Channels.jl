using Test
using Channels

AbstractList = Channels.AbstractList
LinkedList = Channels.LinkedList
@testset "Channels" begin
    include("list.jl")
    include("buffer.jl")
    include("channel.jl")
end
