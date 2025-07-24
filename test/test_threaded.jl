using ThreadSafeDicts
using Test

function testThreadSafeDicts()
    dict = ThreadSafeDict()
    dict = ThreadSafeDict{String,Int64}()
    @test isempty(dict)
    dict["ten"] = 10
    dict["twenty"] = 20
    delete!(dict, "ten")
    @test pop!(dict) == ("twenty" => 20)
    @test isempty(dict)
    dict = ThreadSafeDict{String,Int64}(["a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1])

    @test dict["b"] == 1 && dict["e"] == 3
    Threads.@threads for k in collect(keys(dict))
        dict[k] *= 100
    end

    x = get!(dict, "another", 77)
    @test x == 77
    @test dict["e"] == 300
    @test get(dict, "e", nothing) == 300
    dict["extra"] = 0
    y = dict["extra"]
    @test y == 0
    @test haskey(dict, "a") == true

    empty!(dict)

    y = 77
    func() = isqrt(y)
    x = get!(func, dict, "another")
    @test x == 8
    
    empty!(dict)

    y = 77
    x = get(dict, "another") do
        isqrt(y)
    end
    @test x == 8
    @test !haskey(dict, "another")
    @test_throws KeyError dict["another"]
    
    empty!(dict)
    dict["sum"] = 0
    Threads.@threads for i in 1:1000
        dict[string(i)] = i
        lock(dict) do d
            d["sum"] += i
        end
    end
    res = merge(Dict(string(i)=>i for i in 1:1000), Dict("sum" => sum(1:1000)))
    @test dict == res
    empty!(dict)
    dict["sum"] = 0
    @sync for i in 1:1000
        Threads.@spawn begin
            dict[string(i)] = i
            lock(dict) do d
                d["sum"] += i
            end
        end
    end
    @test dict == res

    @test ((x, y) = iterate(dict)) !== nothing
    @test iterate(dict, y) !== nothing

    @test length(dict) == 1001
    empty!(dict)
    Threads.@threads for i in 1:1000
        sleep(rand() / 100)
        dict["number"] = i
    end
    @test dict["number"] >= 1000 / Threads.nthreads()
    println("testing printing: ", dict)
end

testThreadSafeDicts()
