abstract type AbstractChannel{T} end

mutable struct Channel{T} <: AbstractChannel{T}
    buf::Union{Nothing, AbstractBuffer{T}}
    add!::Function
    takes::LinkedList{Task}
    pushs::LinkedList{Task}
    mutex::ReentrantLock
    ct::Task
    function Channel{T}(buf, xform=identity) where T
        buf = buf isa Integer ? Buffer{:Fixed, T}(buf) : buf
        new(buf, xform(add!), LinkedList{Task}(), LinkedList{Task}(), ReentrantLock(), current_task())
     end
    Channel{T}() where T = Channel{T}(nothing)
end

Base.lock(chnl::Channel) = lock(chnl.mutex)
Base.unlock(chnl::Channel) = unlock(chnl.mutex)


function Base.lock(f, chnl::AbstractChannel)
    lock(chnl)
    try
        f()
    catch e
        @error e
        rethrow(e)
    finally
        unlock(chnl)
    end
end

function push_unbuffered(chnl::Channel, e)
    t = nothing
    iswait = lock(chnl) do
        if isempty(chnl.takes)
            t = @task schedule(chnl.ct, e)
            push!(chnl.pushs, t)
            return true
        end
        chnl.ct = current_task()
        t = popfirst!(chnl.takes)
        t.storage = e
        yieldto(t)
        return false
    end
    iswait && wait(t)
    return e
end

function push_buffered(chnl::Channel, e)
    iswait = lock(chnl) do
        if isfull(chnl.buf)
            t = @task begin
                chnl.push!(chnl.buf, e)
                schedule(chnl.ct)
            end
            return true
        end
    end
end


function take_unbuffered(chnl::Channel)
    t = nothing
    ret = nothing
    iswait = lock(chnl) do
        if isempty(chnl.pushs)
            t = @task schedule(chnl.ct)
            push!(chnl.takes, t)
            return true
        end
        chnl.ct = current_task()
        ret = yieldto(popfirst!(chnl.pushs))
        return false
    end
    iswait && (wait(t); return t.storage)
    return ret
end

function take_buffered(chnl::Channel)
end

isbuffered(chnl::Channel) = !isnothing(chnl.buf)

Base.take!(chnl::Channel) = isbuffered(chnl) ? take_buffered(chnl) : take_unbuffered(chnl)
Base.push!(chnl::Channel, e) = isbuffered(chnl) ? push_buffered(chnl, e) : push_unbuffered(chnl, e)
