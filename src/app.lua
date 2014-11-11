graphics=love.graphics
image=love.image
fs=love.filesystem
hook.new("load",function()
	fdat=fs.read("save.txt")
	save={}
	if fdat then
		local f=loadstring("return "..fdat)
		if f then
			save=setfenv(f,{})() or {}
		end
	end
	local savedt=0
	dosave=false
	hook.new("update",function(dt)
		if dosave then
			savedt=savedt+dt
			if savedt>=2 then
				fs.write("save.txt",serialize(save))
				dosave=nil
				savedt=0
			end
		end
	end)
	w,h=graphics.getDimensions()
	function vibrate()
		if love.system.vibrate then
			love.system.vibrate(0.01)
		end
	end
	require("menu.main")()
end)

