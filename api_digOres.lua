-- VALUES FOR THE DIRECTIONS
local up = "up"
local down = "down"
local forward = "forward"
local back  = "back"
local right = "right"
local left = "left"

-- LOAD FUNCTIONS FROM THE OTHER FILES
os.loadAPI("api_sharedFunctions")
os.loadAPI("api_turtleExt")

-- ------------------------------------------ --
-- START OF THE FUNCTIONS SPECIFIC TO digOres --
-- ------------------------------------------ --

-- EXCAVATES A SHAFT, DIGGING OUT ALL THE SPECIAL BLOCKS (ORES ETC)
function excavateShaft(configuration, dir)
  local squaresMoved=0
  for i=1,configuration.centerRadius+api_sharedFunctions.calculateMoves(configuration, configuration.currentL, 0, configuration.currentS) do
    if api_sharedFunctions.needsRestocking(configuration) then
      api_turtleExt.turnTo(back)
      exitShaftAndRestock(configuration, dir, squaresMoved)
    end
    if api_turtleExt.digAndMove(forward)==0 then
      api_sharedFunctions.reportObstruction(configuration, dir)
      break
    end
    squaresMoved = squaresMoved + 1
    checkSides(configuration, up) 
  end
  api_turtleExt.digAndMove(down, 1, 0)
  api_turtleExt.turnTo(back)
  checkSides(configuration, down)
  for i=1,squaresMoved do
    if configuration.placeTorches and (squaresMoved%6==5) then
      api_turtleExt.place(up, 1)
    end
    if api_sharedFunctions.needsRestocking(configuration) then
      api_turtleExt.digAndMove(up, 1, 0)
      exitShaftAndRestock(configuration, dir, squaresMoved)
      api_turtleExt.turnTo(back)
      api_turtleExt.digAndMove(down, 1, 0)
    end
    if api_turtleExt.digAndMove(forward)==0 then
      api_sharedFunctions.reportObstruction(configuration, dir)
      break
    end
    squaresMoved = squaresMoved - 1
    checkSides(configuration, down) 
  end
  api_turtleExt.digAndMove(up, 1, 0)
  api_turtleExt.digAndMove(forward, squaresMoved, 0)
end

-- CHECKS IF THE BLOCKS AT THE LEFT OR RIGHT ARE SPECIAL (AND THE TOP OR BOTTOM, DEPENDING ON THE INPUT) 
-- IF SO IT WILL DIG OUT THAT BLOCK AND EXCAVATE THE REST OF THE VEIN
function checkSides(configuration, vDir)
  check(configuration, vDir)
  check(configuration, left)
  check(configuration, right)
end

-- DROPS THE ITEMS IN THE INVENTORY AND REFUELS THE TURTLE
function exitShaftAndRestock(configuration, dir, squaresMoved)
  api_turtleExt.digAndMove(forward, squaresMoved, 0)
  api_turtleExt.turnTo(dir)
  api_sharedFunctions.dropoffAndRestock(configuration, configuration.numIgnoreBlocks, false, false, false)
  api_turtleExt.turnTo(dir)
  api_turtleExt.digAndMove(forward, squaresMoved, 0)
end

-- CHECKS IF A BLOCK IN A CERTAIN DIRECTION IS SPECIAL
-- IF SO IT WILL DIG OUT THAT BLOCK AND EXCAVATE THE REST OF THE VEIN
function check(configuration, dir)
  api_turtleExt.turnTo(dir)
  local tDir=api_turtleExt.turnedDir(dir)
  if api_turtleExt.detect(tDir) then
    if isSpecial(configuration, tDir) then
      if api_turtleExt.digAndMove(tDir) == 1 then
        configuration.numOres=configuration.numOres+1
        excavate(configuration)
        api_turtleExt.digAndMove(api_turtleExt.reverseDir(tDir), 1, 0)
      end
    end
  end
  api_turtleExt.turnFrom(dir)
end

-- CHECKS IF A BLOCK IN A CERTAIN DIRECTION IS SPECIAL (NOT ONE OF THE REFERENCE COMPONENTS (DIRT ETC))
function isSpecial(configuration, dir)
  api_turtleExt.turnTo(dir)
  local tDir=api_turtleExt.turnedDir(dir)
  local torchSlot=0
  if configuration.placeTorches then
    torchSlot=1
  end
  if not api_turtleExt.detect(tDir) then
    return false
  end
  for i=1, configuration.numIgnoreBlocks+torchSlot do
    if api_turtleExt.compare(tDir, i) then
      api_turtleExt.turnFrom(dir)
      return false
    end
  end
  api_turtleExt.turnFrom(dir)
  return true
end

-- EXCAVATES AN ORE VEIN
function excavate(configuration)
  local numSteps = 0
  local steps = {}
  repeat
    steps[numSteps] = steps[numSteps] or 0
    steps[numSteps] = lookForOres(configuration, steps[numSteps])  
    if steps[numSteps] ~= 7 then
      if ((numSteps==0) or (steps[numSteps]~=api_turtleExt.reverseIntDir(steps[numSteps-1]))) then
        if api_turtleExt.digAndMove(api_turtleExt.turnedDir(api_turtleExt.intToDir(steps[numSteps]))) == 1 then
          configuration.numOres=configuration.numOres+1
          numSteps = numSteps + 1
        end
      end
    else
      steps[numSteps] = 0
      numSteps = numSteps - 1
      if numSteps >= 0 then
        api_turtleExt.digAndMove(api_turtleExt.reverseDir(api_turtleExt.turnedDir(api_turtleExt.intToDir(steps[numSteps]))), 1, 0)
      end
    end
  until numSteps < 0
end

-- LOOKS AROUND THE CURRENT POSITION, LOOKING FOR ORES
function lookForOres(configuration, dir)
  if dir < 1 then
    dir = dir + 1
    if isSpecial(configuration, up) then
      return 1
    end
  end
  if dir < 2 then
    dir = dir + 1
    if isSpecial(configuration, down) then
      return 2
    end
  end
  if dir > 2 then
    api_turtleExt.turnTo(left)
  end
  for dir=dir+1, 6 do
    if isSpecial(configuration, forward) then
      return dir
    end
    api_turtleExt.turnTo(left)
  end
  return 7
end

-- CHECKS IF THE USER PLACED ENOUGH BLOCKS IN THE INVENTORY
function enoughBlocksProvided(configuration)
  local torchSlot=0
  if configuration.placeTorches then
    torchSlot=1
  end
  for i=1+torchSlot,configuration.numIgnoreBlocks+torchSlot do
    if turtle.getItemCount(i)==0 then
      return false
    end
  end
  return true
end

-- ---------------------------------------- --
-- END OF THE FUNCTIONS SPECIFIC TO digOres --
-- ---------------------------------------- --