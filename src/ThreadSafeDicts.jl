""" ThreadSafeDicts package source code """

module ThreadSafeDicts

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.haskey, Base.delete!, Base.print, Base.iterate, Base.length
export ThreadSafeDict

"""
    ThreadSafeDict(pairs::Vector{Pair{K,V}})

Struct and constructor for ThreadSafeDict. There is one lock per Dict struct. All functions lock this lock, pass
arguments to the d member Dict, unlock the lock, and then return what is returned by the Dict.
"""
struct ThreadSafeDict{K, V} <: AbstractDict{K, V}
    dlock::ReentrantLock
    d::Dict{K, V}
    ThreadSafeDict{K, V}() where V where K = new(ReentrantLock(), Dict{K, V}())
    ThreadSafeDict{K, V}(d::Dict{K, V}) where V where K = new(ReentrantLock(), d)
    ThreadSafeDict{K, V}(itr) where V where K = new(ReentrantLock(), Dict{K, V}(itr))
end
ThreadSafeDict(d::Dict{K, V}) where V where K = ThreadSafeDict{K, V}(d)
ThreadSafeDict() = ThreadSafeDict{Any,Any}()
function ThreadSafeDict(itr)
    d = Dict(itr)
    ThreadSafeDict(d)
end

function getindex(dic::ThreadSafeDict, k)
    @lock dic.dlock getindex(dic.d, k)
end

function setindex!(dic::ThreadSafeDict, k, v)
    @lock dic.dlock setindex!(dic.d, k, v)
end

function haskey(dic::ThreadSafeDict, k)
    @lock dic.dlock haskey(dic.d, k)
end

function get(dic::ThreadSafeDict, k, v)
    @lock dic.dlock get(dic.d, k, v)
end

function get(f::Union{Function, Type}, dic::ThreadSafeDict, k)
    @lock dic.dlock get(f, dic.d, k)
end

function get!(dic::ThreadSafeDict, k, v)
    @lock dic.dlock get!(dic.d, k, v)
end

function get!(f::Union{Function, Type}, dic::ThreadSafeDict, k)
    @lock dic.dlock get!(f, dic.d, k)
end

function pop!(dic::ThreadSafeDict)
    @lock dic.dlock pop!(dic.d)
end

function empty!(dic::ThreadSafeDict)
    @lock dic.dlock empty!(dic.d)
end

function delete!(dic::ThreadSafeDict, k)
    @lock dic.dlock delete!(dic.d, k)
end

function length(dic::ThreadSafeDict)
    @lock dic.dlock length(dic.d)
end

function iterate(dic::ThreadSafeDict)
    @lock dic.dlock iterate(dic.d)
end

function iterate(dic::ThreadSafeDict, i)
    @lock dic.dlock iterate(dic.d, i)
end

function show(io::IO, dic::ThreadSafeDict)
    @lock dic.dlock show(io, dic.d)
end

function show(io::IO, m::MIME"text/plain", dic::ThreadSafeDict)
    @lock dic.dlock show(io, m, dic.d)
end

end # module
