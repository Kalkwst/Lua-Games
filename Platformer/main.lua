function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource('audio/jump.wav', "static")
    sounds.music = love.audio.newSource('audio/music.mp3', "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.3)

    sounds.music:play()


    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.03)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.03)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.03)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.02)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Player')
    world:addCollisionClass('Platform')
    world:addCollisionClass('Danger')

    require('player')
    require('enemy')
    require('libraries/show')

    -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, {
    --     collision_class = "Danger"
    -- })
    -- dangerZone:setType("static")

    platforms = {}

    flagX = 0
    flagY = 0

    saveData = {}
    saveData.currentLevel = "level1"

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    loadMap(saveData.currentLevel)

    --spawnEnemy(790, 320)
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
    cam:lookAt(px, love.graphics.getHeight() / 2)

    player.animation:update(dt)
    updateEnemies(dt)

    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
    if #colliders > 0 then
        if saveData.currentLevel == "level1" then
            loadMap("level2")
        elseif saveData.currentLevel == "level2" then
            loadMap("level1")
        end
    end
end

function love.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    if (key == 'space' or key == 'up') and player.body and player.isGrounded then
        player:applyLinearImpulse(0, -4000)
        sounds.jump:play()
    end

    if key == 'r' then
        loadMap("level2")
    end
end

function nuke()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end

function loadMap(mapName)
    saveData.currentLevel = mapName
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))

    nuke()
    player:setPosition(300, 100)
    gameMap = sti("maps/" .. mapName ..".lua")

    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end

function spawnPlatform(x, y, w, h)
    if w > 0 and h > 0 then
        local platform = world:newRectangleCollider(x, y, w, h, {
            collision_class = "Platform"
        })
        platform:setType("static")
        table.insert(platforms, platform)
    end
end
