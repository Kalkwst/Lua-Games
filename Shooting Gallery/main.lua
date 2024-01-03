function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    timer = 0
    gameState = 1

    gameFont = love.graphics.newFont(40)

    sprites = {}
    sprites.sky = love.graphics.newImage('sprites/sky.png')
    sprites.target = love.graphics.newImage('sprites/target.png')
    sprites.crosshairs = love.graphics.newImage('sprites/crosshairs.png')

    mouseX = 0
    mouseY = 0
end

function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
    if timer > 0 then
        timer = timer - dt
    end

    if timer < 0 then
        timer = 0
        gameState = 1
    end
end

function love.draw()
    love.graphics.draw(sprites.sky, 0, 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 5, 5)
    love.graphics.print("Time: " .. math.ceil(timer), 300, 5)

    if gameState == 1 then
        love.graphics.printf("Click anywhere to begin!", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(),
            "center")
    end

    if gameState == 2 then
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius)
        love.graphics.draw(sprites.crosshairs, mouseX - 20, mouseY - 20)
    end

    love.mouse.setVisible(false)

    -- love.graphics.print(mouseX, 100, 0)
    -- love.graphics.print(mouseY, 250, 0)
    -- love.graphics.print(distanceBetween(mouseX, mouseY, target.x, target.y), 400, 0)
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState ~= 2 then
        gameState = 2
        timer = 10
        score = 0
    end

    if gameState == 2 then
        local hit = checkHit(x, y)

        if hit then
            if button == 1 then
                score = score + 1
            end

            if button == 2 then
                score = score + 2
                timer = timer - 1
            end

            moveTarget()
        else
            if score > 0 then
                score = score - 1
            end
        end
    end
    -- if gameState == 2 and button == 1 and checkHit(x, y) then
    --     score = score + 1
    --     moveTarget()
    -- end

    -- if (game)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function moveTarget()
    math.randomseed(os.time())
    target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
    target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
end

function checkHit(buttonX, buttonY)
    local distance = distanceBetween(buttonX, buttonY, target.x, target.y)

    if (distance < target.radius) then
        return true
    end

    return false
end
