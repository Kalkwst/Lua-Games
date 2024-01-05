player = world:newRectangleCollider(360, 100, 40, 100, {
    collision_class = "Player"
})
player:setFixedRotation(true)
player.speed = 240
player.animation = animations.idle
player.isMoving = false
player.isGrounded = true
player.direction = 1

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

function handlePlayerAnimations()
    if player.isMoving and player.isGrounded then
        player.animation = animations.run
    elseif player.isGrounded and player.isMoving == false then
        player.animation = animations.idle
    else
        player.animation = animations.jump
    end
end

function handleDangerCollisions(dt)
    if player:enter('Danger') then
        player:destroy()
    end
end

function drawPlayer()
    if player.body then
        local px, py = player:getPosition()
        player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
    end
end