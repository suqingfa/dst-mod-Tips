local calls = {}
local total = {}

function profile_start()
    calls = {}
    total = {}

    debug.sethook(function(event)
        local i = debug.getinfo(2, "Sln")
        if i.what ~= 'Lua' then
            return
        end

        local func = i.name or (i.source .. ':' .. i.linedefined)

        if event == 'call' then
            calls[func] = os.clock()
        else
            local time = calls[func] and os.clock() - calls[func] or 0
            total[func] = (total[func] or 0) + time
        end
    end, "cr")
end

function profile_stop()
    debug.sethook()
end

function profile_print()
    print('func', 'time')
    for k, v in pairs(total) do
        print(k, v)
    end
end