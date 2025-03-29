-- Player class
local player = {
  maxHp = 100,
  currentHp = 100,
  x = 400,
  y = 300,
  speed = 200,
  image = nil,
  direction = "idle",
  scale = 3,
  attackRange = 50
}

-- Loads settings, sprites, etc
function love.load()
  love.window.setTitle("Odlaw's Quest 2")
  love.graphics.setBackgroundColor( 0, .4, .6, .2 )

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
    player.image = player.imageUp
  elseif love.keyboard.isDown('s') then
    moveY = 1
    player.direction = 'down'
    player.image = player.imageDown
  end

  if love.keyboard.isDown('a') then
    moveX = -1
    player.direction = 'left'
    player.image = player.imageLeft
  elseif love.keyboard.isDown('d') then
    moveX = 1
    player.direction = 'right'
    player.image = player.imageRight
  end

  if not (love.keyboard.isDown('w') or love.keyboard.isDown('a') or love.keyboard.isDown('s') or love.keyboard.isDown('d')) then
    player.direction = 'idle'
    player.image = player.imageIdle
  end

  player.x = player.x + moveX * player.speed * dt
  player.y = player.y + moveY * player.speed * dt

  function love.keypressed(k)
    if k == 'escape' then
       love.event.quit()
    end
 end
end

-- Draws everything as needed
function love.draw()
  -- Draws the player, position x, position y, 0 rotation, player scaleX, player scaleY)
  love.graphics.draw(player.image, player.x, player.y, 0, player.scale, player.scale)

  -- Melee attack hitbox drawing for testing sizes
  if love.keyboard.isDown('up') then
    love.graphics.rectangle("fill", player.x + 32, player.y - 23, 36, player.attackRange)
  elseif love.keyboard.isDown('down') then
    love.graphics.rectangle("fill", player.x + 32, player.y + 68, 36, player.attackRange)
  elseif love.keyboard.isDown('left') then
    love.graphics.rectangle("fill", player.x - 20, player.y + 28, player.attackRange, 36)
  elseif love.keyboard.isDown('right') then
    love.graphics.rectangle("fill", player.x + 70, player.y + 28, player.attackRange, 36)
  end

  -- Draws the UI element for player HP
  love.graphics.print("HP: " .. player.currentHp .. " / " .. player.maxHp, 5, 5)
end