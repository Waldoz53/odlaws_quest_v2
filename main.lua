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
  attackRange = 50,
  attackDamage = 10,
  isAttacking = false,
  attackCooldown = 1.00,
  timeSinceLastAttack = 0
}

-- Enemy class
local enemy = {
  maxHP = 10,
  currentHP = 10,
  x = 600,
  y = 200,
  image = nil,
  width = 40,
  height = 40,
  isAlive = true
}

-- A message "log"
local message = ''

-- Loads settings, sprites, etc
function love.load()
  love.window.setTitle("Odlaw's Quest 2")
  love.graphics.setBackgroundColor( 0, .4, .6, .2 )

  player.imageDown = love.graphics.newImage("assets/odlaw_sprite/odlaw_down.png")
  player.imageUp = love.graphics.newImage("assets/odlaw_sprite/odlaw_up.png")
  player.imageLeft = love.graphics.newImage("assets/odlaw_sprite/odlaw_left.png")
  player.imageRight = love.graphics.newImage("assets/odlaw_sprite/odlaw_right.png")
  player.imageIdle = love.graphics.newImage("assets/odlaw_sprite/odlaw_idle.png")
  player.image = player.imageIdle

  enemy.image = love.graphics.newImage("assets/greenskin.png")
end

-- Updates anything as needed
function love.update(dt)
  local moveX, moveY = 0, 0

  -- Update player attack timer
  player.timeSinceLastAttack = player.timeSinceLastAttack + dt

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

  -- handles attacks
  if player.timeSinceLastAttack >= player.attackCooldown then
    if love.keyboard.isDown('up') or love.keyboard.isDown('down') or love.keyboard.isDown('left') or love.keyboard.isDown('right') then
      player.isAttacking = true
      player.timeSinceLastAttack = 0
    end
  else 
    player.isAttacking = false
  end

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

  if player.isAttacking then
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
  end

  -- draw enemy
  love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 2, 2)

  -- Draws the UI element for player HP
  love.graphics.print("HP: " .. player.currentHp .. " / " .. player.maxHp, 5, 5)
  -- Draws the UI element for player score
  -- love.graphics.print(message, 700, 5)
end