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
	
	function newList(dat)
		local o={
			items={},
		}
		local main=obj.new("frame",{
			r=dat.r,g=dat.g,b=dat.b,
			x=dat.x,y=dat.y,
			
		})
	end
	
	function bevelDraw(bvl,bo)
		bo=bo or s.height/4
		return function(s,u)
			local lw=s.width/50
			local points={}
			local function i(x,y)
				table.insert(points,x*u)
				table.insert(points,y*u)
			end
			if bvl.tl then
				i(s.realx,s.realy+bo)
				i(s.realx+bo,s.realy)
			else
				i(s.realx,s.realy)
			end
			if bvl.tr then
				i(s.realx+s.width-bo,s.realy)
				i(s.realx+s.width,s.realy+bo)
			else
				i(s.realx+s.width,s.realy)
			end
			if bvl.br then
				i(s.realx+s.width,s.realy+s.height-bo)
				i(s.realx+s.width-bo,s.realy+s.height)
			else
				i(s.realx+s.width,s.realy+s.height)
			end
			if bvl.bl then
				i(s.realx+bo,s.realy+s.height)
				i(s.realx,s.realy+s.height-bo)
			else
				i(s.realx,s.realy+s.height)
			end
			graphics.polygon("fill",unpack(points))
		end
	end
	require("menu.main")()
end)

