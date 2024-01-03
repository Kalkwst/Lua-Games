function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2

end

function love.update(dt)
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    love.graphics.draw(sprites.player, player.x, player.y)
end