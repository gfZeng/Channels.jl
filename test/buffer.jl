@testset "buffer" begin
    buf = Buffer{Any}(0)
    @test buf isa Buffer{:Fixed, Any}
    @test Channels.isfull(buf)
    @test Channels.isempty(buf)

    buf = Buffer{Int64}(3)
    @test buf isa Buffer{:Fixed, Int64}
    @test !Channels.isfull(buf)
    @test Channels.isempty(buf)

    add! = Channels.add!
    del! = Channels.del!

    add!(buf, 3)
    @test 3 == del!(buf)
    try
        for i = 1:10
            add!(buf, i)
        end
    catch e
        @test e isa BoundsError
    end
    @test 1 == del!(buf)
    @test 2 == del!(buf)
    @test 3 == del!(buf)
    @test isempty(buf)
    @test missing === del!(buf)

    buf = Buffer{:Sliding, Int64}(3)
    for i = 1:10
        add!(buf, i)
    end
    @test 8 == del!(buf)
    @test 9 == del!(buf)
    @test 10 == del!(buf)
    @test isempty(buf)
    @test missing === del!(buf)

    buf = Buffer{:Dropping, Int64}(1)
    for i = 1:10
        add!(buf, i)
    end
    @test 1 == del!(buf)
    @test missing === del!(buf)
end
