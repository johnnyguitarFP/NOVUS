local olddirs = 0
local basedir = "models/*/"
local dirs = {basedir}
local normalpairs = {}
-- Get all subfolders of the targeted folder

local function GetDirectories(path)
	local path = path or "*"
	local files, directories = file.Find(path, "DATA")

	if (directories and directories != {}) then
		for k, v in pairs(directories) do
			local d = string.Replace(path, "*", "")
			table.insert(dirs, d..v.."/")
			GetDirectories(d..v.."/*")
		end
	end
end

GetDirectories(basedir.."*")

local function GetPairs(dirs)
	for _, path in pairs(dirs) do
		local tosearch = path.."*.vtf"
		local files = file.Find(tosearch, "DATA")
		for _, file in pairs(files) do
			local file = string.lower(file)
			if (!string.find(file, "_n.vtf")) then
				for k, v in pairs(files) do
					local v = string.lower(v)
					local newfile = string.gsub(file, ".vtf", "")
					local targetfile = string.gsub(v, ".vtf", "")

					if (string.find(targetfile, newfile)) then
						local newtargetfile = string.gsub(targetfile, "_n", "")
						if (targetfile != newfile) then
							if (newfile == newtargetfile) then
								table.insert(normalpairs, {path, newfile, targetfile})
							end
						end
					end
				end
			end
		end
	end
end

GetPairs(dirs)

PrintTable(normalpairs)

local function processvmt(model, d, n, shaders)
	local d = string.gsub(d, "materials/", "", 1)
	local n = string.gsub(n, "materials/", "", 1)
	
	local vmt = "//Auto-Generated using NOVUS source tools"
	vmt = vmt..'\n"'..model..'"'
	vmt = vmt..'\n{'
	vmt = vmt..'\n	"$baseTexture"	'..'"'..d..'"'
	vmt = vmt..'\n	"$bumpMap"	'..'"'..n..'"'
	vmt = vmt..'\n'
	vmt = vmt..'\n'..shaders
	vmt = vmt..'\n}'

	return vmt
end

for _, info in pairs(normalpairs) do

	local model = "VertexLitGeneric"

	local baseTexture = info[1]..info[2]
	local bumpMap =	info[1]..info[3]

	local shaders = [[	"$halfLambert"	"1"
	"$envmap" "env_cubemap"
	"$normalmapalphaenvmapmask" "1"
	"$envmaptint" "[0.3 0.3 0.3]"]]
	
	file.Write(info[1]..info[2]..".txt", processvmt(model, baseTexture, bumpMap, shaders)) 
end
