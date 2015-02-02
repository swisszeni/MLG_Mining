-- VALUES FOR THE DIRECTIONS
local up="up"
local down="down"
local forward="forward"
local back ="back"
local right="right"
local left="left"

-- LOAD THE API OFFERING EXTENDED TURTLE MOVEMENT OPTIONS
os.loadAPI("api_turtleExt")

-- ------------------------------------------------------------------------------ --
-- START OF THE FUNCTION HANDLING THE FILE INPUT AND OUTPUT AND STRING OPERATIONS --
-- ------------------------------------------------------------------------------ --

-- CHECK IF A FILE EXISTS
local function fileExists(filename)
  local file=io.open(filename, "rb")
  if file then 
    file:close()
  end
  return file~=nil
end


-- GETS ALL THE INPUT FROM A FILE
local function getFileContent(filename, skipLines)
  skipLines=skipLines or 0
  if not fileExists(filename) then 
    return {}
  end
  local file=io.open(filename, "r")
  local lines={}
  while true do
    for i=1, skipLines do
      file:read()
    end
    local line=file:read()
    if line==nil then
      break
    end
    lines[#lines+1]=line
  end
  file:close()
  return lines
end


-- SPLITS A TABLE OF STRINGS INTO THEIR KEYS AND VALUES
local function splitInput(table)
  local results={}
  for k,v in pairs(table) do
    local key=v:sub(0, (v:find('='))-1)
    local value=v:sub((v:find('='))+1)
    results[key]=value
  end
  return results
end

-- ---------------------------------------------------------------------------- --
-- END OF THE FUNCTION HANDLING THE FILE INPUT AND OUTPUT AND STRING OPERATIONS --
-- ---------------------------------------------------------------------------- --

-- ------------------------------------------------------------ --
-- START OF THE FUNCTIONS RELATING TO THE CONFIG OF THE PROGRAM --
-- ------------------------------------------------------------ --

-- RETURNS IF A THE VALUE GIVEN PARAMETER IS A NUMBER
local function isNumberInput(param)
  if ((param=="numL") or (param=="numT") or (param=="numS") or (param=="skipL") or (param=="skipT") or (param=="skipS") 
      or (param=="height") or (param=="blocksBetweenShafts") or (param=="firstShaftOffset") or (param=="evenLevelOffset") 
      or (param=="centerRadius") or (param=="numIgnoreBlocks") or (param=="departureFuel") or (param=="returnFuel")) then 
    return true
  else
    return false
  end 
end


-- RETURNS IF THE VALUE OF A GIVEN PARAMETER IS A DIRECTION
local function isDirectionInput(param)
  if ((param=="nextDirL") or (param=="nextDirT") or (param=="fuelSuckDir") or (param=="fuelDropDir") or (param=="itemDropDir") 
      or (param=="torchSuckDir") or (param=="ignoreDir")) then
    return true
  else
    return false
  end
end


-- RETURNS IF THE VALUE OF A GIVEN PARAMETER IS A BOOLEAN
local function isBooleanInput(param)
  if ((param=="placeTorches") or (param=="singleChest") or (param=="requiresFuel") or (param=="digSidesToo")) then
    return true
  else
    return false
  end
end

-- CHECKS IF A STRING DENOTES A DIRECTION
function isDirection(dir)
  if dir=="forward" or dir=="back" or dir=="left" or dir=="right" or dir=="up" or dir=="down" then
    return true
  end
  return false
end

-- PRINTS THE MANUAL TO THE TERMINAL IN CASE THE USER SPECIFIED INCORRECT VALUES
local function printManual()
  term.clear()
  print("Command Line Arguments (1/3)")
  print("----------------------------")
  print(" -numL <num>     (=nr. of levels)")
  print(" -numT <num>     (=nr. of tunnels)")
  print(" -numS <num>     (=nr. of shafts)")
  print(" -skipL <num>    (=skip # levels)")
  print(" -skipT <num>    (=skip # tunnels)")
  print(" -skipS <num>    (=skip # shafts)")
  print(" -dirNextL <dir> (=next lev. U/D)")
  print(" -dirNextT <dir> (=next tun. L/R)")
  print("PRESS ANY KEY TO CONTINUE")
  print("")
  read()
  term.clear()
  print("Command Line Arguments (2/3)")
  print("----------------------------")
  print(" -height <num>   (=level height 2/3)")
  print(" -betw <num>     (=blocks betw shafts)")
  print(" -firstOffs <num>(=first shaft offset)")
  print(" -evenOffs <num> (=even level offset)")
  print(" -torches        (=place torches)")
  print(" -oneChest       (=single drop chest)")
  print(" -rad <num>      (=center radius)")
  print(" -sides          (=dig out the sides)")
  print(" -numIgnore <num>(=num ignore blocks)")
  print("PRESS ANY KEY TO CONTINUE")
  read()
  term.clear()
  print("Command Line Arguments (3/3)")
  print("----------------------------")
  print(" -noFuel         (=no need for fuel)")
  print(" -depFuel <num>  (=departure fuel)")
  print(" -retFuel <num>  (=return fuel)")
  print(" -fuelS <dir>    (=fuel suck dir)")
  print(" -fuelD <dir>    (=fuel drop dir)")
  print(" -torchS <dir>   (=torch suck dir)")
  print(" -itemD <dir>    (=item drop dir)")
  print(" -ignoreS <dir>  (=ignore block dir)")
  print("")
  print("")
end

-- PRINTS THE POSSIBLE DIRECTION VALUES TO THE TERMINAL
local function printDirs(source, attribute, value)
  term.clear()
  print("Invalid direction chosen:")
  print("------------------------------------")
  print("_SOURCE= "..source)
  print("_ATTRIB= "..attribute)
  print("_VALUE="..value)
  print("------------------------------------")
  print(" up")
  print(" down")
  print(" forward")
  print(" back")
  print(" right")
  print(" left")
  sleep(2)
end

-- RETURNS THE DEFAULT CONFIGURATION OF THE PROGRAMS
local function getDefaultConfig()
  local configuration={}
  -- THE NUMBER OF LEVELS
  configuration.numL=1
  -- THE NUMBER OF TUNNELS
  configuration.numT=4
  -- THE NUMBER OF SHAFTS TO EXCAVATE
  configuration.numS=16
  -- HOW MANY LEVELS TO SKIP
  configuration.skipL=0
  -- HOW MANY TUNNELS TO SKIP
  configuration.skipT=0
  -- HOW MANY SHAFTS TO SKIP
  configuration.skipS=0
  -- THE DIRECTION OF THE NEXT LEVEL (UP or DOWN)
  configuration.nextDirL=up
  -- THE DIRECTION OF THE NEXT TUNNEL (LEFT or RIGHT)
  configuration.nextDirT=left
  -- THE HEIGHT OF THE LEVELS/TUNNELS
  configuration.height=3
  -- THE NUMBER OF BLOCKS BETWEEN EACH SHAFT
  configuration.blocksBetweenShafts=3
  -- HOW MANY BLOCKS WILL THE TURTLE MOVE BEFORE DIGGING THE FIRST SHAFT
  configuration.firstShaftOffset=4
  -- THE NUMBER OF BLOCKS THE EVEN LEVEL SHAFTS WILL BE OFFSET
  configuration.evenLevelOffset=2
  -- DOES THE TURTLE ALSO PLACE TORCHES
  configuration.placeTorches=false
  -- IS THERE A SINGLE DROPOFF STATION (true) OR ONE PER DIRECTION, PER LEVEL (false)
  configuration.singleChest=false
  -- THE RADIUS OF THE CIRCLE ON WHICH THE REFUELING STATIONS ARE POSITIONED
  configuration.centerRadius=5
  -- DOES THE TURTLE NEED TO DIG OUT THE SIDES OF THE TUNNEL TOO
  configuration.digSidesToo=false
  -- THE NUMBER OF BLOCK TYPES THE TURTLE WILL _NOT_ DIG UNLESS NEEDED
  -- DEFAULT CONSIDERS: Smooth stone, Dirt, Gravel, Marble (Tekkit), Wood, stone bricks
  configuration.numIgnoreBlocks=6
  -- DOES THE TURTLE REQUIRE FUEL TO OPERATE?
  configuration.requiresFuel=true
  -- THE AMOUNT OF FUEL THE TURTLE WILL STORE BEFORE HEADING OF TO A SHAFT
  configuration.departureFuel=1200
  -- THE AMOUNT OF FUEL AT WHICH THE TURTLE WILL RETURN TO DROPOFF
  configuration.returnFuel=200
  -- THE DIRECTION OF THE FUEL ITEMS (IN THE REFUELING STATION)
  configuration.fuelSuckDir=up
  -- THE DIRECTION WHERE THE TURTLE WILL DROP LEFTOVERS (BUCKETS)
  configuration.fuelDropDir=down
  -- THE DIRECTION WHERE THE TURTLE WILL DROP ANY MINED ITEMS
  configuration.itemDropDir=down
  -- THE DIRECTION OF THE TORCHES
  configuration.torchSuckDir=right
  -- THE DIRECTION OF THE IGNORE BLOCKS
  configuration.ignoreDir=left
  -- RETURN THE CONFIGURATION
  return configuration
end


-- CHANGES THE GIVEN CONFIGURATION TO ACCOUNT FOR THE CONFIG FILE
local function processConfigFile(configuration, filename)
  local lines=getFileContent(filename, 1)
  local parsed=splitInput(lines)
  for k,v in pairs(parsed) do
    -- IF IT IS A NUMBER INPUT
    if isNumberInput(k) then
      configuration[k]=tonumber(v)
    end
    -- IF IT IS A DIRECTION INPUT
    if isDirectionInput(k) then
      if not isDirection(v) then
        printDirs("Config File: "..filename, k, v)
        return false
      end
      configuration[k]=v
    end
    -- IF IT IS A BOOLEAN INPUT
    if isBooleanInput(k) then
      if v=="true" then
        configuration[k]=true
      else
        configuration[k]=false
      end
    end
  end
  return true
end


-- CHANGES THE GIVEN CONFIGURATION TO ACCOUNT FOR THE COMMAND LINE ARGUMENTS
local function processCommandLine(configuration, args)
  readParams=0
  while readParams < #args do
    if string.lower(args[readParams+1])=="-numl" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.numL=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-numt" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.numT=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-nums" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.numS=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-skipl" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.skipL=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-skipt" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.skipT=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-skips" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.skipS=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-dirnextl" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.nextDirL=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-dirnextt" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.nextDirT=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-height" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.height=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-betw" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.blocksBetweenShafts=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-firstoffs" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.firstShaftOffset=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-evenoffs" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.evenLevelOffset=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-torches" then
      configuration.placeTorches=true
      readParams=readParams+1
    elseif string.lower(args[readParams+1])=="-onechest" then
      configuration.singleChest=true
      readParams=readParams+1
    elseif string.lower(args[readParams+1])=="-rad" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.centerRadius=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-sides" then
      configuration.digSidesToo=true
      readParams=readParams+1
    elseif string.lower(args[readParams+1])=="-numignore" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      local numIgnoreBlocks=tonumber(args[readParams+2])
      if (numIgnoreBlocks > 16) then
        print("Maximum 16 ignore blocks allowed")
        return false
      end
      configuration.numIgnoreBlocks=numIgnoreBlocks
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-nofuel" then
      configuration.requiresFuel=false
      readParams=readParams+1
    elseif string.lower(args[readParams+1])=="-depfuel" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.departureFuel=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-retfuel" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      configuration.returnFuel=tonumber(args[readParams+2])
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-fuels" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.fuelSuckDir=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-fueld" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.fuelDropDir=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-torchs" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.torchSuckDir=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-itemd" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.itemDropDir=args[readParams+2]
      readParams=readParams+2
    elseif string.lower(args[readParams+1])=="-ignores" then
      if not (readParams+1 < #args) then
        printManual()
        return false
      end 
      if not isDirection(args[readParams+2]) then
        printDirs("Command Line Arguments", args[readParams+1], args[readParams+2])
        return false
      end
      configuration.ignoreDir=args[readParams+2]
      readParams=readParams+2
    else
      printManual()
      return false
    end
  end
  return true
end


-- VALIDATES THE CONFIGURATION TO CHECK THE DEPENDANT VALUES (NUMIGNORE ON TORCHES)
local function validateConfig(configuration)
  if (configuration.placeTorches and configuration.numIgnoreBlocks > 15) then
    print("With torches enabled, maximum 15 ignore blocks allowed")
    return false
  end
  return true
end


-- RETURNS THE CONFIGURATION OF THE PROGRAM, ACCOUNTING FOR THE CONFIG FILE AND THE COMMAND LINE ARGUMENTS
function getConfig(filename, args)
  local configuration=getDefaultConfig()
  -- TRY TO PROCESS THE CONFIG FILE, ABORT IF THIS FAILS (THE RETURN VALUE IS FALSE)
  if not processConfigFile(configuration, filename) then
    return nil
  end
  -- TRY TO PROCESS THE COMMAND LINE ARGUMENTS, ABORT IF THIS FAILS (THE RETURN VALUE IS FALSE)
  if not processCommandLine(configuration, args) then
    return nil
  end
  -- NOW THAT THE FINAL CONFIGURATION IS GATHERED, VALIDATE IT
  if not validateConfig(configuration) then
    return nil
  end
  return configuration
end

-- ---------------------------------------------------------- --
-- END OF THE FUNCTIONS RELATING TO THE CONFIG OF THE PROGRAM --
-- ---------------------------------------------------------- --

-- -------------------------------------------------- --
-- START OF THE FUNCTIONS SHARED BETWEEN ALL PROGRAMS --
-- -------------------------------------------------- --

-- CHECKS IF THE TURTLE NEEDS RESTOCKING
function needsRestocking(configuration)
  if configuration.requiresFuel then
    if turtle.getFuelLevel() < configuration.returnFuel then
      return true
    end
  end
  if turtle.getItemCount(15)~=0 or turtle.getItemCount(16)~=0 then
    return true
  end
  if configuration.placeTorches and turtle.getItemCount(1)==0 then
    return true
  end
  return false
end


-- EMPTIES THE INVENTORY AND RESTOCKS THE INVENTORY
function dropoffAndRestock(configuration, ignoreBlocks, restockIgnore, dropTorches, dropIgnore)
  tempL=configuration.currentL
  tempT=configuration.currentT
  tempS=configuration.currentS
  if configuration.singleChest then
    moveToLocation(configuration, 1, 1, 0)
  else
    moveToLocation(configuration, tempL, tempT, 0)
  end
  if restockIgnore then
    dropoff(configuration, 0, dropTorches, dropIgnore)
  else
    dropoff(configuration, ignoreBlocks, dropTorches, dropIgnore)
  end
  restock(configuration, ignoreBlocks, restockIgnore)
  moveToLocation(configuration, tempL, tempT, tempS)
end


-- EMPTIES THE INVENTORY
function dropoff(configuration, ignoreBlocks, dropTorches, dropIgnore)
  -- DROP THE TORCHES
  turtle.select(1)
  local torchSlot=0
  if configuration.placeTorches then
    torchSlot=1
    if dropTorches then
      api_turtleExt.drop(configuration.torchSuckDir)
    end
  end
  -- DROP THE EXTRAS OF THE IGNORE BLOCKS
  api_turtleExt.turnTo(configuration.itemDropDir)
  for i=1+torchSlot,torchSlot+ignoreBlocks do
    turtle.select(i)
    api_turtleExt.drop(api_turtleExt.turnedDir(configuration.itemDropDir), math.max(turtle.getItemCount(i)-1, 0))
  end
  -- DROP THE OTHER ITEMS
  for i=torchSlot+ignoreBlocks+1,16 do
    turtle.select(i)
    api_turtleExt.drop(api_turtleExt.turnedDir(configuration.itemDropDir), turtle.getItemCount(i))
  end
  api_turtleExt.turnFrom(configuration.itemDropDir)
  turtle.select(1)
  -- DROP THE IGNORE BLOCKS
  if dropIgnore then
    api_turtleExt.turnTo(configuration.ignoreDir)
    for i=1+torchSlot,torchSlot+ignoreBlocks do
      turtle.select(i)
      api_turtleExt.drop(api_turtleExt.turnedDir(configuration.ignoreDir), 1)
    end
    api_turtleExt.turnFrom(configuration.ignoreDir)
  end
end


-- RESTOCKS THE TORCHES
function restockTorches(configuration)
  turtle.select(1)
  local dispMsg=true
  local firstEmpty=2
  -- CALCULATE THE FIRST EMPTY SLOT
  while ((turtle.getItemCount(firstEmpty)>0) and (firstEmpty<16)) do
    firstEmpty = firstEmpty+1
  end
  -- ALIGN WITH THE TORCH CHEST AND SUCK A STACK
  api_turtleExt.turnTo(configuration.torchSuckDir)
  local tDir=api_turtleExt.turnedDir(configuration.torchSuckDir)
  while turtle.getItemCount(firstEmpty)==0 do
    if not api_turtleExt.suck(tDir) then
      if dispMsg then
        term.clear()
        term.setCursorPos(1,1)
        print("---------------------------------")
        print("Please place some torches in a chest")
        print("Chest Direction:  "..configuration.torchSuckDir)
        print("Torches Required: "..(turtle.getItemSpace(1)+1))
        print("---------------------------------")
        dispMsg=false
      end
    else
      dispMsg=true
    end
    sleep(0)
  end
  term.clear()
  -- CHECK IF THERE ARE ACTUALLY TORCHES IN SLOT 1 AND DUMP ANY EXCESS TORCHES
  if turtle.compareTo(firstEmpty) then
    turtle.select(firstEmpty)
    api_turtleExt.drop(tDir)
    api_turtleExt.turnFrom(configuration.torchSuckDir)
  else
    turtle.select(firstEmpty)
    api_turtleExt.drop(tDir)
    turtle.select(1)
    api_turtleExt.turnFrom(configuration.torchSuckDir)
    api_turtleExt.drop(configuration.itemDropDir)
    restockTorches(configuration)
  end
  turtle.select(1)
end


-- RESTOCKS THE INVENTORY
function restock(configuration, ignoreBlocks, restockIgnore)
  turtle.select(1)
  local torchSlot=0
  -- RESTOCK THE TORCHES
  if configuration.placeTorches then
    torchSlot=1
    restockTorches(configuration)
  end
  -- RESTOCK THE IGNORE BLOCKS
  if restockIgnore then
    api_turtleExt.turnTo(configuration.ignoreDir)
    local tDir=api_turtleExt.turnedDir(configuration.ignoreDir)
    for i=1+torchSlot,ignoreBlocks+torchSlot do
      turtle.select(i)
      api_turtleExt.suck(tDir)
    end
    api_turtleExt.turnFrom(configuration.ignoreDir)
  end
  -- RESTOCK THE FUEL
  if configuration.requiresFuel then
    api_turtleExt.refuel(configuration.fuelSuckDir, configuration.fuelDropDir, 16, configuration.departureFuel)
  end
  turtle.select(1)
end


-- CALCULATES HOW MUCH MOVES NEED TO BE MADE TO GO FROM ONE SHAFT TO ANOTHER
function calculateMoves(configuration, numL, fromS, toS)
  local lowS=fromS
  local highS=toS
  if highS < lowS then
    lowS=toS
    highS=fromS
  end
  if lowS==highS then
    return 0
  end
  local requiredMoves=0
  if highS==(configuration.numS+1) then
    if numL % 2==1 then
      requiredMoves=requiredMoves+configuration.evenLevelOffset
    end
    highS=highS-1
  end
  if lowS==0 then
    requiredMoves=requiredMoves+configuration.firstShaftOffset
    if numL % 2==0 then
      requiredMoves=requiredMoves+configuration.evenLevelOffset
    end
    requiredMoves=requiredMoves+((configuration.blocksBetweenShafts+1)*(highS-1))
  else
    requiredMoves=requiredMoves+((configuration.blocksBetweenShafts+1)*(highS-lowS))
  end
  return requiredMoves
end


-- MOVES FROM THE CURRENT LOCATION TO ANOTHER
function moveToLocation(configuration, newL, newT, newS)
  if newL==configuration.currentL and newT==configuration.currentT then
    if configuration.currentS < newS then
      api_turtleExt.digAndMove(forward, calculateMoves(configuration, newL, configuration.currentS, newS), 0)
    elseif newS < configuration.currentS then
      api_turtleExt.digAndMove(api_turtleExt.reverseDir(forward), calculateMoves(configuration, newL, configuration.currentS, newS), 0)
    end
  else
    local turnDir=configuration.nextDirT
    local moves=newT-configuration.currentT
    if configuration.currentT > newT then
      turnDir=api_turtleExt.reverseDir(turnDir)
      moves=configuration.currentT-newT
    end
    if configuration.currentS==0 then
      api_turtleExt.digAndMove(forward, 1, 0)
      api_turtleExt.turnTo(turnDir)
    else
      api_turtleExt.turnTo(back)
      api_turtleExt.digAndMove(forward, calculateMoves(configuration, configuration.currentL, 0, configuration.currentS)-1, 0)
      api_turtleExt.turnFrom(turnDir)
    end
    api_turtleExt.digAndMove(forward, configuration.centerRadius+1, 0)
    if configuration.currentL < newL then
      api_turtleExt.digAndMove(configuration.nextDirL, (newL-configuration.currentL)*(configuration.height+1), 0)
    end
    if configuration.currentL > newL then
      api_turtleExt.digAndMove(api_turtleExt.reverseDir(configuration.nextDirL), (configuration.currentL-newL)*(configuration.height+1), 0)
    end
    if newT==configuration.currentT then
      api_turtleExt.turnTo(back)
    else
      api_turtleExt.turnTo(turnDir)
      for i=2, moves do
        api_turtleExt.digAndMove(forward, 2*(configuration.centerRadius+1), 0)
        api_turtleExt.turnTo(turnDir)
      end
    end
    if newT==configuration.currentT then
      turnDir=api_turtleExt.reverseDir(turnDir)
    end
    api_turtleExt.digAndMove(forward, configuration.centerRadius+1, 0)
    if newS==0 then
      api_turtleExt.turnTo(turnDir)
      api_turtleExt.digAndMove(forward, 1, 0)
      api_turtleExt.turnTo(back)
    else
      api_turtleExt.turnFrom(turnDir)
      api_turtleExt.digAndMove(forward, calculateMoves(configuration, newL, 0, newS)-1, 0)
    end
  end
  configuration.currentL=newL
  configuration.currentT=newT
  configuration.currentS=newS
end


-- REPORTS AND OBSTRUCTION IN ONE OF THE SHAFTS
function reportObstruction(configuration, dir)
  print("Encountered obstruction in:")
  print(" LEV: "..configuration.currentL)
  print(" TUN: "..configuration.currentT)
  print(" SH : "..configuration.currentS.." ("..dir..")")
end


-- RETURNS THE CURRENT VERSION OF THE OS (CraftOS)
function getOSVersion()
  return tonumber(splitString(os.version(), " ")[2])
end


-- RETURNS IF THE VERSION OF THE OS (CraftOS) IS ATLEAST THE GIVEN
function OSVersionIsAtleast(osVersion)
  return getOSVersion >= osVersion
end

-- ------------------------------------------------ --
-- END OF THE FUNCTIONS SHARED BETWEEN ALL PROGRAMS --
-- ------------------------------------------------ --