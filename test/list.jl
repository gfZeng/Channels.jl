function count(lst::AbstractList)
    n = 0
    for e in lst
        n += 1
    end
    return n
end

@testset "list" begin
    # Empty elements
    lst = LinkedList{Int64}()
    @test isempty(lst)
    push!(lst, 42)
    @test 42 == pop!(lst)
    pushfirst!(lst, 43)
    @test 43 == popfirst!(lst)

    lst = LinkedList(3)
    @test 3 == pop!(lst)

    lst = LinkedList(3)
    @test 3 == popfirst!(lst)

    # Add  elements
    lst = LinkedList(1, 2, 3)
    @test length(lst) == 3
    @test length(lst) == count(lst)
    @test 3 == last(lst) == lst[end]

    push!(lst, 9)
    @test length(lst) == count(lst)
    @test 9 == last(lst) == lst[end]

    pushfirst!(lst, 0)
    @test length(lst) == count(lst)
    @test 0 == first(lst) == lst[1]

    lst[end+1] = 100
    lst[0] = 0
    @test 0 == first(lst)
    @test 100 == last(lst)

    # Remove elements
    l = lst[end-1]
    pop!(lst)
    @test l == lst[end] == last(lst)

    f = lst[2]
    popfirst!(lst)
    @test f == lst[1] == first(lst)

    # Empty
    empty!(lst)
    @test 0 == length(lst) == count(lst)

    for i = 1:100
        push!(lst, i)
    end
    @test 100 == length(lst) == count(lst)

    @test 100 == lst[end] == lst[count(lst)]
end
