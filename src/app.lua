local graphics=love.graphics
local image=love.image
hook.new("load",function()
	local function vibrate()
		if love.system.vibrate then
			love.system.vibrate(0.01)
		end
	end
	for k,v in tpairs(objects) do
		objects[k]=nil
	end
	
	local function drawSkyrise(s,u)
		graphics.rectangle("fill",u*s.realx,u*s.realy,u*s.width,u*(s.height*0.9))
		graphics.setColor(s.r/1.5,s.g/1.5,s.b/1.5)
		graphics.rectangle("fill",u*(s.realx+(s.width*0.045)),u*(s.realy+(s.height*0.9)),u*(s.width/1.09),u*(s.height*0.1))
		graphics.setColor(20,20,20)
		graphics.setLineWidth(u*(s.width/15))
		graphics.line(
			u*(s.realx+(s.width*0.35)),u*(s.realy+(s.height/1.5)),
			u*(s.realx+(s.width/2)),u*(s.realy+(s.height/1.3)),
			u*(s.realx+(s.width*0.65)),u*(s.realy+(s.height/1.5))
		)
	end
	
	local function drawCube(s,u)
		local lw=s.width/5
		graphics.setLineWidth(u*lw)
		graphics.setLineJoin("none")
		local w=s.width-lw
		local h=s.height-lw
		local x=s.realx+(lw/2)
		local y=s.realy+(lw/2)
		graphics.line(
			u*x,u*y,
			u*(x+w),u*y,
			u*(x+w),u*(y+h),
			u*x,u*(y+h),
			u*x,u*y
		)
		graphics.circle("fill",u*x,u*y,u*(lw/2),100)
		graphics.circle("fill",u*(x+w),u*y,u*(lw/2),100)
		graphics.circle("fill",u*(x+w),u*(y+h),u*(lw/2),100)
		graphics.circle("fill",u*x,u*(y+h),u*(lw/2),100)
	end
	
	local scoringTextBlue
	local scoringTextRed
	local posts={}
	local skyrises={}
	local skyrisecubes={}
	
	local rfloor=0
	local bfloor=0
	local autonWinner
	local ccolor="red"
	local redFrame
	local blueFrame
	local floorGoalCounter
	
	local impossibru=graphics.newImage("res/not_an_easteregg.png")
	
	local clr_red={180,20,20}
	local clr_blue={19,65,190}
	
	local function resetScore()
		rfloor=0
		bfloor=0
		autonWinner=nil
		for k,v in pairs(posts) do
			v.ncubes=0
			v.doupdate()
		end
		blueFrame.reset()
		redFrame.reset()
		floorGoalCounter.value="0"
	end
	
	local autonIndicator
	local score
	
	local function updateScore()
		score={
			r=0,
			b=0,
			red={
				floor=rfloor,
				sections=0,
				sCubes=0,
				owned=0,
				pCubes=0,
				cubes=0,
			},
			blue={
				floor=bfloor,
				sections=0,
				sCubes=0,
				owned=0,
				pCubes=0,
				cubes=0,
			},
			autonWinner=autonWinner,
		}
		if autonWinner then
			autonIndicator.r,autonIndicator.g,autonIndicator.b=unpack(autonWinner=="red" and clr_red or clr_blue)
		else
			autonIndicator.r,autonIndicator.g,autonIndicator.b=40,40,40
		end
		for k,v in pairs(posts) do
			if v.ncubes>0 then
				for n,l in pairs(v.cubes) do
					if l.a~=0 then
						local c=l.r>l.b and "red" or "blue"
						score[c].pCubes=score[c].pCubes+1
						if n==v.ncubes then
							score[c].owned=score[c].owned+1
						end
					end
				end
			end
		end
		for k,v in pairs(skyrises) do
			if v.a~=0 then
				score[v.color].sections=score[v.color].sections+1
			end
		end
		for k,v in pairs(skyrisecubes) do
			if v.a~=0 then
				local c=v.r>v.b and "red" or "blue"
				score[c].sCubes=score[c].sCubes+1
			end
		end
		local s=score.red
		s.cubes=s.sCubes+s.pCubes
		score.r=s.floor + s.sections*4 + s.sCubes*4 + s.owned + s.pCubes*2
		if autonWinner=="red" then
			score.r=score.r+10
		end
		local s=score.blue
		s.cubes=s.sCubes+s.pCubes
		score.b=s.floor + s.sections*4 + s.sCubes*4 + s.owned + s.pCubes*2
		if autonWinner=="blue" then
			score.b=score.b+10
		end
		
		if score.red.cubes>22 or score.blue.cubes>22 then
			if redFrame then
				redFrame.image=impossibru
				redFrame.r=50
				redFrame.g=50
				redFrame.b=50
			end
			if blueFrame then
				blueFrame.image=impossibru
				blueFrame.r=50
				blueFrame.g=50
				blueFrame.b=50
			end
		else
			if redFrame then
				redFrame.r=0
				redFrame.g=0
				redFrame.b=0
				redFrame.image=nil
			end
			if blueFrame then
				blueFrame.r=0
				blueFrame.g=0
				blueFrame.b=0
				blueFrame.image=nil
			end
		end
		scoringTextRed.value=tostring(score.r)
		scoringTextBlue.value=tostring(score.b)
	end
	
	local w,h=graphics.getDimensions()
	local sz=4.5
	local height=sz*2.5
	local width=sz
	local indicatorCube
	local doneSwitching=true
	
	local function field(c1,c2)
		local main=obj.new("frame",{
			x=0,y=0,
			r=0,g=0,b=0,
			width=(w/h)*100,height=100,
			onDown=function()
				return true
			end,
			onClick=function()
				return true
			end,
			onDrag=function()
				return true
			end,
			update=function(s,dt)
				if s.ex and s.ex~=s.x then
					if s.ex>s.x then
						s.x=s.x+(math.max(5,(s.ex-s.x)*4)*dt)
					else
						s.x=s.x-(math.max(5,(s.x-s.ex)*4)*dt)
					end
					if math.abs(s.x-s.ex)<0.1 then
						s.x=s.ex
						if s.x~=0 then
							s.x=(w/h)*-100
							s.ex=(w/h)*-100
						end
						doneSwitching=true
					end
				end
			end
		})
		
		local c1r,c1g,c1b=unpack(c1)
		local c2r,c2g,c2b=unpack(c2)
		
		local base=main:new("frame",{x=0,y=94,r=c1r+35,g=c1g,b=c1b,width=(w/h)*100,height=6})

		base:new("frame",{x=0,y=0,width=(w/h)*26.5,height=6,r=80,g=80,b=80})
		base:new("frame",{x=(w/h)*51,y=0,width=(w/h)*49,height=6,r=80,g=80,b=80})

		local function regCubes(post)
			table.insert(posts,post)
			local function updateCubes()
				for l1=1,post.ncubes do
					post.cubes[l1].a=255
				end
				for l1=post.ncubes+1,post.capacity do
					post.cubes[l1].a=0
				end
				updateScore()
			end
			post.doupdate=updateCubes
			post.ncubes=0
			post.layer=2
			post.cubes={}
			local base=post:new("frame",{
				x=(post.width/2)-(height/2),y=post.height,
				width=height,height=6,a=0,
				xclick=width,
				onDrag=function()
					if post.ncubes==1 then
						post.ncubes=0
						updateCubes()
						vibrate()
						return true
					end
				end
			})
			for l1=1,post.capacity do
				table.insert(post.cubes,post:new("frame",{
					x=(post.width/2)-(height/2),y=post.height-(height*l1),
					width=height,height=height,
					xclick=width,
					r=c1r,g=c1g,b=c1b,a=0,
					draw=drawCube,
					onDrag=function(s)
						local r,g,b=indicatorCube.r,indicatorCube.g,indicatorCube.b
						if post.restricted then
							r=c1r
							g=c1g
							b=c1b
						end
						if (post.ncubes==0 and l1==1) or l1==post.ncubes+1 or l1==post.ncubes-1 then
							post.ncubes=l1
							s.r=r
							s.g=g
							s.b=b
							updateCubes()
							vibrate()
							return true
						elseif s.a~=0 and s.r~=r then
							s.r=r
							s.g=g
							s.b=b
							updateCubes()
							vibrate()
							return true
						end
					end,
					onClick=function(s)
						if s.r~=indicatorCube.r and not restricted then
							s.r=indicatorCube.r
							s.g=indicatorCube.g
							s.b=indicatorCube.b
							updateCubes()
							vibrate()
							return true
						end
					end,
				}))
			end
		end

		local highGoal=main:new("frame",{capacity=5,x=(((w/h)*100)*0.7)-(width),y=94-(height*4.5),r=128,g=128,b=128,width=width,height=height*4.5})
		regCubes(highGoal)

		local mediumGoal1=main:new("frame",{capacity=4,x=(((w/h)*100)*0.58)-(width),y=94-(height*3.5),r=128,g=128,b=128,width=width,height=height*3.5})
		regCubes(mediumGoal1)

		do
			local sections={}
			local nsections=0
			local sectionsenabled=true
			local x=(((w/h)*100)*0.46)-(width)
			local y=89-height
			local cubes={}
			local ncubes=0
			local updateCubes
			local updateSections

			-- skyrise base
			local sbase=base:new("frame",{
				x=((w/h)*46)-(width*1.1),y=-5,
				r=220,g=220,b=10,
				width=width*1.2,height=5,
				xclick=width*2,
				onClick=function(s)
					sectionsenabled=not sectionsenabled
					updateSections()
					vibrate()
				end,
				onDrag=function(s)
					if sectionsenabled and nsections==1 then
						nsections=0
						updateSections()
						vibrate()
					end
				end
			})
	
			function updateSections()
				local rncubes=math.min(ncubes,nsections+1)
				if ncubes==1 and nsections==0 then
					rncubes=0
				end
				if rncubes~=ncubes then
					ncubes=rncubes
					updateCubes()
				end
				sbase.r=sectionsenabled and 220 or 150
				sbase.g=sectionsenabled and 220 or 150
				sbase.b=sectionsenabled and 10 or 150
				for l1=1,7 do
					sections[l1].a=l1<=nsections and 255 or 0
					sections[l1].r=sectionsenabled and 220 or 150
					sections[l1].g=sectionsenabled and 220 or 150
					sections[l1].b=sectionsenabled and 10 or 150
				end
				updateScore()
			end
	
			-- cube base
			base:new("frame",{
				x=(x+(width/2))-(height/2),y=0,
				width=height,height=6,a=0,
				xclick=width,
				onDrag=function()
					if not sectionsenabled then
						if ncubes==1 then
							ncubes=0
							updateCubes()
							vibrate()
						end
					end
				end,
				onClick=function()
					sectionsenabled=not sectionsenabled
					updateSections()
					vibrate()
				end,
			})
	
			 -- skyrise sections
			for l1=1,7 do
				local section=main:new("frame",{
					layer=1,
					x=x,y=y,r=220,g=220,b=10,width=width,height=height,draw=drawSkyrise,
					color=c1r>c2r and "red" or "blue",
					onDrag=function(s)
						if sectionsenabled and ((nsections==0 and l1==1) or l1==nsections+1 or l1==nsections-1) then
							nsections=l1
							updateSections()
							vibrate()
							return true
						end
					end,
					onClick=function(s)
						if s.a==255 then
							sectionsenabled=not sectionsenabled
							updateSections()
							vibrate()
						end
					end,
					xclick=width*2,
				})
				table.insert(sections,section)
				table.insert(skyrises,section)
				y=y-height
			end
	
			-- skyrise cubes
			function updateCubes()
				local rnsections=math.max(nsections,ncubes-1)
				if rnsections~=nsections or (ncubes==1 and nsections==0) then
					nsections=rnsections
					updateSections()
				end
				for l1=1,ncubes do
					cubes[l1].a=255
				end
				for l1=ncubes+1,#cubes do
					cubes[l1].a=0
				end
				updateScore()
			end
			
			for l1=1,8 do
				local cube=main:new("frame",{
					layer=3,
					x=x+((width/2)-(height/2)),y=83-(height*(l1-1)),
					width=height,height=height,
					xclick=width,
					r=c1r,g=c1g,b=c1b,a=0,
					draw=drawCube,
					onDrag=function(s)
						if not sectionsenabled then
							if (ncubes==0 and l1==1) or l1==ncubes+1 or l1==ncubes-1 then
								if nsections==0 then
									nsections=1
									updateSections()
								end
								ncubes=l1
								updateCubes()
								vibrate()
								return true
							end
						end
					end,
				})
				table.insert(skyrisecubes,cube)
				table.insert(cubes,cube)
			end
	
			updateSections()
			
			function main.reset()
				ncubes=0
				nsections=0
				updateSections()
				updateCubes()
			end
		end

		local smallGoal1=main:new("frame",{restricted=true,capacity=2,x=(((w/h)*100)*0.34)-(width),y=94-(height*1.5),r=128,g=128,b=128,width=width,height=height*1.5})
		regCubes(smallGoal1)

		local mediumGoal2=main:new("frame",{capacity=4,x=(((w/h)*100)*0.22)-(width),y=94-(height*3.5),r=128,g=128,b=128,width=width,height=height*3.5})
		regCubes(mediumGoal2)

		local smallGoal2=main:new("frame",{capacity=2,x=(((w/h)*100)*0.1)-(width),y=94-(height*1.5),r=128,g=128,b=128,width=width,height=height*1.5})
		regCubes(smallGoal2)

		return main
	end
	
	local mwidth=(w/h)*23
	local menu=obj.new("frame",{
		layer=10,r=255,g=255,b=255,a=200,x=(w/h)*77,y=0,width=mwidth,height=100,

		onDown=function()
			return true
		end,
		onClick=function()
			return true
		end,
		onDrag=function()
			return true
		end,
	})
	
	scoringTextRed=menu:new("text",{
		x=0,y=5,
		size=mwidth/3.5,
		maxwidth=mwidth/2,
		r=clr_red[1],g=clr_red[2],b=clr_red[3],
		style="center",
		value="0",
	})
	
	scoringTextBlue=menu:new("text",{
		x=mwidth/2,y=5,
		size=mwidth/3.5,
		maxwidth=mwidth/2,
		r=clr_blue[1],g=clr_blue[2],b=clr_blue[3],
		style="center",
		value="0",
	})
	
	local scoreMenuButton=menu:new("frame",{
		x=0,y=0,
		width=mwidth,height=(mwidth/3.5)+10,
		a=0,
		onClick=function()
			vibrate()
			local menu=obj.new("frame",{
				layer=20,
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
				x=0,y=(bh/2)-(ts/2),
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
						"-Auton winner [ "..(score.autonWinner=="red" and "yes" or "no").." ]"
					local bluetext="Blue Teams:\n"..
						"-Skyrise:\n"..
						"--Sections [ "..score.blue.sections.." ]\n"..
						"--Cubes [ "..score.blue.sCubes.." ]\n"..
						"-Posts:\n"..
						"--Owned [ "..score.blue.owned.." ]\n"..
						"--Cubes [ "..score.blue.pCubes.." ]\n"..
						"-Floor goals [ "..score.blue.floor.." ]\n"..
						"-Auton winner [ "..(score.autonWinner=="blue" and "yes" or "no").." ]"
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
				x=0,y=(bh/2)-(ts/2),
				r=180,g=180,b=180,
				size=ts,
				maxwidth=bw,
				value="S",
				style="center",
			})
		end,
	})
	
	floorGoalCounter=menu:new("frame",{
		x=mwidth/8,y=36,
		width=mwidth-mwidth/4,height=12,
		r=20,g=20,b=20,
	}):new("text",{
		x=0,y=1,
		size=8,
		maxwidth=mwidth-mwidth/4,
		r=180,g=180,b=180,
		style="center",
		value="0",
	})
	
	local function updateCounter(v)
		if ccolor=="red" then
			rfloor=math.max(0,rfloor+v)
		else
			bfloor=math.max(0,bfloor+v)
		end
		floorGoalCounter.value=tostring(ccolor=="red" and rfloor or bfloor)
		updateScore()
		vibrate()
	end
	
	local floorGoalAdd=menu:new("frame",{
		x=mwidth/8,y=48,
		width=(mwidth*0.5)-mwidth/8,height=12,
		r=30,g=30,b=30,
		onClick=function()
			updateCounter(1)
			return true
		end,
	})
	floorGoalAdd:new("text",{
		x=0,y=2,
		size=6,
		maxwidth=(mwidth*0.5)-mwidth/8,
		r=180,g=180,b=180,
		style="center",
		value="+",
	})
	
	local floorGoalSub=menu:new("frame",{
		x=mwidth/2,y=48,
		width=(mwidth*0.5)-mwidth/8,height=12,
		r=30,g=30,b=30,
		onClick=function()
			updateCounter(-1)
			return true
		end,
	})
	floorGoalSub:new("text",{
		x=0,y=2,
		size=6,
		maxwidth=(mwidth*0.5)-mwidth/8,
		r=180,g=180,b=180,
		style="center",
		value="-",
	})
	
	local cubeColor="red"
	
	indicatorCube=obj.new("frame",{
		layer=10,
		x=2,y=2,
		width=15,height=15,
		draw=drawCube,
		r=180,g=20,b=20,
		xclick=7,
		yclick=7,
		onClick=function(s)
			if cubeColor=="red" then
				cubeColor="blue"
				s.r=19
				s.g=65
				s.b=190
			else
				cubeColor="red"
				s.r=180
				s.g=20
				s.b=20
			end
			vibrate()
			return true
		end
	})
	
	autonIndicator=obj.new("frame",{
		layer=10,
		x=((w/h)*77)-17,y=2,
		width=15,height=15,
		r=40,g=40,b=40,
		onClick=function(s)
			if not autonWinner or autonWinner~=ccolor then
				autonWinner=ccolor
			else
				autonWinner=nil
			end
			updateScore()
			vibrate()
			return true
		end,
	})
	
	redFrame=field(clr_red,clr_blue)
	blueFrame=field(clr_blue,clr_red)
	blueFrame.x=(w/h)*-100
	
	local function ud(s,dt)
		s.x=s.ex
	end
	
	local switchSideButton=menu:new("frame",{
		x=(mwidth/8),y=80,
		width=mwidth-(mwidth/4),height=12,
		r=20,g=20,b=20,
		onClick=function(s)
			if doneSwitching then
				doneSwitching=false
				if ccolor=="red" then
					redFrame.ex=(w/h)*100
					blueFrame.ex=0
					ccolor="blue"
				else
					redFrame.ex=0
					blueFrame.ex=(w/h)*100
					ccolor="red"
				end
				vibrate()
				floorGoalCounter.value=tostring(ccolor=="red" and rfloor or bfloor)
				return true
			end
		end,
		draw=function(s,u)
			graphics.rectangle("fill",u*s.realx,u*s.realy,u*s.width,u*s.height)
			graphics.setColor(180,180,180)
			graphics.setLineWidth(u*(s.height/8))
			graphics.setLineJoin("miter")
			local arw=s.height/1.5
			local sx=s.realx+(s.width/2)-(arw/2)
			local sy=s.realy+6
			graphics.line(u*sx,u*sy,u*(sx+arw),u*sy)
			graphics.line(u*(sx+(arw/2)),u*(sy-(s.height/4)),u*sx,u*sy,u*(sx+(arw/2)),u*(sy+(s.height/4)))
		end,
	})
end)

