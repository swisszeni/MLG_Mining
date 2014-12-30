-- VALUES FOR THE DIRECTIONS
local up = "up"
local down = "down"
local forward = "forward"
local back  = "back"
local right = "right"
local left = "left"

-- ------------------------------------------------------------ --
-- START OF THE CODE THAT GETS EXECUTED WHEN THE PROGRAM STARTS --
-- ------------------------------------------------------------ --

-- LOAD FUNCTIONS FROM THE OTHER FILES
os.loadAPI("api_sharedFunctions")
os.loadAPI("api_turtleExt")
os.loadAPI("api_digTunnels")
os.loadAPI("api_digShafts")
os.loadAPI("api_digOres")

-- GET THE CONFIGURATION OF THE PROGRAM
local args={...}
local configuration = api_sharedFunctions.getConfig("config", args)
if configuration == nil then
  return
end

-- USED TO KEEP TRACK OF THE CURRENT POSITION
configuration.currentL = 1
configuration.currentT = 1
configuration.currentS = 0

-- USED TO KEEP TRACK OF THE NUMBER OF EXCAVATED ORES
configuration.numOres = 0

-- CHECK THE MINIMAL FUEL VALUE SPECIFIED BY THE USER
if (configuration.departureFuel < 400) then
  print("Warning: Low fuel value chosen")
  print("Do you wish to proceed? (Y/N)")
  local answer=io.read()
  if not (answer=="Y") then
    return
  end
end

-- CHECK THE NUMBER OF BLOCKS PROVIDED BY THE USER
api_sharedFunctions.dropoffAndRestock(configuration, configuration.numIgnoreBlocks, true, true, true)
if not api_digOres.enoughBlocksProvided(configuration) then
  term.clear()
  print("ERROR:")
  print("-------------------------------")
  print("You said you wanted to turtle")
  print("To ignore "..configuration.numIgnoreBlocks.." blocks but didn't")
  print("place them all in the chest")
  print("chest direction="..configuration.ignoreDir)
  print("-------------------------------")
  print("ABORTING")
  print("")
  print("")
  print("")
  print("")
  api_sharedFunctions.dropoff(configuration, configuration.numIgnoreBlocks, true, true)
  return
end
if configuration.singleChest then
  api_sharedFunctions.dropoffAndRestock(configuration, configuration.numIgnoreBlocks, false, false, true)
end

-- FOR EVERY LEVEL
for curL = 1 + configuration.skipL, configuration.numL do
  local firstT = 1
  if curL == 1 + configuration.skipL then
    firstT = firstT + configuration.skipT
  end
  -- FOR EVERY TUNNEL
  for curT = firstT, configuration.numT do
    -- DROP THE IGNORE ITEMS
    if not configuration.singleChest or (curL ~= 1 + configuration.skipL) or (curT ~= firstT) then
      api_sharedFunctions.moveToLocation(configuration, curL, curT, 0)
      api_sharedFunctions.dropoffAndRestock(configuration, configuration.numIgnoreBlocks, false, false, true)
    end
    local firstS = 0
    if (curL == 1 + configuration.skipL) and (curT == 1 + configuration.skipT) and (configuration.skipS~=0) then
      firstS = 1 + configuration.skipS
    end
    -- FOR EVERY SHAFT: DIG THE TUNNEL LEADING TO IT
    for curS = firstS, configuration.numS do
      api_sharedFunctions.moveToLocation(configuration, curL, curT, curS)
      api_digTunnels.digSegment(configuration)
      if api_sharedFunctions.needsRestocking(configuration) then
        api_sharedFunctions.dropoffAndRestock(configuration, 0, false, false, false)
      end
    end
    firstS = math.max(firstS, 1)
    -- FOR EVERY SHAFT: DIG IT
    for curS = firstS, configuration.numS do
      api_sharedFunctions.moveToLocation(configuration, curL, curT, curS)
      api_turtleExt.turnTo(left)
      api_digShafts.digShaft(configuration, left)
      if api_sharedFunctions.needsRestocking(configuration) then
        api_turtleExt.turnTo(left)
        api_sharedFunctions.dropoffAndRestock(configuration, 0, false, false, false)
        api_turtleExt.turnTo(right)
      end
      api_digShafts.digShaft(configuration, right)
      api_turtleExt.turnTo(right)
      if api_sharedFunctions.needsRestocking(configuration) then
        api_sharedFunctions.dropoffAndRestock(configuration, 0, false, false, false)
      end
    end
    -- RETRIEVE THE IGNORE ITEMS
    api_sharedFunctions.moveToLocation(configuration, curL, curT, 0)
    api_sharedFunctions.dropoffAndRestock(configuration, configuration.numIgnoreBlocks, true, false, true)
    -- FOR EVERY SHAFT: DIG THE ORES
    for curS = firstS, configuration.numS do
      api_sharedFunctions.moveToLocation(configuration, curL, curT, curS)
      api_turtleExt.turnTo(left)
      api_digOres.excavateShaft(configuration, left)
      api_digOres.excavateShaft(configuration, right)
      api_turtleExt.turnTo(right)
    end
  end
end

-- RETURN TO START AND DROPOFF
api_sharedFunctions.moveToLocation(configuration, 1, 1, 0)
api_sharedFunctions.dropoff(configuration, configuration.numIgnoreBlocks, true, true)
print("Execution finished")
print("Number of ores dug: "..configuration.numOres)

-- ---------------------------------------------------------- --
-- END OF THE CODE THAT GETS EXECUTED WHEN THE PROGRAM STARTS --
-- ---------------------------------------------------------- --