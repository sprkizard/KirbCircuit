//=================================================================//
// GAME
// ---------
// contains main game functions (HP handling, controls, camera, etc)
//
//=================================================================//

--We need a camera that acts as 2D but still 3D
freeslot("MT_PLAYCAM", "S_PLAYCAM",
	"SPR_INHA",
	"S_PLAY_INHALE0",
	"S_PLAY_INHALE1",
	"S_PLAY_INHALE2",
	"S_PLAY_INHALE3",
	"S_PLAY_INHALE4",
	"S_PLAY_INHALED"
	
 )
states[S_PLAY_INHALE0] = {SPR_INHA,0,3,A_None,0,0,S_PLAY_INHALE1}
states[S_PLAY_INHALE1] = {SPR_INHA,1,3,A_None,0,0,S_PLAY_INHALE2}
states[S_PLAY_INHALE2] = {SPR_INHA,2,3,A_None,0,0,S_PLAY_INHALE3}
states[S_PLAY_INHALE3] = {SPR_INHA,3,1,A_None,0,0,S_PLAY_INHALE4}
states[S_PLAY_INHALE4] = {SPR_INHA,4,1,A_None,0,0,S_PLAY_INHALE3}
states[S_PLAY_INHALED] = {SPR_INHA,5,1,A_None,0,0,S_PLAY_INHALED}

--Drag an object towards a target object
local function P_GotoObject(thing, gotothing, speed)
	
	--Goto an object
	if (thing.valid) and (gotothing.valid)
		--Distance
		local dist = P_AproxDistance(P_AproxDistance(gotothing.x - thing.x,
		gotothing.y - thing.y),gotothing.z - thing.z)
		
		--Goto the current object at the set speed
		thing.momx = FixedMul(FixedDiv(gotothing.x - thing.x, dist), (speed*FRACUNIT))
		thing.momy = FixedMul(FixedDiv(gotothing.y - thing.y, dist), (speed*FRACUNIT))
		thing.momz = FixedMul(FixedDiv(gotothing.z - thing.z, dist), (speed*FRACUNIT))

		--if (dist > 786*FRACUNIT)
		--end
	end	
end

-------------------
--State looper
--Loops states
--from start to last
--------------------
local function P_LoopState(mobj, start, last)
	if not (mobj.state >= start)
	and (mobj.state <= last)
		mobj.state = start
	end
end
------------------------------
-------------------
--Loops sprites from a range at set speed
--------------------
local function P_SpriteLoop(mo,firstf,lastf,speed)
	-- Frame Cycle
	if (leveltime % speed == 0)
		mo.frame = $1+1
	end
	if (mo.frame > lastf)
		mo.frame = firstf
	end
end
------------------------------

////////////////////////////
-- Player Camera
////////////////////////////
mobjinfo[MT_PLAYCAM] = {
	doomednum = -1,
	spawnhealth = 8,
	spawnstate = S_PLAYCAM,
	speed = 8, 
	radius = 32*FRACUNIT,
	height = 32*FRACUNIT,
	damage = 0,
	mass = 0,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP
}

//States go in this Order
//Sprite,Frame,Tics,Action,var1,var2,nextstate
states[S_PLAYCAM] = {SPR_RING,0,-1,A_None,0,0,S_PLAYCAM}
-----------------------------------------------------------

--[[local function P_CapeTeleportMove(mo, chaser, foff_x, foff_y, f_angle, boff_x, boff_y, b_angle, z)
	
	
	local foffsetx = P_ReturnThrustX(chaser, chaser.angle-f_angle, FixedMul(foff_x*FRACUNIT, chaser.scale))
	local foffsety = P_ReturnThrustY(chaser, chaser.angle-f_angle, FixedMul(foff_y*FRACUNIT, chaser.scale))

	local boffsetx = P_ReturnThrustX(chaser, chaser.angle-b_angle, FixedMul(boff_x*FRACUNIT, chaser.scale))
	local boffsety = P_ReturnThrustY(chaser, chaser.angle-b_angle, FixedMul(boff_y*FRACUNIT, chaser.scale))
	
	P_TeleportMove(mo, 
	chaser.x-foffsetx+boffsetx,
	chaser.y-foffsety+boffsety,
	chaser.z+z)
end]]--

//Camera thinker
addHook("MobjThinker", function(mo)
	//A_CapeChase(mo,0+32, 0+0)
	if (mo.target.valid)
		--P_CapeTeleportMove(mo, mo.target, 200, -200, 0, 0, 228, ANGLE_180, 32*FRACUNIT)
		P_TeleportMove(mo, 
		mo.target.x,
		mo.target.y-240*FRACUNIT,
		mo.target.z+64*FRACUNIT)
		mo.angle = ANGLE_90
		
	end
	
end, MT_PLAYCAM)



//=================//
--Map Load code
--When the map loads init everything
//=================//
addHook("MapLoad", do
	for player in players.iterate do
		player.inhaling = false
		player.floating = false
		player.runtic = 4
		player.sidedown = false
		player.toruncount = 0
		player.running = true
		player.inhaletime = 0
		player.objectinhaled = false
		--[[player.isFull = false
		player.inAir = false
		player.squishTimer = 3
		player.canJump = true
		player.jumpTimer = 0
		player.fallTimer = -1
		player.wasRunning = false
		player.puffTimer = 0
		player.canPuff = false
		player.puffSpitTimer = 8
		player.unPuffTimer = 15
		player.stateJustChanged = false
		player.emitPuff = false
		player.efPuffTimer = 2
		player.noStepSound = false
		holdPower = powerNone
		havePower = powerNone]]--
	end
end)


//=================//
--Gameplay code
//=================//
addHook("ThinkFrame", do
	
	for player in players.iterate

		--We need a custom camera that's 2D but still 3D
		if (player.health) and not (player.mo.cam)
			player.mo.cam = P_SpawnMobj(player.mo.x,
								player.mo.y, 
								player.mo.z,
								MT_PLAYCAM)
			--Wee setting up the camera					
			player.mo.cam.target = player.mo
			player.awayviewmobj = player.mo.cam		
			player.awayviewtics = 99*TICRATE

		end
		
		//=================//
		//   
		//     Controls
		//
		//=================//
		//Looks like we need to remake the movement code...
		
		
		//Set to strafe only, nice 2D effect
		player.pflags = $1|PF_FORCESTRAFE
		//Cut off normalspeed (restore it later?)
		player.normalspeed = 0
		
		if (player.facingleft == nil)
			player.facingleft = false
		end
		
		//For short access
		local forwardmove = player.cmd.forwardmove
		local sidemove = player.cmd.sidemove
		
		//Facing left changes the sprite angle left, or right
		if (player.facingleft == true)
			player.mo.angle = ANGLE_180
		else
			player.mo.angle = 0
		end
		

		
		//Left/Right
		//Moving Right
		if (sidemove > 0) 
			player.mo.angle = 0
			P_InstaThrust(player.mo, 0, 6*FRACUNIT)
			player.facingleft = false
		//Moving Left
		elseif (sidemove < 0) 
			player.mo.angle = ANGLE_180
			player.facingleft = true
			P_InstaThrust(player.mo, ANGLE_180, 6*FRACUNIT)
		end
		
		//Moving Forward
		if (forwardmove > 0) 
			P_InstaThrust(player.mo, ANGLE_90, 6*FRACUNIT)
		 //Moving Backwards
		elseif (forwardmove < 0)
			P_InstaThrust(player.mo, -ANGLE_90, 6*FRACUNIT)
		end
		
		//Upright Downleft
		//Moving UpRight
		if (forwardmove > 0) and (sidemove > 0) 
			P_InstaThrust(player.mo, ANGLE_45, 6*FRACUNIT)
		//Moving DownLeft
		elseif (forwardmove < 0) and (sidemove < 0) 
			P_InstaThrust(player.mo, FixedAngle(-145*FRACUNIT), 6*FRACUNIT)
		end
		//Moving UpLeft
		if (forwardmove > 0) and (sidemove < 0)
			P_InstaThrust(player.mo, FixedAngle(145*FRACUNIT), 6*FRACUNIT)
		//Moving DownRight
		elseif (forwardmove < 0) and (sidemove > 0)
			P_InstaThrust(player.mo, FixedAngle(-45*FRACUNIT), 6*FRACUNIT)
		end
		
		
		--[[
		--Running
		
		if (sidemove > 0) and (player.sidedown == false)
			player.toruncount = $1+1
			player.sidedown = true
			if (player.toruncount == 2)
				player.running = true
			end
		elseif (sidemove < 0) and (player.sidedown == false)
			player.toruncount = $1+1
			player.sidedown = true
			if (player.toruncount == 2)
				player.running = true
			end
		end
		if (player.running == true)
			if ((sidemove > 0) or (sidemove < 0))
			or ((forwardmove > 0) or (forwardmove < 0))
			
			P_InstaThrust(player.mo, player.mo.angle, 17*FRACUNIT)
			--P_LoopState(player.mo, S_PLAY_SPD1, S_PLAY_SPD4)
			P_SpriteLoop(player.mo,16,19,6)
			end
		end
		if not ((sidemove > 0) or (sidemove < 0))
			player.sidedown = false
			if (player.speed == 0)
				player.toruncount = 0
				player.running = false
				player.runtic = 4
				player.running = false
			end
		end]]--
		//------------------------------------------------//
		
		
		--Inhale an enemy
		
		if (player.cmd.buttons & BT_USE) and not (player.objectinhaled)
			for	enemy_inhaled in thinkers.iterate("mobj")
				--ONLY ENEMIES, NOT BOSSES (until they die that is)
				if (enemy_inhaled.flags & MF_ENEMY)	
				local dist = P_AproxDistance(P_AproxDistance(
								enemy_inhaled.x - player.mo.x,
								enemy_inhaled.y - player.mo.y),
								enemy_inhaled.z - player.mo.z)
								
					if (dist < 256*FRACUNIT)
					--Drag enemy to you
					P_GotoObject(enemy_inhaled, player.mo, 25)
					end
				end
			end
			player.inhaletime = $1+1
			player.inhaling = true
			player.mo.momx = 0
			player.mo.momy = 0
			
		end
		
		if (player.inhaling == true) and (player.inhaletime < 2)
			player.mo.state = S_PLAY_INHALE0
			--TODO: can a single state switch be done easily?
		end
		--Turn inhaling off? dunno
		if not (player.cmd.buttons & BT_USE)
			if (player.inhaling == true)
				player.inhaling = false
				player.mo.state = S_PLAY_STND
			end
			player.inhaletime = 0
		end
		--Check to make sure holding the button doesnt make you continue
		if (player.cmd.buttons & BT_USE) and (player.objectinhaled == true)
			
			player.objectinhaled = false
		end
	end
	
end)

--Enemy (etc) Suction handler
addHook("MobjCollide", function(mo, tmthing)
	if (mo.player.inhaling == true)
	
		if (tmthing.flags & MF_ENEMY)	
			
				P_KillMobj(tmthing, mo, mo)
			
			--TODO: do i really need another sprite to load instead?	
			mo.player.mo.state = S_PLAY_INHALED
			
			mo.player.inhaling = false
			mo.player.objectinhaled = true
			mo.player.cmd.buttons = $1 & ~BT_USE
		end
	
	end
return true
end,MT_PLAYER)


--Well I need to view these variables somehow?
--[[local function draw_test(v, stplyr)
	--v.drawPaddedNum(56, 56, stplyr.health, 2, 0)
	v.drawString(56, 56, "Sidemove: "+stplyr.cmd.sidemove, 0)
	v.drawString(56, 66, "ForwardMove: "+stplyr.cmd.forwardmove, 0)
	v.drawString(56, 76, "Runtic: "+stplyr.runtic, 0)
	v.drawString(56, 86, "Runcount: "+stplyr.toruncount, 0)
	v.drawString(56, 96, "Run: "+stplyr.running, 0)
	v.drawString(56, 106, "Sidedown: "+stplyr.sidedown, 0)
	v.drawString(56, 116, "SPR: "+stplyr.mo.sprite, 0)
	v.drawString(56, 126, "Inhaletime: "+stplyr.inhaletime, 0)
	--v.drawString(56, 136, "Direction: "+stplyr.direction, 0)

end
hud.add(draw_test)]]--

