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

-- --------------------------------------------- --
-- START OF THE FUNCTIONS SPECIFIC TO digTunnels --
-- --------------------------------------------- --

-- DIGS A SEGMENT (FROM ONE SHAFT TO THE NEXT) DIGGING OUT THE SIDES ASWELL
function digSegmentAndSides(configuration, slices)
  local torchOffset=0
  if ((configuration.currentL % 2 == 0) and (configuration.currentS == 0)) then
    torchOffset=configuration.evenLevelOffset
  end
  api_turtleExt.digAndMove(forward, 1, 0)
  api_turtleExt.digAndMove(down, 1, 0)
  for i=1, slices do
    if i~=1 then
      api_turtleExt.digAndMove(forward, 1, 0)
    end
    api_turtleExt.turnTo(left)
    api_turtleExt.dig(up)
    api_turtleExt.dig(down)
    api_turtleExt.digAndMove(forward, 1, 0)
    api_turtleExt.dig(down)
    api_turtleExt.dig(forward)
    api_turtleExt.digAndMove(up, 1, 0)
    api_turtleExt.dig(forward)
    if configuration.placeTorches and ((i+torchOffset) % (configuration.blocksBetweenShafts+1) == math.floor((configuration.blocksBetweenShafts+1)/2)) then
      api_turtleExt.place(forward, 1)
    end
    if configuration.height == 3 then
      api_turtleExt.digAndMove(up, 1, 0)
      api_turtleExt.dig(forward)
    end
    api_turtleExt.dig(up)
    api_turtleExt.turnTo(back)
    api_turtleExt.digAndMove(forward, 1, 0)
    api_turtleExt.dig(up)
    api_turtleExt.digAndMove(forward, 1, 0)
    api_turtleExt.dig(up)
    api_turtleExt.dig(forward)
    if configuration.height == 3 then
      api_turtleExt.digAndMove(down, 1, 0)
      api_turtleExt.dig(forward)
    end
    api_turtleExt.digAndMove(down, 1, 0)
    api_turtleExt.dig(forward)
    api_turtleExt.dig(down)
    if configuration.placeTorches and ((i+torchOffset) % (configuration.blocksBetweenShafts+1) == (configuration.blocksBetweenShafts+1)/2) then
      api_turtleExt.digAndMove(up, 1, 0)
      api_turtleExt.place(forward, 1)
      api_turtleExt.digAndMove(down, 1, 0)
    end
    api_turtleExt.turnTo(back)
    api_turtleExt.digAndMove(forward, 1, 0)
    api_turtleExt.turnTo(right)
  end
  api_turtleExt.digAndMove(up, 1, 0)
  configuration.currentS = configuration.currentS + 1
end

-- DIGS A SEGMENT (FROM ONE SHAFT TO THE NEXT) LEAVING THE SIDES INTACT
function digSegmentNoSides(configuration, slices)
  api_turtleExt.digAndMove(forward, 1, 0)
  api_turtleExt.digAndMove(left, 1, 0)
  local dir = right
  for i=1, slices do
    if i~=1 then
      api_turtleExt.digAndMove(forward, 1, 0)
    end
    api_turtleExt.turnTo(dir)
    if configuration.height == 3 then
      api_turtleExt.dig(up)
    end
    api_turtleExt.dig(down)
    api_turtleExt.digAndMove(forward, 1, 0)
    if configuration.height == 3 then
      api_turtleExt.dig(up)
    end
    api_turtleExt.dig(down)
    api_turtleExt.digAndMove(forward, 1, 0)
    if configuration.height == 3 then
      api_turtleExt.dig(up)
    end
    api_turtleExt.dig(down)
    api_turtleExt.turnFrom(dir)
    dir=api_turtleExt.reverseDir(dir)
  end
  api_turtleExt.turnTo(dir)
  api_turtleExt.digAndMove(forward, 1, 0)
  api_turtleExt.turnFrom(dir)
  configuration.currentS = configuration.currentS + 1
  if configuration.placeTorches then
    api_turtleExt.place(down, 1)
  end
end

-- DIGS A SEGMENT (FROM ONE SHAFT TO THE NEXT)
function digSegment(configuration)
  local slices = api_sharedFunctions.calculateMoves(configuration, configuration.currentL, configuration.currentS, configuration.currentS+1)
  if slices == 0 then
    return
  end
  if configuration.digSidesToo then
    digSegmentAndSides(configuration, slices)
  else
    digSegmentNoSides(configuration, slices)
  end
end

-- ------------------------------------------- --
-- END OF THE FUNCTIONS SPECIFIC TO digTunnels --
-- ------------------------------------------- --