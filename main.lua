-- Player class
local player = {
  score = 0,
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
  timeSinceLastAttack = 0,
}

-- Enemy class
-- local enemy = {
--   maxHP = 10,
--   currentHP = 10,
--   x = love.math.random(player.x - 200, player.x + 200),
--   y = love.math.random(player.y - 200, player.y + 200),
--   image = nil,
--   width = 30,
--   height = 32,
--   isAlive = true,
--   speed = 50,
--   targetX = player.x,
--   targetY = player.y,
-- }

-- Displays and clears messages after a 2 second timer
local message = ''
local messageTimer = 2
local timeSinceLastMessage = 0

local function displayMessage(msg)
  message = msg
  timeSinceLastMessage = 0
end

local function clearMessage(delta)
  timeSinceLastMessage = timeSinceLastMessage + delta
  if timeSinceLastMessage >= messageTimer then
    message = ''
  end
end
--

-- Bounding collision check
local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

-- enemy spawning variables
local enemies = {}
local spawnTimer = 0
local spawnInterval = 3

-- Loads settings, sprites, etc
function love.load()
  love.window.setTitle("Odlaw's Quest 2")
  love.graphics.setBackgroundColor(0, .4, .6, .2)

  -- Loads player sprites
  player.imageDown = love.graphics.newImage("assets/odlaw_sprite/odlaw_down.png")
  player.imageUp = love.graphics.newImage("assets/odlaw_sprite/odlaw_up.png")
  player.imageLeft = love.graphics.newImage("assets/odlaw_sprite/odlaw_left.png")
  player.imageRight = love.graphics.newImage("assets/odlaw_sprite/odlaw_right.png")
  player.imageIdle = love.graphics.newImage("assets/odlaw_sprite/odlaw_idle.png")
  player.image = player.imageIdle
end

-- Updates anything as needed
function love.update(dt)
  local moveX, moveY = 0, 0

  -- Enemy spawning
  spawnTimer = spawnTimer - dt
  if spawnTimer <= 0 then
    spawnTimer = spawnInterval
    local enemy = {
      maxHP = 10,
      currentHP = 10,
      x = love.math.random(player.x - 400, player.x + 400),
      y = love.math.random(player.y - 400, player.y + 400),
      image = love.graphics.newImage("assets/greenskin.png"),
      width = 30,
      height = 32,
      isAlive = true,
      speed = love.math.random(30, 60),
      targetX = player.x + love.math.random(-30, 30),
      targetY = player.y + love.math.random(-30, 30),
    }
    table.insert(enemies, enemy)
  end

  for i, enemy in ipairs(enemies) do
    -- handles enemy movement
    if not enemy.targetX or not enemy.targetY or math.abs(enemy.x - enemy.targetX) < 40 and math.abs(enemy.y - enemy.targetY) < 40 then
      enemy.targetX = player.x + love.math.random(0, 40)
      enemy.targetY = player.y + love.math.random(0, 40)
    end
  
    local dx = enemy.targetX - enemy.x
    local dy = enemy.targetY - enemy.y
    local distance = math.sqrt(dx * dx + dy * dy)
  
    if distance > 0 then
      enemy.x = enemy.x + (dx / distance) * enemy.speed * dt
      enemy.y = enemy.y + (dy / distance) * enemy.speed * dt
    end
    --
  end

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
  --

  -- Moves the player
  player.x = player.x + moveX * player.speed * dt
  player.y = player.y + moveY * player.speed * dt
  --

  -- handles attacks
  if player.timeSinceLastAttack >= player.attackCooldown then
    if love.keyboard.isDown('up') or love.keyboard.isDown('down') or love.keyboard.isDown('left') or love.keyboard.isDown('right') then
      player.isAttacking = true
      player.timeSinceLastAttack = 0
    else
      player.isAttacking = false
    end
  else 
    player.isAttacking = false
  end
  --

  -- check for player attack collision with enemy
  if player.isAttacking then
    local hitX, hitY, hitW, hitH

    if love.keyboard.isDown('up') then
      player.direction = "up"
      hitX = player.x + 32
      hitY = player.y - 23
      hitW = 36
      hitH = player.attackRange
    elseif love.keyboard.isDown('down') then
      player.direction = "down"
      hitX = player.x + 32
      hitY = player.y + 68
      hitW = 36
      hitH = player.attackRange
    elseif love.keyboard.isDown('left') then
      player.direction = "left"
      hitX = player.x - 20
      hitY = player.y + 28
      hitW = player.attackRange
      hitH = 36
    elseif love.keyboard.isDown('right') then
      player.direction = "right"
      hitX = player.x + 70
      hitY = player.y + 28
      hitW = player.attackRange
      hitH = 36
    end

    for i, enemy in ipairs(enemies) do
      if enemy.isAlive and checkCollision(hitX, hitY, hitW, hitH, enemy.x, enemy.y, enemy.width, enemy.height) then
        enemy.isAlive = false
        displayMessage("Enemy hit!")
        table.remove(enemies, i)
        player.score = player.score + 1
      end
    end
  end
  --

  -- Runs clear message function
  clearMessage(dt)

  -- exits the game if you press Esc
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end
end

-- Draws everything as needed
function love.draw()
  -- Push, translate and pop allows for camera to lock to the player
  love.graphics.push()
  love.graphics.translate(-player.x - 40 + love.graphics.getWidth() / 2, -player.y - 40 + love.graphics.getHeight() / 2)

  -- Draws the player, position x, position y, 0 rotation, player scaleX, player scaleY)
  love.graphics.draw(player.image, player.x, player.y, 0, player.scale, player.scale)

  -- draw enemies
  for i, enemy in ipairs(enemies) do
    if enemy.isAlive then
      if enemy.image then
        love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 2, 2)
      else
        love.graphics.setColor(1, 0, 0, .5)
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
        love.graphics.setColor(1, 1, 1)
      end
    end
  end

  if player.isAttacking then
    local hitX, hitY, hitW, hitH

    -- Melee attack hitbox drawing
    if player.direction == 'up' then
      hitX = player.x + 32
      hitY = player.y - 23
      hitW = 36
      hitH = player.attackRange
    elseif player.direction == 'down' then
      hitX = player.x + 32
      hitY = player.y + 68
      hitW = 36
      hitH = player.attackRange
    elseif player.direction == 'left' then
      hitX = player.x - 20
      hitY = player.y + 28
      hitW = player.attackRange
      hitH = 36
    elseif player.direction == "right" then
      hitX = player.x + 70
      hitY = player.y + 28
      hitW = player.attackRange
      hitH = 36
    end

    love.graphics.rectangle("fill", hitX, hitY, hitW, hitH)
  end
  love.graphics.pop()
  --

  -- Draws the UI element for player HP
  love.graphics.print("HP: " .. player.currentHp .. " / " .. player.maxHp, 5, 5)

  -- Draws the UI element for ingame messages
  love.graphics.print(message, 5, love.graphics.getHeight() - 20)

  -- Draws the UI element for player's score
  love.graphics.print("Score: " .. player.score, love.graphics.getWidth() / 2 - 30, 5)
end