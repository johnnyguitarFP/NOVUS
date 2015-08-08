local olddirs = 0
local basedir = "source_fallout/"
local dirs = {basedir}
local MTLFiles = {}
local materialIndex = {}
local files = {"props_col"}

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
