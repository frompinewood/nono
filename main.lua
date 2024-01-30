--initialize the starting state
function love.load()
    -- const
    EMPTY = 0
    FILL = 1
    MARK = 2

    -- resources
    images = {}
    images[EMPTY] = love.graphics.newImage("res/empty.png")
    images[FILL] = love.graphics.newImage("res/fill.png")
    images[MARK] = love.graphics.newImage("res/mark.png")

    img_x_scale = 1
    img_y_scale = 1

    -- screen
    screen_width, screen_height = 0, 0
    square_size = 0
    
    -- initialize vars
    hint_window = 0
    grid_width = 5
    grid_height = 5
    user_grid = {}
    state_grid = {}
    history = {}
    last_x = 0
    last_y = 0
    last_cell = -1
    font_height = love.graphics.getFont():getHeight()/2
    -- hints
    user_vert_hints = {}
    user_horz_hints = {}
    vert_hints = {}
    horz_hints = {}
    won = false

    -- set new game
    new_game(nil, nil, true)
end

function new_game(width, height, reset)
    history = {}
    screen_width, screen_height = love.graphics.getDimensions()
    hint_scale = 0.2
    hint_window = (math.floor(math.min(screen_width, screen_height)) * hint_scale) 
    game_width, game_height = screen_width - hint_window, screen_height - hint_window
    grid_width = width or grid_width
    grid_height = height or grid_height
    square_size = math.floor(math.min(game_width, game_height) / math.max(grid_width, grid_height))
    img_x_scale = square_size / images[EMPTY]:getWidth()
    img_y_scale = square_size / images[EMPTY]:getHeight()
    won = false
    if reset == true then
        user_grid = make_grid(grid_width, grid_height)
        state_grid = make_grid(grid_width, grid_height, function(x, y)
            return love.math.random(0, 1)
        end)
    end
    horz_hints = {}
    vert_hints = {}
    for i = 1, grid_height do
        table.insert(horz_hints, calc_hints(get_row(state_grid, i)))
    end
    for i = 1, grid_width do
        table.insert(vert_hints, calc_hints(get_col(state_grid, i)))
    end
end

function love.resize(width, height)
    new_game(nil, nil, false)
end

function love.update(dt)
    -- set user hints
    user_horz_hints = {}
    user_vert_hints = {}
    for i = 1, grid_height do
        table.insert(user_horz_hints, calc_hints(get_row(user_grid, i)))
    end
    for i = 1, grid_width do
        table.insert(user_vert_hints, calc_hints(get_col(user_grid, i)))
    end
    won = is_won()
end

function love.draw()
    if won == true then
        love.graphics.print("You won!")
    end
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    draw_grid(user_grid, hint_window, hint_window)
    draw_vert_hints(vert_hints)
    draw_horz_hints(horz_hints)
end

function is_won()
    for x = 1, grid_width do
        for y = 1, grid_height do
            if user_grid[x][y] ~= state_grid[x][y] and
               (state_grid[x][y] == FILL or user_grid[x][y] == FILL) then
               return false
           end
        end
    end
    return true
end

function draw_grid(grid, xoff, yoff) 
    for x = 1, grid_width do
        for y = 1, grid_height do
            img = images[grid[x][y]]
            draw_img(img, x, y, xoff, yoff)
        end
    end
end

function draw_img(img, x, y, xoff, yoff)
    love.graphics.draw(img, ((x - 1) * square_size) + xoff, ((y - 1) * square_size) + yoff, 0, img_x_scale, img_y_scale)
end

function draw_horz_hints(horz_hints)
    for i = 1, grid_height do
        hint = horz_hints[i]
        for j = 1, #hint do
            local x = hint_window - (j * (square_size/2))
            local y = hint_window + 
                      ((i - 1) * square_size) + 
                      (square_size / 2) - 
                      font_height
            love.graphics.print(hint[#hint-j+1], x, y)
        end
    end
end

function draw_vert_hints(vert_hints)
    for i = 1, grid_width do
        hint = vert_hints[i]
        for j = 1, #hint do
            -- calc hint coordinates
            local x = hint_window + 
                      ((i - 1) * square_size) +
                      (square_size / 2) -
                      font_height
            local y = hint_window - (j * (square_size/2))
            love.graphics.print(hint[#hint-j+1], x, y)
        end
    end
end

-- hint stuff
function calc_hints(lane)
    hints = {}
    hint = 0
    for i = 1, #lane do
        if lane[i] == FILL then
            hint = hint + 1
        elseif hint > 0 then
            table.insert(hints, hint)
            hint = 0
        end
    end
    if #hints == 0 or hint > 0 then
        table.insert(hints, hint)
    end
    return hints
end

function get_row(grid, i)
    local row = {}
    for n = 1, grid_width do
        table.insert(row, grid[n][i])
    end
    return row
end

function get_col(grid, i)
    local col = {}
    for n = 1, grid_height do
        table.insert(col, grid[i][n])
    end
    return col
end

-- grid stuff
function make_grid(width, height, fill)    
    if fill == nil then
        fill = function(x, y) return EMPTY end
    end
    local grid = {}
    for i = 1, width do
        table.insert(grid, {})
        for j = 1, height do
            table.insert(grid[i], fill(i, j))
        end
    end
    return grid
end

-- keyboard stuff
function love.keypressed(key, isrepeat)
    if key == 'r' then new_game(nil, nil, true) end
    if key == 'u' then pop_history() end
    -- these are terrible sorry
    if key == '1' then 
        new_game(5, 5, true)
    end
    if key == '2' then 
        new_game(10, 10, true) 
    end
    if key == '3' then 
        new_game(15, 15, true) 
    end
    if key == 's' then
        print_known()
    end
end

-- mouse stuff
function love.mousepressed(x, y, button)
    local button = conv_button(button)
    local x, y = screen_to_grid(x, y)
    if x <= 0 or x > grid_width then return nil end
    if y <= 0 or y > grid_height then return nil end
    local cell = user_grid[x][y]
    push_history(x, y, cell)
    if cell == button then
        user_grid[x][y] = EMPTY
    else
        user_grid[x][y] = button
    end
    last_x, last_y = x, y
    last_cell = cell
end

function love.mousemoved(x, y)
    button = get_mouse_down()
    if button == nil then return nil end 
    x, y = screen_to_grid(x, y)
    if x <= 0 or x > grid_width then return nil end
    if y <= 0 or y > grid_height then return nil end
    curr = user_grid[x][y]
    if (x ~= last_x or y ~= last_y) and curr == last_cell then
        push_history(x, y, curr)
        user_grid[x][y] = button
    end
end

function get_mouse_down()
    if love.mouse.isDown(1) then return FILL end
    if love.mouse.isDown(2) then return MARK end
    return nil
end

function screen_to_grid(x, y)
    if won == true then return 0 end
    x1 = math.floor((x - hint_window) / square_size) + 1
    y1 = math.floor((y - hint_window) / square_size) + 1
    return x1, y1
end

function conv_button(button)
    if button == 0 then return EMPTY end
    if button == 1 then return FILL end
    if button == 2 then return MARK end
    return nil
end

-- history functions
function push_history(x, y, prev)
    table.insert(history, {x, y, prev})
end

function pop_history()
    if #history == 0 then return nil end
    item = table.remove(history)
    user_grid[item[1]][item[2]] = item[3]
end

-- solver stuff
function fill_col_range(col, a, b, fill)
    for i = a, b do
        user_grid[col][i] = fill
    end
end

function fill_row_range(row, a, b, fill)
    for i = a, b do
        user_grid[i][row] = fill
    end
end

function hint_weight(hint)
    sum = 0
    for i = 1, #hint do
        sum = sum + hint[i]
    end
    return sum + #hint - 1
end

