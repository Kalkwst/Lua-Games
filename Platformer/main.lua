function love.load()
    anim8 = require 'libraries/anim8/anim8'

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.03)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.03)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.03)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    player = world:newRectangleCollider(360, 100, 40, 100, {
        collision_class = "Player"
    })
    player:setFixedRotation(true)
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.isGrounded = true
    player.direction = 1

    platform = world:newRectangleCollider(250, 400, 300, 100, {
        collision_class = "Platform"
    })
    platform:setType("static")

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {
        collision_class = "Danger"
    })
    dangerZone:setType("static")
end

function love.update(dt)
    world:update(dt)
    if player.body then

        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 80, 2, {'Platform'})

        if #colliders > 0 then
            player.isGrounded = true
        else
            player.isGrounded = false
        end

        player.isMoving = false
        handlePlayerMovement(dt)
    end

    handlePlayerAnimations()
    handleDangerCollisions(dt)

    player.animation:update(dt)
end

function love.draw()
    world:draw()

    if player.body then
        local px, py = player:getPosition()
        player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
    end

end

function handlePlayerMovement(dt)
    local px, py = player:getPosition()

    if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
        player:setX(px + player.speed * dt)
        player.isMoving = true
        player.direction = 1
    end

    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
        player:setX(px - player.speed * dt)
        player.isMoving = true
        player.direction = -1
    end
end

function handleDangerCollisions(dt)
    if player:enter('Danger') then
        player:destroy()
    end
end

function handlePlayerAnimations()
    if player.isMoving and player.isGrounded then
        player.animation = animations.run
    elseif player.isGrounded and player.isMoving == false then
        player.animation = animations.idle
    else
        player.animation = animations.jump
    end
end

function love.keypressed(key)
    if (key == 'space' or key == 'up') and player.body and player.isGrounded then
        player:applyLinearImpulse(0, -4000)
    end
end

