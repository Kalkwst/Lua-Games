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

    require('player')

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
    drawPlayer()
end

function love.keypressed(key)
    if (key == 'space' or key == 'up') and player.body and player.isGrounded then
        player:applyLinearImpulse(0, -4000)
    end
end

