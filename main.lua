-- Player class
local player = {
  score = 0,
  health = 100,
  x = 0,
  y = 0,
  prevX = 0,
  prevY = 0,
  width = 39,
  height = 39,
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

-- Displays and clears messages after a 2 second timer
local message = ''
local messageTimer = 2
local timeSinceLastMessage = 0

function displayMessage(msg)
  message = msg
  timeSinceLastMessage = 0
end

function clearMessage(delta)
  timeSinceLastMessage = timeSinceLastMessage + delta
  if timeSinceLastMessage >= messageTimer then
    message = ''
  end
end
--

-- enemy spawning variables
local enemies = {}
local spawnTimer = 0
local spawnInterval = 3

-- Bounding collision check
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  -- return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
  local margin = 10
  local ax1 = x1
  local ax2 = x1 + w1
  local bx1 = x2
  local bx2 = x2 + h2
  local xCollide = ax1 <= bx2 and ax2 >= bx1
  local yCollide = math.floor(y1) < math.floor(y2 + h2) and math.floor(y1 + h1) > math.floor(y2)

  if (player.x > 100 or player.x < 100) then
    print("X-Range:", math.floor(x1), math.floor(x2 + w2), "| Attack Box:", math.floor(x2), math.floor(x1 + w1), "| X-Collision:", xCollide)
    print("Y-Range:", math.floor(y1), math.floor(y2 + h2), "| Attack Box:", math.floor(y2), math.floor(y1 + h1), "| Y-Collision:", yCollide)
  end

  return xCollide and yCollide
end

function round(num, numDecimals)
  local mult = 10^(numDecimals or 0)
  return math.floor(num * mult + .5) / mult
end

-- Moves the player
function updatePlayer(dt)
  local moveX, moveY = 0, 0

  player.prevX = player.x
  player.prevY = player.y
    
  if love.keyboard.isDown('w') then
    moveY = -1
    player.direction = 'up'
    player.image = player.imageUp
    print("Player Y:", player.y)
  elseif love.keyboard.isDown('s') then
    moveY = 1
    player.direction = 'down'
    player.image = player.imageDown
    print("Player Y:", player.y)
  end

  if love.keyboard.isDown('a') then
    moveX = -1
    player.direction = 'left'
    player.image = player.imageLeft
    print("Player X:", player.x)
  elseif love.keyboard.isDown('d') then
    moveX = 1
    player.direction = 'right'
    player.image = player.imageRight
    print("Player X:", player.x)
  end

  if not (love.keyboard.isDown('w') or love.keyboard.isDown('a') or love.keyboard.isDown('s') or love.keyboard.isDown('d')) then
    player.direction = 'idle'
    player.image = player.imageIdle
  end

  player.x = player.x + moveX * player.speed * dt
  player.y = player.y + moveY * player.speed * dt

  -- Update player attack timer
  player.timeSinceLastAttack = player.timeSinceLastAttack + dt

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
      hitX = player.x
      hitY = player.y - player.height - 10
      hitW = 39
      hitH = player.attackRange
    elseif love.keyboard.isDown('down') then
      player.direction = "down"
      hitX = player.x
      hitY = player.y + player.height
      hitW = 39
      hitH = player.attackRange
    elseif love.keyboard.isDown('left') then
      player.direction = "left"
      hitX = player.x  - player.width - 10
      hitY = player.y
      hitW = player.attackRange
      hitH = 39
    elseif love.keyboard.isDown('right') then
      player.direction = "right"
      hitX = player.x + player.width
      hitY = player.y
      hitW = player.attackRange
      hitH = 39
    end

    for i, enemy in ipairs(enemies) do
      if enemy.isAlive and checkCollision(hitX, hitY, hitW, hitH, enemy.x, enemy.y, enemy.width, enemy.height) then
        enemy.isAlive = false
        displayMessage("Enemy " .. enemy.name ..  " killed!")
        table.remove(enemies, i)
        player.score = player.score + 1
      end
    end
  end
  --
end

function updateEnemy(dt)
  -- Enemy spawning
  spawnTimer = spawnTimer - dt
  if spawnTimer <= 0 then
    spawnTimer = spawnInterval
    -- Enemy class
    local enemy = {
      maxHP = 10,
      currentHP = 10,
      x = love.math.random(player.x - 000, player.x + 400),
      y = love.math.random(player.y - 800, player.y + 400),
      image = love.graphics.newImage("assets/greenskin.png"),
      width = 30,
      height = 32,
      isAlive = true,
      speed = love.math.random(30, 60),
      name = "greenskin",
      attackCooldown = 1.5,
      lastAttackTime = 0,
      attackRange = 30,
      isAttacking = false,
      attackTimer = 0
    }
    table.insert(enemies, enemy)
  end

  -- Handles all enemy actions
  for i, enemy in ipairs(enemies) do
    -- Enemy movement
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    local distance = math.sqrt(dx * dx + dy * dy)
  
    if distance > 30 then
      local randomFactor = love.math.random(-20, 20)
      enemy.x = enemy.x + ((dx + randomFactor) / distance) * enemy.speed * dt
      enemy.y = enemy.y + ((dy + randomFactor) / distance) * enemy.speed * dt
    end
    --

    -- Enemy attack handler
    local attackRange = enemy.attackRange
    enemy.lastAttackTime = enemy.lastAttackTime - dt
    if distance < attackRange and enemy.lastAttackTime <= 0 then
      enemyAttack(enemy)
      enemy.lastAttackTime = enemy.attackCooldown
    end
    -- Enemy attack animation handler
    if enemy.isAttacking then
      enemy.attackTimer = enemy.attackTimer - dt
      if enemy.attackTimer <= 0 then
        enemy.isAttacking = false
      end
    end
  end

  function enemyAttack(e)
    print("Enemy attacking!")
    local attackBox = {
      x = e.x - 10, y = e.y - 10, width = e.width + 20, height = e.height + 20
    }

    e.isAttacking = true
    e.attackTimer = .2

    if checkCollision(round(attackBox.y, 2), round(attackBox.y, 2), round(attackBox.width, 2), round(attackBox.height, 2), round(player.prevX, 2), round(player.prevY, 2), round(player.width, 2), round(player.height, 2)) then
      player.health = player.health - 10
      displayMessage("You were hit for 10 damage!")
      print("Player hit! Health: ", player. health)
    else
      print("Enemy attack missed!")
    end
  end
end

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
  updatePlayer(dt)
  updateEnemy(dt)

  -- Runs clear message function
  clearMessage(dt)

  -- exits the game if you press Esc
  if love.keyboard.isDown('escape') or player.health <= 0 then
    love.event.quit()
  end
end

-- Draws everything as needed
function love.draw()
  -- Push, translate and pop allows for camera to lock to the player
  love.graphics.push()
  love.graphics.translate(-player.x - 20 + love.graphics.getWidth() / 2, -player.y - 20 + love.graphics.getHeight() / 2)

  -- Draws the player, position x, position y, 0 rotation, player scaleX, player scaleY)
  love.graphics.draw(player.image, player.x, player.y, 0, player.scale, player.scale)
  love.graphics.setColor(1, 1, 1, .5)
  love.graphics.rectangle("fill", player.x, player.y , player.width, player.height)
  love.graphics.setColor(1, 1, 1)

  -- draw enemies + their attack boxes
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

    if enemy.isAttacking then
      love.graphics.setColor(1, .5, .5, .5)
      love.graphics.rectangle("fill", enemy.x - 10, enemy.y - 10, enemy.width + 20, enemy.height + 20)
      love.graphics.setColor(1, 1, 1)
    end
  end

  if player.isAttacking then
    local hitX, hitY, hitW, hitH

    -- Melee attack hitbox drawing
    if player.direction == 'up' then
      hitX = player.x
      hitY = player.y - player.height - 10
      hitW = 39
      hitH = player.attackRange
    elseif player.direction == 'down' then
      hitX = player.x
      hitY = player.y + player.height
      hitW = 39
      hitH = player.attackRange
    elseif player.direction == 'left' then
      hitX = player.x - player.width - 10
      hitY = player.y
      hitW = player.attackRange
      hitH = 39
    elseif player.direction == "right" then
      hitX = player.x + player.width
      hitY = player.y
      hitW = player.attackRange
      hitH = 39
    end

    love.graphics.rectangle("fill", hitX, hitY, hitW, hitH)
  end
  love.graphics.pop()
  --

  -- Draws the UI element for player HP
  love.graphics.print("HP: " .. player.health, 5, 5)

  -- Draws the UI element for ingame messages
  love.graphics.print(message, 5, love.graphics.getHeight() - 20)

  -- Draws the UI element for player's score
  love.graphics.print("Score: " .. player.score, love.graphics.getWidth() / 2 - 30, 5)
end