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

-- -------------------------------------------- --
-- START OF THE FUNCTIONS SPECIFIC TO digShafts --
-- -------------------------------------------- --

-- DIGS A SINGLE SHAFT, THE PARAMETERS WILL DETERMINE THE LENGTH OF THE SHAFT
function digShaft(configuration, dir)
  local squaresMoved=0
  for i=1,configuration.centerRadius+api_sharedFunctions.calculateMoves(configuration, configuration.currentL, 0, configuration.currentS) do
    if configuration.placeTorches and (i % 6==5) then
      api_turtleExt.place(down, 1)
    end
    if api_turtleExt.digAndMove(forward)==0 then
      api_sharedFunctions.reportObstruction(configuration, dir)
      break
    end
    squaresMoved = squaresMoved + 1
    api_turtleExt.dig(down)
  end
  api_turtleExt.turnTo(back)
  api_turtleExt.digAndMove(forward, squaresMoved, 0)
end

-- ------------------------------------------ --
-- END OF THE FUNCTIONS SPECIFIC TO digShafts --
-- ------------------------------------------ --