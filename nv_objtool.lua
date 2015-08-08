--[[
	This tool reads obj files that are stored in data/basedir and goes through all OBJ files and MTL files stored within that folder.
	What then happens is it reads the texture directory and takes the name of the texture itself and assigns it as the material name.
	The OBJ and the MTL files are put into two seperate folders. data/objtool/out/mtl/ and data/objtool/out/obj you may need to create these folders.
	Once they are in the folders you will need to change the file extension from .txt to the name of the folder (either mtl or obj).
	Once you reimport the OBJ and MTL file into your preferred 3d modelling program, they should have correct material names allowing for a speedy import to the source engine.
--]]

local olddirs = 0
local basedir = "source_*/"
local dirs = {basedir}
local MTLFiles = {}
local materialIndex = {}
local files = {"*"}

for k, v in pairs(files) do
	local function ProcessMTLFile(mtl)
		local mtl = string.Explode("\n", mtl, false) 
		for key, value in pairs(mtl) do
			if string.StartWith(value, "newmtl") then
				print(mtl[key + 8])
				local target = string.gsub(value, "newmtl ", "", 1)
				if (string.find(mtl[key + 8], ".dds")) then
					local newMaterial = string.gsub(mtl[key + 8], "\\", ".")
					newMaterial = string.Explode(".", newMaterial, false)
					
					materialIndex[string.gsub(mtl[key], "newmtl ", "")] = "phy"
					mtl[key] = "newmtl ".."phy"
				end
			end
		end
	
		file.Write("objtool/out/mtl/"..v..".txt", string.Implode("\n", mtl))
	end
	
	ProcessMTLFile(file.Read("objtool/in/"..v..".mtl", "DATA"))
	local object = "NULL"
	
	local function ProcessOBJFile(obj)
		local obj = string.Explode("\n", obj, false)
		for key, value in pairs(obj) do
			if string.StartWith(value, "usemtl ") then
				local newMaterial = string.gsub(value, "usemtl ", "")
				if (materialIndex[newMaterial]) then
					obj[key] = "usemtl ".."phy"
					print(materialIndex[newMaterial])
				else
					print("ERROR IN "..object)
				end
			elseif string.StartWith(value, "o") then
				object = value
			end
		end
	
		file.Write("objtool/out/obj/"..v..".txt", string.Implode("\n", obj))
	end
	
	ProcessOBJFile(file.Read("objtool/in/"..v..".obj", "DATA"))
	
	local matty = {}
	for k, v in pairs(materialIndex) do
		print(k, v)
		if !table.HasValue(matty, v) then
			table.insert(matty, v)
		end
	end

	for k, v in pairs(matty) do
		print(v)
	end
end
