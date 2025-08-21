--moves the snake
function snake_movement()
    --limits the snake movement
    if game.input_last == "up" and game.snake_dy ~= 1 then
        game.snake_dx = 0
        game.snake_dy = -1
    end
    if game.input_last == "down" and game.snake_dy ~= -1 then
        game.snake_dx = 0
        game.snake_dy = 1
    end
    if game.input_last == "left" and game.snake_dx ~= 1 then
        game.snake_dx = -1
        game.snake_dy = 0
    end
    if game.input_last == "right" and game.snake_dx ~= -1 then
        game.snake_dx = 1
        game.snake_dy = 0
    end
    
    --moves snake tail
    if #snake>1 then
        for i=#snake, 2, -1 do
            snake[i].x = snake[i-1].x
            snake[i].y = snake[i-1].y
        end
    end
    
    --moves snake head
    snake[1].x = snake[1].x + game.snake_dx
    snake[1].y = snake[1].y + game.snake_dy
end

--checks if snake is colliding
function snake_collision()
    --checks apple collision
    if snake[1].x == apple.x and snake[1].y == apple.y then
        apple_make()
        
        game.current_score = game.current_score + 1
        if game.current_score>game.high_score then
            game.high_score = game.current_score
        end
        
        table.insert(snake, {x=-1, y=-1, r=0, g=255, b=0, w=75, h=75})
    end
    
    --checks tail collision
    for i=#snake, 2, -1 do
        if snake[1].x == snake[i].x and snake[1].y == snake[i].y then
            game_reset()
            break
        end
    end
    
    --checks out if bounds
    if snake[1].x<0 or snake[1].x>11 or snake[1].y<0 or snake[1].y>7 then
        game_reset()
    end
end

--place the apple at random
function apple_make()
    local avoid_place = {}
    
    for _, i in ipairs(snake) do
        table.insert(avoid_place, {x=i.x, y=i.y})
    end
    
    local function position_included(table, value)
        for _, i in pairs(table) do
            if i.x == value.x and i.y == value.y then
                return true
            end
        end
        
        return false
    end
    
    apple.x = math.random(11)
    apple.y = math.random(7)
    
    while position_included(avoid_place, {x=apple.x, y=apple.y}) do
        apple.x = math.random(11)
        apple.y = math.random(7)
    end
end

--resets the current game
function game_reset()
    snake = {
        [1] = {x=6, y=4, r=0, g=255, b=0, w=75, h=75}
    }
    apple = {
        x=2, y=2, r=255, g=0, b=0, w=75, h=75
    }
    game.current_score = 1
    game.input_last = "none"
    game.snake_dx = 0
    game.snake_dy = 0
end

function love.keypressed(key)
    --game control
    if key == "up" then
        game.input_last = "up"
    end
    if key == "down" then
        game.input_last = "down"
    end
    if key == "left" then
        game.input_last = "left"
    end
    if key == "right" then
        game.input_last = "right"
    end
end

function love.load()
    --define tables
    snake = {
        [1] = {x=6, y=4, r=0, g=255, b=0, w=75, h=75}
    }
    apple = {
        x=2, y=2, r=255, g=0, b=0, w=75, h=75
    }
    game = {
        current_score=1,
        high_score=1,
        update=0,
        refresh=1/5,
        input_last="none",
        snake_dx=0,
        snake_dy=0
    }
    draw_list = {}
    
    math.randomseed(os.time())
end

function love.update(dt)    
    --game loop
    game.update = game.update + dt
    if game.update>game.refresh then
        game.update = 0
        
        snake_movement()
        snake_collision()
        
        draw_list = {}
        table.insert(draw_list, apple)
        for _, i in ipairs(snake) do
            table.insert(draw_list, i)
        end
    end
end

function love.draw()
    --background
    love.graphics.setColor(30, 30, 30)
    love.graphics.rectangle("fill", 0, 0, 900, 600)
    
    --game objects
    for _, i in ipairs(draw_list) do
        love.graphics.setColor(i.r, i.g, i.b)
        love.graphics.rectangle("fill", i.x*i.w, i.y*i.h, i.w, i.h)
    end
    
    --text
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Score: "..tostring(game.current_score), 0, 0, 0, 3, 3)
    love.graphics.print("Highest Score: "..tostring(game.high_score), 0, 50, 0, 3, 3)
end