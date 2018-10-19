shift_direction = 1

function reverse_shift()
    --print('stop shifting...')
    local delay_target = 1000
    local interval = delay_ms
    local multiplier = 0.5
    
    -- slows
    tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
        interval = interval / multiplier
        tmr.interval(0, interval)
        --print('interval', interval)
        if multiplier > 1 and interval <= delay_target
        or multiplier < 1 and interval >= delay_target then
            --print('shifting reversed')
            shift_direction = shift_direction * -1
            tmr.interval(0, delay_ms)
            tmr.unregister(1)
        end
    end)
end

--

ws2812.init()

local i, buffer = 0, ws2812.newBuffer(led_count, 3)
method = random_method()

h, s, l = math.random(), saturation, brightness

buffer:fill(0, 0, 0)
ws2812.write(buffer)

-- main cycle
tmr.alarm(0, 15, tmr.ALARM_AUTO, function()
    buffer:shift(shift_direction, ws2812.SHIFT_CIRCULAR)
    ws2812.write(buffer)

    local pos = i % led_count
    
    -- full strip cycle
    if pos == 0 then
        method = random_method()
        print('method: ', method)
        --print_power(buffer)
        ws2812.write(buffer)
        color_random_cycle = math.random(1, 255) / 255
    end

    -- fill method
    if method == 0 then
        -- rainbow
        color = i % 255 / 255
    elseif method == 1 then
        -- waterfall
        color = math.random(1, 255) / 255
    else
        -- solid
        color = color_random_cycle
    end

    -- add pixel for fill shifted
    buffer:set(1, hslToRgb(color, s, l, 1))

    -- dead pixel after each led strip full cycle
    if pos == 0 then
        buffer:set(1, 0, 0, 0)
    end

    -- reverse flow effect
    if reverse_chance > 0 and math.random(0, led_count / reverse_chance) == 1 then
        reverse_shift()
    end

    -- dead pixel effect
    if dead_picel_chance > 0 and math.random(0, led_count / dead_picel_chance) == 1 then
        local color_pixel
        if method == 1 then
            -- черный пиксель, иначе будет не видно
            color_pixel = {0, 0, 0}
        else
            -- рандомный цвет пикселя (потемнее, чтобы видно было)
            color_pixel = {hslToRgb(math.random(1, 255) / 255 , s , l / 2, 1)}
        end
        buffer:set(1, color_pixel)
        --print('random dead pixel')
    end
    
    i = i + 1
end)
