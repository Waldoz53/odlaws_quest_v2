local player = {
  x = 400,
  y = 300,
  speed = 200,
  image = nil,
  direction = "none",
  scale = 3
}

-- Loads settings, sprites, etc
function love.load()
  love.window.setTitle("Odlaw's Quest v2")

  player.imageDown = love.graphics.newImage("odlaw_sprite/odlaw_down.png")
  player.imageUp = love.graphics.newImage("odlaw_sprite/odlaw_up.png")
  player.imageLeft = love.graphics.newImage("odlaw_sprite/odlaw_left.png")
  player.imageRight = love.graphics.newImage("odlaw_sprite/odlaw_right.png")
  player.imageIdle = love.graphics.newImage("odlaw_sprite/odlaw_idle.png")
  player.image = player.imageIdle
end

-- Updates anything as needed
function love.update(dt)
  local moveX, moveY = 0, 0

  if love.keyboard.isDown('w') then
    moveY = -1
    player.direction = 'up'
  elseif love.keyboard.isDown('s') then
    moveY = 1
    player.direction = 'down'
  elseif love.keyboard.isDown('a') then
    moveX = -1
    player.direction = 'left'
  elseif love.keyboard.isDown('d') then
    moveX = 1
    player.direction = 'right'
  else
    player.direction = 'idle'
  end

  player.x = player.x + moveX * player.speed * dt
  player.y = player.y + moveY * player.speed * dt

  if player.direction == 'up' then
    player.image = player.imageUp
  elseif player.direction == 'down' then
    player.image = player.imageDown
  elseif player.direction == 'left' then
    player.image = player.imageLeft
  elseif player.direction == 'right' then
    player.image = player.imageRight
  else 
    player.image = player.imageIdle
  end
end

-- Draws everything as needed
function love.draw()
  -- Draws the player, position x, position y, 0 rotation, player scaleX, player scaleY)
  love.graphics.draw(player.image, player.x, player.y, 0, player.scale, player.scale)
end