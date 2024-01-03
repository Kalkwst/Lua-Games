function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180
    player.orientation = 0
    
    zombies = {}

    offsets = {}
    offsets.playerX = sprites.player:getWidth() / 2
    offsets.playerY = sprites.player:getHeight() / 2
    offsets.zombieX = sprites.zombie:getWidth() / 2
    offsets.zombieY = sprites.zombie:getHeight() / 2
end

function love.update(dt)
    handlePlayerMovement(dt)
    handleZombiesMovement(dt)

    if love.keyboard.isDown("space") then
        spawnZombie()
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    love.graphics.draw(sprites.player, player.x, player.y, player.orientation, nil, nil, offsets.playerX, offsets.playerY)

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, offsets.zombieX, offsets.zombieY)
    end
end

function handlePlayerMovement(dt)
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
    end

    player.orientation = playerMouseAngle()
end

function handleZombiesMovement(dt)
    for i, z in ipairs(zombies) do
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)
    end
end

function playerMouseAngle()
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function zombiePlayerAngle(zombie)
    return math.atan2(player.y - zombie.y, player.x - zombie.x)
end


function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    zombie.speed = 140

    if isFastZombie() then
        zombie.speed = 220
    end

    table.insert(zombies, zombie)
end

function isFastZombie()
    if math.random() < 0.12 then
        return true
    else
        return false
    end
end