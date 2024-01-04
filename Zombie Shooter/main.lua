function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')
    sprites.machineGun = love.graphics.newImage('sprites/machinegun.png')
    sprites.machineGunMan = love.graphics.newImage('sprites/machinegunman.png')

    player = {}
    player.sprite = sprites.player
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180
    player.orientation = 0
    player.hp = 10
    player.damage = 10
    player.canTakeDmg = true

    zombies = {}

    bullets = {}

    powerUps = {}

    offsets = {}
    offsets.playerX = sprites.player:getWidth() / 2
    offsets.playerY = sprites.player:getHeight() / 2
    offsets.zombieX = sprites.zombie:getWidth() / 2
    offsets.zombieY = sprites.zombie:getHeight() / 2
    offsets.bulletX = sprites.bullet:getWidth() / 2
    offsets.bulletY = sprites.bullet:getHeight() / 2

    gameFont = love.graphics.newFont(40)

    gameState = 1
    maxZombieTime = 2
    zombieTimer = 2

    machineGunSpawned = false
    machineGunTimer = 180

    playerDamageTimer = 0

    score = 0
    gameTimer = 300
end

function love.update(dt)
    handlePlayerMovement(dt)
    handleZombiesMovement(dt)
    handleBulletsMovement(dt)
    handleCollisions()
    despawnBullets()

    if gameState == 2 then

        if gameTimer > 0 then
            gameTimer = gameTimer - dt
        end
    
        if gameTimer < 0 then
            gameTimer = 0
            gameState = 1
        end

        zombieTimer = zombieTimer - dt
        machineGunTimer = machineGunTimer - dt

        if zombieTimer <= 0 then
            spawnZombie()
            zombieTimer = math.random(0.8, maxZombieTime)
            maxZombieTime = maxZombieTime * 0.9
        end

        if machineGunTimer <= 0 then
            spawnMachineGun()
            machineGunSpawned = true
        end

        if playerDamageTimer <= 0 and player.canTakeDmg == false then
            player.canTakeDmg = true
            playerDamageTimer = 0.2
        end

        if playerDamageTimer > 0 then
            playerDamageTimer = playerDamageTimer - dt
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    love.graphics.setFont(gameFont)
    love.graphics.print("HP: " .. player.hp)

    love.graphics.print("Score: ".. score, 225)
    love.graphics.print("Time: " .. math.ceil(gameTimer), 450)

    if gameState == 1 then
        love.graphics.printf("Click anywhere to begin!", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(),
            "center")
    end

    love.graphics
        .draw(player.sprite, player.x, player.y, player.orientation, nil, nil, offsets.playerX, offsets.playerY)

    for i, z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), z.scaleFactor, z.scaleFactor,
            offsets.zombieX, offsets.zombieY)
    end

    for i, b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.2, 0.2, offsets.bulletX, offsets.bulletY)
    end

    for i, p in ipairs(powerUps) do
        love.graphics.draw(p.sprite, p.x, p.y)
    end
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    elseif button == 1 and gameState == 1 then
        gameState = 2
        machineGunSpawned = false
        player.hp = 10
    end
end

function handlePlayerMovement(dt)
    if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and player.x < love.graphics.getWidth() then
        player.x = player.x + player.speed * dt
    end

    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and player.x > 0 then
        player.x = player.x - player.speed * dt
    end

    if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and player.y > 0 then
        player.y = player.y - player.speed * dt
    end

    if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) and player.y < love.graphics.getHeight() then
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
            if player.canTakeDmg == true then
                player.hp = player.hp - 1
                playerDamageTimer = 0.4
                player.canTakeDmg = false
            end
            

            if player.hp == 0 then
                gameState = 1

                for i,z in ipairs(zombies) do
                    zombies[i] = nil
                end
            end
        end

        for j, b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 10 then
                handleBulletWound(b, z)
            end
        end
    end

    for i, p in ipairs(powerUps) do
        if distanceBetween(player.x, player.y, p.x, p.y) < 50 then
            handlePowerUp(player, p)

            table.remove(powerUps, i)
        end
    end
end

function handleBulletWound(bullet, zombie)
    bullet.dead = true
    zombie.health = zombie.health - bullet.damage

    if zombie.health <= 0 then
        zombie.dead = true
        score = score + zombie.score
    end

    for i = #zombies, 1, -1 do
        local z = zombies[i]
        if z.dead then
            table.remove(zombies, i)
        end
    end

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.dead then
            table.remove(bullets, i)
        end
    end
end

function handlePowerUp(player, p)
    if p.type == "machinegun" then
        player.sprite = sprites.machineGunMan
        player.damage = 20
        p.dead = true
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
    zombie.score = 1

    if isFastZombie() then
        zombie.speed = 220
        zombie.score = 2
    end

    if isBeefyZombie() then
        zombie.health = 30
        zombie.scaleFactor = 2
        zombie.speed = 90
        zombie.score = 3
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    bullet.damage = player.damage
    bullet.dead = false

    table.insert(bullets, bullet)
end

function spawnMachineGun()
    if machineGunSpawned == false then
        local machineGun = {}
        machineGun.sprite = sprites.machineGun
        machineGun.type = "machinegun"
        machineGun.x = math.random(0, love.graphics.getWidth())
        machineGun.y = math.random(0, love.graphics.getHeight())
        machineGun.dead = false

        table.insert(powerUps, machineGun)
    end
end

function despawnBullets()
    for i = #bullets, 1, -1 do
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
