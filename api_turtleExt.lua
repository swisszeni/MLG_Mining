-- VALUES FOR THE DIRECTIONS
local up = "up"
local down = "down"
local forward = "forward"
local back  = "back"
local right = "right"
local left = "left"

-- --------------------------------------------------------------- --
-- START OF FUNCTIONS EXTENDING THE FUNCTIONALITY OF THE BASIC API --
-- --------------------------------------------------------------- --

-- ALIGNS THE TURTLE TO MOVE, DIG, ... IN A CERTAIN DIRECTION
function turnTo(dir)
  if dir==back then
    turtle.turnLeft()
    turtle.turnLeft()
  elseif dir==right then
    turtle.turnRight()
  elseif dir==left then
    turtle.turnLeft()
  end
end

-- REALIGNS THE TURTLE TO THE ORIGINAL DIRECTION
function turnFrom(dir)
  if dir==back then
    turtle.turnLeft()
    turtle.turnLeft()
  elseif dir==right then
    turtle.turnLeft()
  elseif dir==left then
    turtle.turnRight()
  end
end

-- RETURNS THE DIRECTION THE TURTLE SHOULD MOVE, DIG, ... AFTER THE PREVIOUS ALIGNMENT
function turnedDir(dir)
  if dir==right or dir==left or dir==back then
    return forward
  else
    return dir
  end
end

-- RETURNS THE REVERSE DIRECTION SO UP BECOMES DOWN ETC
function reverseDir(dir)
  if dir==forward then
    return back
  elseif dir==back then
    return forward
  elseif dir==up then
    return down
  elseif dir==down then
    return up
  elseif dir==right then
    return left
  elseif dir==left then
    return right
  end
end

-- RETURNS THE DIRECTION USED BY THE PERIPHERAL FUNCTIONS
function peripheralDir(dir)
  if dir==forward then
    return "front"
  elseif dir==up then
    return "top"
  elseif dir==down then
    return "bottom"
  end
end

-- CONVERTS AN INTEGER TO A DIRECTION
function intToDir(dir)
  if dir == 1 then
    return up
  elseif dir == 2 then
    return down
  elseif dir == 3 then
    return forward
  elseif dir == 4 then
    return left
  elseif dir == 5 then
    return back
  elseif dir == 6 then
    return right
  end 
end

-- RETURNS THE REVERSE DIRECTION SO UP BECOMES DOWN ETC
function reverseIntDir(dir)
  if dir==1 then
    return 2
  elseif dir==2 then
    return 1
  elseif dir==3 then
    return 5
  elseif dir==4 then
    return 6
  elseif dir==5 then
    return 3
  elseif dir==6 then
    return 4
  end
end

-- MOVES THE TURTLE A CERTAIN DISTANCE IN A CERTAIN DIRECTION
-- IF NO DISTANCE IS SPECIFIED IT WILL JUST MOVE 1 STEP
function move(dir, steps, attempts)
  steps = steps or 1
  attempts = attempts or 10
  local stepsTaken = 0
  turnTo(dir)
  local tDir=turnedDir(dir)
  for i=1,steps do
    local tries=1
    local success=false
    while (((attempts==0) or (tries<=attempts))) do
      if tDir==forward then
        success=turtle.forward()
      elseif tDir==up then
        success=turtle.up()
      elseif tDir==down then
        success=turtle.down()
      end
      if success then
        break
      end
      attack(tDir)
      -- THIS CONSTRUCTION IS USED SO TRIES WON'T OVERFLOW WHEN ATTEMPTS==0
      tries = math.min(tries+1, attempts+1)
      sleep(0.5)
    end
    if success then
      stepsTaken=stepsTaken+1
    else
      break
    end
  end
  turnFrom(dir)
  return stepsTaken
end

-- DIGS IN A CERTAIN DIRECTION
function dig(dir, attempts)
  attempts = attempts or 10
  turtle.select(1)
  turnTo(dir)
  local tDir=turnedDir(dir)
  local tries=1
  local success=false
  while ((detect(tDir)) and ((attempts==0) or (tries<=attempts))) do
    if not (peripheral.getType(peripheralDir(tDir))=="turtle") then
      if tDir==forward then
        success=turtle.dig()
      elseif tDir==up then
        success=turtle.digUp()
      elseif tDir==down then
        success=turtle.digDown()
      end
    end
    -- THIS CONSTRUCTION IS USED SO TRIES WON'T OVERFLOW WHEN ATTEMPTS==0
    tries = math.min(tries+1, attempts+1)
    -- THE RANDOM FUNCTION IS USED SO THE TURTLE WON'T GET STUCK ON COBBLESTONE GENERATORS
    sleep(0.4+(math.random()/10))
  end
  turnFrom(dir)
  return success
end

-- DIGS AND MOVES A CERTAIN DISTANCE IN A CERTAIN DIRECTION
-- IF NO DISTANCE IS SPECIFIED IT WILL JUST MOVE 1 STEP
function digAndMove(dir, steps, attempts)
  steps = steps or 1
  attempts = attempts or 10
  local stepsTaken = 0
  turnTo(dir)
  local tDir=turnedDir(dir)
  for i=1,steps do
    local tries=1
    local success=false
    while (((attempts==0) or (tries<=attempts))) do
      dig(tDir, 1)
      success = (move(tDir, 1, 1)==1)
      if success then
        break
      end
      -- THIS CONSTRUCTION IS USED SO TRIES WON'T OVERFLOW WHEN ATTEMPTS==0
      tries = math.min(tries+1, attempts+1)
      sleep(0)
    end
    if success then
      stepsTaken=stepsTaken+1
    else
      break
    end
  end
  turnFrom(dir)
  return stepsTaken
end

-- ATTACKS IN A CERTAIN DIRECTION
function attack(dir)
  turnTo(dir)
  local tDir=turnedDir(dir)
  local attack
  if dir==up then
    attack=turtle.attackUp()
  elseif dir==down then
    attack=turtle.attackDown()
  else
    attack=turtle.attack()
  end 
  local success
  while attack() do
    success=true
    sleep(0.3)
  end
  turnFrom(dir)
  return success
end

-- PLACES A BLOCK FROM A CERTAIN SLOT IN A CERTAIN DIRECTION
function place(dir, slot)
  turtle.select(slot)
  turnTo(dir)
  local tDir=turnedDir(dir)
  local success
  if tDir==forward then
    success=turtle.place()
  elseif tDir==up then
    success=turtle.placeUp()
  elseif tDir==down then
    success=turtle.placeDown()
  end
  turnFrom(dir)
  return success
end

-- DETECTS IF THERE IS A BLOCK IN A CERTAIN DIRECTION
function detect(dir)
  local block = false
  turnTo(dir)
  local tDir=turnedDir(dir)
  if tDir==forward then
    block = turtle.detect()
  elseif tDir==up then
    block = turtle.detectUp()
  elseif tDir==down then
    block = turtle.detectDown()
  end
  turnFrom(dir)
  return block
end

-- COMPARES A BLOCK IN A CERTAIN DIRECTION TO THE BLOCK IN A CERTAIN INVENTORY SLOT
function compare(dir, slot)
  local same = false
  turtle.select(slot)
  turnTo(dir)
  local tDir=turnedDir(dir)
  if tDir==forward then
    same = turtle.compare()
  elseif tDir==up then
    same = turtle.compareUp()
  elseif tDir==down then
    same = turtle.compareDown()
  end
  turnFrom(dir)
  return same
end

-- COMPARES A BLOCK IN A CERTAIN DIRECTION TO A CERTAIN INVENTORY SLOT
-- IF IT MATCHES THE BLOCK WILL BE REPLACED BY A BLOCK IN THE SPECIFIED SLOT
function compareAndReplace(dir, compareSlot, replaceSlot)
  local replaced = false
  turnTo(dir)
  local tDir=turnedDir(dir)
  if not compare(tDir, compareSlot) then
    replaced = true
    dig(tDir)
    place(tDir, replaceSlot)  
  end
  turnFrom(dir)
  return replaced
end

-- DROPS A CERTAIN NUMBER OF ITEMS IN A CERTAIN DIRECTION
-- IF NO NUMBER IS SPECIFIED IT WILL DROP ALL THE ITEMS
function drop(dir, num)
  turnTo(dir)
  local tDir=turnedDir(dir)
  local success
  if num == null then
    if tDir==forward then
      success=turtle.drop()
    elseif tDir==up then
      success=turtle.dropUp()
    elseif tDir==down then
      success=turtle.dropDown()
    end
  else
    if tDir==forward then
      success=turtle.drop(num)
    elseif tDir==up then
      success=turtle.dropUp(num)
    elseif tDir==down then
      success=turtle.dropDown(num)
    end
  end
  turnFrom(dir)
  return success
end

-- SUCKS UP ITEMS FROM A CERTAIN DIRECTION
function suck(dir)
  turnTo(dir)
  local tDir=turnedDir(dir)
  local success
  if tDir==forward then
    success=turtle.suck()
  elseif tDir==up then
    success=turtle.suckUp()
  elseif tDir==down then
    success=turtle.suckDown()
  end
  turnFrom(dir)
  return success
end

-- REFUELS THE TURTLE, PARAMETERS DENOTE IN WHICH DIRECTION THE FUEL ITEMS WILL BE, WHERE TO DROP ANY 
-- LEFTOVERS (BUCKETS) IN WHICH INVENTORY SPOT THE FUEL WILL BE AND HOW MUCH FUEL NEEDS TO BE STORED
function refuel(suckDir, dropDir, fuelSlot, requiredFuel)
  turtle.select(fuelSlot)
  local dispMsg=true
  while turtle.getFuelLevel() < requiredFuel do
    suck(suckDir)
    local success = turtle.refuel()
    if not success then
      if dispMsg then
        term.clear()
        term.setCursorPos(1,1)
        print("---------------------------------")
        print("Please place some fuel in a chest")
        print("Chest Direction: "..suckDir)
        print("Fuel required:   "..(requiredFuel-turtle.getFuelLevel()))
        print("---------------------------------")
        dispMsg=false
      end
      sleep(1)
    else
      dispMsg=true
    end
    drop(dropDir)
    sleep(0)
  end
  turtle.select(1)
  term.clear()
end

-- ------------------------------------------------------------- --
-- END OF FUNCTIONS EXTENDING THE FUNCTIONALITY OF THE BASIC API --
-- ----------------------------------------