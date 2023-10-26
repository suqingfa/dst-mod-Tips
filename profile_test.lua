require('profile')

profile_start()

local N = 1e6

function test_sum(n)
    local sum = 0
    for i = 1, n do
        sum = sum + i
    end
    return sum
end

test_sum(N)

function test_get_up_value(n)
    for _ = 1, n do
        debug.getupvalue(test_sum, 1)
    end
end

test_get_up_value(N)

profile_stop()
profile_print()