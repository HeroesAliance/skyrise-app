return function()
	local menu
	local back=hook.new("back_button",function()
		if menu.ey==0 then
			menu.ey=-100
		else
			menu.ey=0
		end
		vibrate()
	end)
	menu=obj.new("frame",{
		layer=20,
		x=0,y=-100,
		ey=0,
		width=(w/h)*100,height=100,
		r=255,g=255,b=255,a=240,
		onDown=function(s)
			return true
		end,
		onDrag=function(s)
			return true
		end,
		onClick=function(s)
			if s.ey==0 then
				s.ey=-100
			else
				s.ey=0
			end
			vibrate()
			return true
		end,
		update=function(s,dt)
			if s.ey and s.ey~=s.y then
				if s.ey>s.y then
					s.y=s.y+(math.max(5,(s.ey-s.y)*4)*dt)
				else
					s.y=s.y-(math.max(5,(s.y-s.ey)*4)*dt)
				end
				if math.abs(s.y-s.ey)<0.1 then
					s.y=s.ey
					if s.y~=0 then
						hook.del(back)
						s:destroy()
						scoreMenuOpen=false
					end
				end
			end
		end,
	})
	local sz=(w/h)*25
	menu:new("text",{
		x=0,y=30-(sz/2),
		size=sz,
		maxwidth=(w/h)*47,
		r=clr_red[1],g=clr_red[2],b=clr_red[3],
		style="center",
		value=scoringTextRed.value,
	})
	menu:new("text",{
		x=(w/h)*53,y=30-(sz/2),
		size=sz,
		maxwidth=(w/h)*47,
		r=clr_blue[1],g=clr_blue[2],b=clr_blue[3],
		style="center",
		value=scoringTextBlue.value,
	})
	local bh=20
	local bw=20
	local ts=bh/2
	local resetButton=menu:new("frame",{
		x=2,y=98-bh,
		height=bh,width=bw,
		r=30,g=30,b=30,
		onClick=function(s)
			resetScore()
		end,
	})
	resetButton:new("text",{
		x=0,y=(bh/2)-(ts/1.7),
		r=180,g=180,b=180,
		size=ts,
		maxwidth=bw,
		value="0",
		style="center",
	})
	local scoreSheetButton=menu:new("frame",{
		x=4+bw,y=98-bh,
		height=bh,width=bw,
		r=30,g=30,b=30,
		onClick=function(s)
			local menu=menu:new("frame",{
				layer=menu.layer+3,
				x=0,y=0,
				width=(w/h)*100,height=100,
				r=255,g=255,b=255,a=240,
				onDown=function(s)
					return true
				end,
				onDrag=function(s)
					return true
				end,
				onClick=function(s)
					s:destroy()
					vibrate()
					return true
				end,
			})
			local redtext="Red Teams:\n"..
				"-Skyrise:\n"..
				"--Sections [ "..score.red.sections.." ]\n"..
				"--Cubes [ "..score.red.sCubes.." ]\n"..
				"-Posts:\n"..
				"--Owned [ "..score.red.owned.." ]\n"..
				"--Cubes [ "..score.red.pCubes.." ]\n"..
				"-Floor goals [ "..score.red.floor.." ]\n"..
				"-Auton winner [ "..(score.auton=="red" and "yes" or "no").." ]"
			local bluetext="Blue Teams:\n"..
				"-Skyrise:\n"..
				"--Sections [ "..score.blue.sections.." ]\n"..
				"--Cubes [ "..score.blue.sCubes.." ]\n"..
				"-Posts:\n"..
				"--Owned [ "..score.blue.owned.." ]\n"..
				"--Cubes [ "..score.blue.pCubes.." ]\n"..
				"-Floor goals [ "..score.blue.floor.." ]\n"..
				"-Auton winner [ "..(score.auton=="blue" and "yes" or "no").." ]"
			local function text(txt,x,y,size,r,g,b)
				local c=0
				for i,l in txt:gmatch("([%-]*)([^\n]+)") do
					menu:new("text",{
						x=x+((#i)*(size*2)),y=y+(c*(size*1.3)),
						maxwidth=(w/h)*46,
						size=size,
						value=l,
					})
					c=c+1
				end
			end
			text(redtext,(w/h)*2,(w/h)*2,6.5)
			text(bluetext,(w/h)*52,(w/h)*2,6.5)
			vibrate()
			return true
		end
	})
	local ts=bh/2
	scoreSheetButton:new("text",{
		x=0,y=(bh/2)-(ts/1.7),
		r=180,g=180,b=180,
		size=ts,
		maxwidth=bw,
		value="S",
		style="center",
	})
end
