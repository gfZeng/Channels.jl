
# Flag
mutable struct AltFlag
    lock::ReentrantLock
    raised::Bool
end

raised(flag::AltFlag) = flag.raised
function raise!(flag::AltFlag)
    raised(flag) && return false
    lock(flag.lock)
    suc = raised(flag) ? false : (flag.raised = true)
    unlock(flag.lock)
    return suc
end

raised(::Nothing) = false
raise!(::Nothing) = true
const Flag = Union{Nothing, AltFlag}

# Channel
abstract type AbstractChannel{T} end
mutable struct Channel{T} <: AbstractChannel{T}
    buf::Union{Nothing, AbstractBuffer{T}}
    takes::Threads.Condition
    pushs::Threads.Condition
    push!::Function
    closed::Bool
    function Channel{T}(buf::Union{Integer, Nothing, AbstractBuffer}, xform::Function=identity) where T
        if buf isa Integer
            @assert buf > 0
            buf = Buffer{Fixed, T}(buf)
        end
        lock = ReentrantLock()
        takes, pushs = Threads.Condition(lock), Threads.Condition(lock)
        new(buf, takes, pushs, xform(push!), false)
    end
end
lock(chnl::Channel)     = lock(chnl.takes)
unlock(chnl::Channel)   = unlock(chnl.takes)
trylock(chnl::Channel)  = unlock(chnl.takes)
islocked(chnl::Channel) = islocked(chnl.takes)

close!(chnl::Channel) = chnl.closed = true
close(chnl::Channel) = close!(chnl)
isclosed(chnl::Channel) = chnl.closed

const ABORT = gensym("Abort")
CLOSED_EXCEPTION = InvalidStateException("Channel is closed.", :closed)
checkstate(chnl::Channel) = isclosed(chnl) && throw(CLOSED_EXCEPTION)
isaborted(x) = (x === ABORT)

function push!(chnl::Channel, v; flag::Flag=nothing, blockable::Bool=true)
    lock(chnl)
    try
        checkstate(chnl)
        if isfull(chnl.buf)
            blockable || return false
            wait(chnl.pushs)
        end
        raise!(flag) || return ABORT
        chnl.push!(chnl.buf, v)
        notify(chnl.takes, nothing, false, false)
        return true
    finally
        unlock(chnl)
    end
end

function take!(chnl::Channel; flag::Flag=nothing, blockable::Bool=true)
    lock(chnl)
    try
        checkstate(chnl)
        if isempty(chnl.buf)
            blockable || return nothing
            wait(chnl.takes)
        end
        raise!(flag) || return ABORT
        v = pop!(chnl.buf)
        notify(chnl.pushs, nothing, false, false)
        return v
    finally
        unlock(chnl)
    end
end
