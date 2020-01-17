function testchannel(Channel)
    @testset "channel" begin
        chnl = Channel{Any}()
        @test chnl isa Channel

        @async push!(chnl, 3)
        @test 3 == take!(chnl)

        @async take!(chnl)
        @test 42 == push!(chnl, 42)

        @async push!(chnl, 3)
        @async push!(chnl, 4)
        @async push!(chnl, 5)
        @test 3 == take!(chnl)
        @test 4 == take!(chnl)
        @test 5 == take!(chnl)

        @async for i = 1:10
            push!(chnl, i)
        end

        for i = 1:10
            @test i == take!(chnl)
        end

        @async push!(chnl, 3)
        @async push!(chnl, 4)
        @async take!(chnl)
        @test 3 == take!(chnl)


        chnl = Channel{Any}(9)
        @async for i = 1:100
            push!(chnl, i)
        end

        for i = 1:100
            @test i == take!(chnl)
        end
    end
end
testchannel(Base.Channel)
testchannel(Channels.Channel)
