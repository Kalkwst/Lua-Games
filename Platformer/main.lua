function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

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

    -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, {
    --     collision_class = "Danger"
    -- })
    -- dangerZone:setType("static")

    platforms = {}


    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)

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

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight()/2)

    player.animation:update(dt)
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
    cam:detach()
end

function love.keypressed(key)
    if (key == 'space' or key == 'up') and player.body and player.isGrounded then
        player:applyLinearImpulse(0, -4000)
    end
end

function loadMap()
    gameMap = sti('maps/level1.lua')

    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end

function spawnPlatform(x, y, w, h)
    if w > 0 and h > 0 then
        local platform = world:newRectangleCollider(x, y, w, h, {
            collision_class = "Platform"
        })
        platform:setType("static")
    end

    table.insert(platforms, platform)
end