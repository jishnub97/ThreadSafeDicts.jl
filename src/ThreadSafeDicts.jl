""" ThreadSafeDicts package source code """

module ThreadSafeDicts

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.haskey, Base.delete!, Base.print, Base.iterate, Base.length
export ThreadSafeDict

"""
    ThreadSafeDict(pairs::Vector{Pair{K,V}})

Return a `ThreadSafeDict`, which wraps a `Dict` along with a lock.
Functions on a `ThreadSafeDict` generally acquire this lock and pass the underlying `Dict` to the call, and release
the lock once the call returns.

A `ThreadSafeDict` does not directly support `@lock`, but `parent(t::ThreadSafeDict)` returns a `Lockable`
object that supports `@lock`.
"""
struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
    d :: Base.Lockable{Dict{K, V}, Threads.SpinLock}
    ThreadSafeDict{K, V}(d::Dict{K,V}) where {K,V} = new{K,V}(Base.Lockable(d, Threads.SpinLock()))
    ThreadSafeDict{K, V}(itr) where {K,V} = ThreadSafeDict{K, V}(Dict{K, V}(itr))
    ThreadSafeDict{K, V}() where {K,V} = ThreadSafeDict{K, V}(Dict{K, V}())
end
ThreadSafeDict(d::Dict{K, V}) where V where K = ThreadSafeDict{K, V}(d)
ThreadSafeDict() = ThreadSafeDict{Any,Any}()
function ThreadSafeDict(itr)
    d = Dict(itr)
    ThreadSafeDict(d)
end
Base.parent(dic::ThreadSafeDict) = dic.d

function getindex(dic::ThreadSafeDict, k)
    lockable = parent(dic)
    @lock lockable getindex(lockable[], k)
end


function setindex!(dic::ThreadSafeDict, k, v)
    lockable = parent(dic)
    @lock lockable setindex!(lockable[], k, v)
end

function haskey(dic::ThreadSafeDict, k)
    lock(dic) do d
        haskey(d, k)
    end
end

function get(dic::ThreadSafeDict, k, v)
    lock(dic) do d
        get(d, k, v)
    end
end

function get(f::Union{Function, Type}, dic::ThreadSafeDict, k)
    lock(dic) do d
        get(f, d, k)
    end
end

function get!(dic::ThreadSafeDict, k, v)
    lock(dic) do d
        get!(d, k, v)
    end
end

function get!(f::Union{Function, Type}, dic::ThreadSafeDict, k)
    lock(dic) do d
        get!(f, d, k)
    end
end

function pop!(dic::ThreadSafeDict)
    lock(dic) do d
        pop!(d)
    end
end

function empty!(dic::ThreadSafeDict)
    lock(dic) do d
        empty!(d)
    end
end

function delete!(dic::ThreadSafeDict, k)
    lock(dic) do d
        delete!(d, k)
    end
end

function length(dic::ThreadSafeDict)
    lock(dic) do d
        length(d)
    end
end

function iterate(dic::ThreadSafeDict)
    lock(dic) do d
        iterate(d)
    end
end

function iterate(dic::ThreadSafeDict, i)
    lock(dic) do d
        iterate(d, i)
    end
end

function show(io::IO, dic::ThreadSafeDict)
    lock(dic) do d
        show(io, d)
    end
end

function show(io::IO, m::MIME"text/plain", dic::ThreadSafeDict)
    lock(dic) do d
        show(io, m, d)
    end
end

"""
    lock(f::Function, dic::ThreadSafeDict)

Acquire the lock of the ThreadSafeDict and call the function `f` with the underlying `Dict` as the only argument.
When this function returns, the lock is released.
"""
function Base.lock(f::Function, dic::ThreadSafeDict)
    lockable = parent(dic)
    @lock lockable f(lockable[])
end

end # module
