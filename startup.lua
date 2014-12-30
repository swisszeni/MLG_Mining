-- SPLITS A STRING INTO TWO PARTS, BEFORE AND AFTER THE DELIMITER
function splitString(string, delimiter)
  local parts={}
  parts[1]=string:sub(0, (string:find(delimiter))-1)
  parts[2]=string:sub((string:find(delimiter))+1)
  return parts
end


-- CHECKS IF THE PROGRAM REQUIRES UPDATING
function requiresUpdate(newestVersion)
  -- IF THERE IS NO CHANGELOG: UPDATE
  local file=io.open("changelog", "r")
  if file == nil then
    return true
  end
  -- IF IT IS OF AN OLDER VERSION: UPDATE
  local versionLine=file:read()
  local versionInfo=splitString(versionLine, "=")[2]
  file:close()
  if versionInfo~=newestVersion then
    return true
  end
  return false
end

-- MAIN UPDATE CODE
local updateConfig = http.get("https://raw.github.com/Ulthean/MLG_Mining/master/updateList")
if not updateConfig then
  print("Error connecting to server")
  return false
end
local newestVersionInfo=splitString(updateConfig.readLine(), "=")[2]
if requiresUpdate(newestVersionInfo) then
  -- BUILD THE LIST OF PROGRAMS TO UPDATE
  local numPrograms=tonumber(splitString(updateConfig.readLine(), "=")[2])
  local programs={}
  for i=1, numPrograms do
    local programInfo = updateConfig.readLine()
    programs[splitString(programInfo, "=")[1]]=splitString(programInfo, "=")[2]
  end
  -- REMOVE ALL PROGRAMS, EXCEPT FOR THE CONFIG FILE
  for k, v in pairs(programs) do
    if k~="config" then
      shell.run("rm", k)
    end
  end
  -- ADD THE UPDATED PROGRAMS
  for k, v in pairs(programs) do
    shell.run("pastebin", "get", v, k)
  end
  -- PROVIDE UPDATE INFO
  local impact=splitString(updateConfig.readLine(), "=")[2]
  local advise=splitString(updateConfig.readLine(), "=")[2]
  print("---------------------------")
  print("MLG MINING: PROGRAM UPDATED")
  print("IMPACT: "..impact)
  print("ADVISE: "..advise)
  print("---------------------------")
else
  print("---------------------------")
  print("MLG MINING: NO UPDATE FOUND")
  print("---------------------------")
end