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
    player.hp = 0
    
    zombies = {}

    bullets = {}

    offsets = {}
    offsets.playerX = sprites.player:getWidth() / 2
    offsets.playerY = sprites.player:getHeight() / 2
    offsets.zombieX = sprites.zombie:getWidth() / 2
    offsets.zombieY = sprites.zombie:getHeight() / 2
    offsets.bulletX = sprites.bullet:getWidth() / 2
    offsets.bulletY = sprites.bullet:getHeight() / 2

    gameFont = love.graphics.newFont(40)
end

function love.update(dt)
    handlePlayerMovement(dt)
    handleZombiesMovement(dt)
    handleBulletsMovement(dt)
    handleCollisions()
    despawnBullets()
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    love.graphics.setFont(gameFont)
    love.graphics.print("HP: " .. player.hp)

    love.graphics.draw(sprites.player, player.x, player.y, player.orientation, nil, nil, offsets.playerX, offsets.playerY)

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), z.scaleFactor, z.scaleFactor, offsets.zombieX, offsets.zombieY)
    end

    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.2, 0.2, offsets.bulletX, offsets.bulletY)
    end
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button) 
    if button == 1 then
        spawnBullet()
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

function handleBulletsMovement(dt)
    for i, b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end
end

function handleCollisions()
    for i, z in ipairs(zombies) do
        if distanceBetween(z.x, z.y, player.x, player.y) < 10 then
            player.hp = player.hp - 1
        end

        for j, b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 10 then
                handleBulletWound(b, z)
            end
        end
    end
end

function handleBulletWound(bullet, zombie)
    bullet.dead = true
    zombie.health = zombie.health - bullet.damage

    if zombie.health <= 0 then
        zombie.dead = true
    end

    for i=#zombies, 1, -1 do
        local z = zombies[i]
        if z.dead then
            table.remove(zombies, i)
        end
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.dead then
            table.remove(bullets, i)
        end
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
    zombie.health = 10
    zombie.dead = false
    zombie.scaleFactor = 1

    if isFastZombie() then
        zombie.speed = 220
    end

    if isBeefyZombie() then
        zombie.health = 30
        zombie.scaleFactor = 2
        zombie.speed = 90
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    bullet.damage = 10
    bullet.dead = false

    table.insert(bullets, bullet)
end

function despawnBullets()
    for i=#bullets, 1, -1 do
        local b = bullets[i]

        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end
end

function isFastZombie()
    if math.random() < 0.12 then
        return true
    else
        return false
    end
end

function isBeefyZombie()
    if math.random() < 0.08 then
        return true
    else
        return false
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end