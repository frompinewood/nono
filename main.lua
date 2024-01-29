function love.load()
    length = 10
    size = (love.graphics.getHeight()*0.75) / length
    user_grid = make_grid(length, length, function(i,j) return 0 end) 
    state_grid = make_grid(length, length, 
        function(i,j) 
            return love.math.random(0,1) 
        end)
    vhints = {}
    hhints = {}
    for i = 1, length do
        table.insert(vhints, get_hints(get_col(state_grid, i)))
        table.insert(hhints, get_hints(get_row(state_grid, i)))
    end
    font = love.graphics.newFont(22)
    winfont = love.graphics.newFont(40)
    font_width = font:getWidth('A')
    font_height = font:getHeight()
    love.graphics.setFont(font)
    history = {}
    win = false
end

function reset_game()
    user_grid = make_grid(length, length, function(i,j) return 0 end) 
    state_grid = make_grid(length, length, 
        function(i,j) 
            return love.math.random(0,1) 
        end)
    vhints = {}
    hhints = {}
    for i = 1, length do
        table.insert(vhints, get_hints(get_col(state_grid, i)))
        table.insert(hhints, get_hints(get_row(state_grid, i)))
    end
    history = {}
    win = false
end

function love.update(dt)
-- check win state
    win = true
    for x = 1, length do
        for y = 1, length do
            if user_grid[x][y] ~= state_grid[x][y] and
                (state_grid[x][y] == 1 or user_grid[x][y] == 1) then
                 win = false
             end
        end
    end
-- check hints
    for i = 1, length do
        vhint = get_hints(get_col(user_grid, i))
        hhint = get_hints(get_row(user_grid, i))
        if cmp_hints(vhint, vhints[i]) == true then
            fill_col(user_grid, i)
        end
        if cmp_hints(hhint, hhints[i]) == true then
            fill_row(user_grid, i)
        end
    end
end

function love.keypressed(key, is_repeat)
    if key == 'u' and #history > 0 then
        move = table.remove(history)
        user_grid[move[1]][move[2]] = move[3]
    end
    if key == 'r' then
        reset_game()
    end
end

function love.mousepressed(x, y, button)
    mousedown = button
    local x, y = screen_to_grid(x, y)
    if x == 0 then return nil end
    table.insert(history, {x, y, user_grid[x][y]})
    if button == 1 then
        if user_grid[x][y] == 0 then
            user_grid[x][y] = 1
        else
            user_grid[x][y] = 0 
        end
    end
    if button == 2 then
        user_grid[x][y] = 2
    end
end

function love.mousemoved(x, y, dx, dy)
    local x, y = screen_to_grid(x, y)
    if x == 0 then return nil end
    local button = 0
    if love.mouse.isDown(1) then
        button = 1
    end
    if love.mouse.isDown(2) then
        button = 2
    end
    if user_grid[x][y] == 0 and button ~= 0 then
        user_grid[x][y] = button
        table.insert(history, {x, y, 0})
    end
end

function love.draw()
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    draw_grid(0, 0, user_grid) 
    love.graphics.setColor(0, 0, 0)

    if win == true then
        draw_win_screen()
    end
end

function draw_grid(x, y, grid)
    for i = 1, #grid do
        for j = 1, #grid[i] do
            draw_cell(x+i-1, y+j-1, grid[i][j])
        end
        draw_h_hint(i, vhints[i])
        draw_v_hint(i, hhints[i])
    end
end

function fill_col(grid, n)
    for i = 1, length do
        if grid[i][n] ~= 1 then
            grid[i][n] = 2
        end
    end
end

function fill_row(grid, n)
    for i = 1, length do
        if grid[n][i] ~= 1 then
            grid[n][i] = 2
        end
    end
end

function draw_win_screen()
    love.graphics.setFont(winfont)
    x1 = math.floor(size * length * 0.3)
    y1 = math.floor(size * length * 0.3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', x1, y1, size * 4, size * 4)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("You Win!!!", x1 + size, y1 + size)
end

function draw_cell(x, y, cell)
    x1 = (x * size) + 1
    y1 = (y * size) + 1
    if cell == 0 then
        love.graphics.setColor(0, 0, 0)
    end
    if cell == 1 then
        love.graphics.setColor(1, 1, 1)
    end
    if cell == 2 then
        love.graphics.setColor(0.4, 0.4, 0.4)
    end
    love.graphics.rectangle('fill', x1, y1, size-1, size-1)
    love.graphics.setColor(1, 1, 1)
end

function draw_h_hint(y, hints)
    x1 = (size * (length)) + 10
    y1 = ((y - 1) * size) + math.floor(size / 2) - font_height / 2
    hintstr = string.reverse(join_str(hints, " "))        
    love.graphics.print(hintstr, math.floor(x1), math.floor(y1)) 
end

function draw_v_hint(x, hints)
    x1 = ((x-1) * size) + math.floor(size / 2) - font_width / 2
    y1 = (size * length) + 10
    for i, hint in ipairs(hints) do
        love.graphics.print(hint, math.floor(x1), math.floor(y1 + (i * font_height)))
    end
end

function make_grid(width, height, func)
    local cells = {}
    for i = 1, width do
        cells[i] = {}
        for j = 1, height do
            cells[i][j] = func(i,j)
        end
    end
    return cells
end

function get_row(grid, n)
    return grid[n]
end

function get_col(grid, n)
    local row = {}
    for i = 1, length do
       row[i] = grid[i][n] 
    end
    return row
end

function get_hints(cells)
    local hints = {}
    local hint = 0
    for i = 1, #cells do
        if cells[i] == 1 then
           hint = hint + 1 
        end 
        if hint > 0 and cells[i] == 0 then
            table.insert(hints, hint)
            hint = 0
        end
    end
    if hint > 0 then 
        table.insert(hints, hint) 
    end
    return hints
end

function cmp_hints(h1, h2)
    if #h1 ~= #h2 then return false end
    for i = 0, #h1 do
        if h1[i+1] ~= h2[i+1] then
            return false
        end
    end
    return true
end

function screen_to_grid(x, y)
    x1 = math.floor(x / size) + 1
    y1 = math.floor(y / size) + 1
    if x1 > length or y1 > length then return 0, 0 end
    return x1, y1
end

function foldl(fun, acc, list)
    for i = 1, #list do
        acc = fun(list[i], acc)
    end
    return acc
end

function join_str(list, delim)
    if #list == 0 then return '' end
    return foldl(function(a, b) 
        return a .. delim .. b 
    end, '', list)
end
