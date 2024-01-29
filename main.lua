--initialize the starting state
function love.load()
    -- const
    EMPTY = 0
    FILL = 1
    MARKED = 2

    EMPTY_IMG = love.graphics.newImage("empty.png")
    FILL_IMG = love.graphics.newImage("fill.png")
    MARK_IMG = love.graphics.newImage("mark.png")

    images = {}
    images[EMPTY] = EMPTY_IMG
    images[FILL] = FILL_IMG
    images[MARKED] = MARK_IMG

    img_size = EMPTY_IMG:getWidth()

    SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()


    -- grid params
    grid_width = 0
    grid_height = 0

    -- screen params
    hint_space = 0.30 

    x_off = SCREEN_WIDTH * hint_space
    y_off = SCREEN_HEIGHT * hint_space

    screen_width = SCREEN_WIDTH - x_off
    screen_height = SCREEN_HEIGHT - y_off
    square_size = math.min(screen_width, screen_height) / math.max(grid_width, grid_height)

    -- grid vars
    user_grid = {}
    state_grid = {}
    reset_game()
end

function reset_game()
    grid_width = 10
    grid_height = 10
    user_grid = make_grid(grid_width, grid_height)
    state_grid = make_grid(grid_width, grid_height, function(x, y)
        return love.math.random(0, 1)
    end)
end

function love.update(dt)

end

function love.draw()
    draw_grid(state_grid, 10, 10)
end

function draw_grid(grid, xoff, yoff) 
    for x = 1, grid_width do
        for y = 1, grid_height do
            img = images[grid[x][y]]
            love.graphics.draw(img, x * img_size, y * img_size)
        end
    end
end

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
