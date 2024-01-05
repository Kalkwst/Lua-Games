function love.load()
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    player = world:newRectangleCollider(360, 100, 80, 80, {
        collision_class = "Player"
    })
    player:setFixedRotation(true)
    player.speed = 240

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
        handlePlayerMovement(dt)
    end

    handleDangerCollisions(dt)
end

function love.draw()
    world:draw()
end

function handlePlayerMovement(dt)
    local px, py = player:getPosition()

    if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
        player:setX(px + player.speed * dt)
    end

    if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
        player:setX(px - player.speed * dt)
    end
end

function handleDangerCollisions(dt)
    if player:enter('Danger') then
        player:destroy()
    end
end

function love.keypressed(key)
    if (key == 'space' or key == 'up') and player.body then
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'Platform'})

        if #colliders > 0 then
            player:applyLinearImpulse(0, -7000)
        end
        
    end
end
