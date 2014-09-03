//=================================================================//
// HUD
// ---------
// contains main HUD functions. (HP, icons, etc)
//
//=================================================================//

--Borrowing from terminal
function A_MServ_floatFixed(src)
        if src == nil then return nil end
        if not src:find("^-?%d+%.%d+$") then -- Not a float!
                if tonumber(src) then
                        return tonumber(src)*FRACUNIT
                else
                        return nil
                end
        end
        local decPlace = src:find("%.")
        local whole = tonumber(src:sub(1, decPlace-1))*FRACUNIT
        local dec = src:sub(decPlace+1)
        local decNumber = tonumber(dec)*FRACUNIT
        for i=1,dec:len() do
                decNumber = $1/10
        end
        if src:find("^-") then
                return whole-decNumber
        else
                return whole+decNumber
        end
end

--[[local function V_DrawMeter(v, x,y, maxval, value, skip, gfx_1, flags1,gfx_2,flags2)
-- Ending segment first
	//v.draw(posx, posy, p_endseg, V_SNAPTOTOP|V_SNAPTORIGHT)
	x = $1 + 8

	-- Step through backwards, to match the way we're drawing.
	for i = maxval, 1, -1
		if value >= i
			v.draw(x, y, gfx_1, flags1)
		else
			v.draw(x, y, gfx_2, flags2)
		end
		x = $1 + skip;
	end
end

local function V_DrawInverseMeter(v, x,y, maxval, value, skip, gfx_1, flags1,gfx_2,flags2)
-- Ending segment first
	//v.draw(posx, posy, p_endseg, V_SNAPTOTOP|V_SNAPTORIGHT)
	x = $1 - 23

	-- Step through backwards, to match the way we're drawing.
	for i = maxval, 1, -1
		if value >= i
		v.drawScaled(x<<FRACBITS, y<<FRACBITS, A_MServ_floatFixed("0.6"), gfx_1, flags1)
			//v.draw(x, y, gfx_1, flags1)
		else
		v.drawScaled(x<<FRACBITS, y<<FRACBITS, A_MServ_floatFixed("0.6"), gfx_2, flags2)
			//v.draw(x, y, gfx_2, flags2)
		end
		x = $1 - skip;
	end
end]]--

//========================//
//   Draw the main HUD
//========================//
local function draw_kirbyui(v, stplyr)

	--Custom drawn graphic for holder
	local kirby_hpbar = v.cachePatch("KBAR") 
	--Temporary player icon
	--local kirby_iconnormal = v.cachePatch("KICON") 
	--Face icon
	local face_icon = v.cachePatch("FACE_ICO")
	
	--Max HP
	local HPmax  = 100; 
	--HP holder Position X
	local k_posx = 38 
	--HP holder Position Y
	local k_posy = 182 
	--Blue hp graphic
	local k_blue = v.cachePatch("KHPBLUE")
	--Grey HP graphic
	local k_grey  = v.cachePatch("KHPGREY")
	
	--HP variable for quick access
	local HP = stplyr.health-1 

	--TODO: account for 100HP to fit inside the graphic without splitting it :/
	--TODO: support for 100HP, not 153..
	--[[if (HP <= 100)
	//for i = 0,153,2
	for i = 0, 100, 1
		if (stplyr.health+53 > i)
        v.draw(k_posx, k_posy, k_blue, 0)
		else
		v.draw(k_posx, k_posy, k_grey, 0)
		end
		k_posx = $1 + 1;
	end
		
	end]]--
	
	//========================================//
	--HP handler code
	--(stupid overdone hp code)
	--Game cannot fit it into the bar so split like
	--[Below 50 | Above 50]
	
	--HP range from 0 to 50
	if (HP <= 100)
		for i = 0, 50, 1
			if (stplyr.health > i)
			v.draw(k_posx, k_posy, k_blue, 0)
			else
			v.draw(k_posx, k_posy, k_grey, 0)
			end
			k_posx = $1 + 1;
		end
	end
	--HP range from 50 to 100
	local b_posx = 88
	local b_posy = 182
	if (HP <= 100)
		for i = 50, 100, 2
			if (stplyr.health > i)
			v.draw(b_posx, b_posy, k_blue, 0)
			else
			v.draw(b_posx, b_posy, k_grey, 0)
			end
			b_posx = $1 + 1;
		end
	end
	//========================================//
	
	//============//
	// Face Icons //
	//============//
	--Draw these last
	--Face Icons!
	//if not (powerlist)
	v.draw(3+2, 162+2, face_icon, 0)//, //V_70TRANS|V_SCALEPATCHMASK) --Change this into the player icon soon.. I suppose
	//elseif
	//Traditional
	//if (player.power.fire == true)
	//if (player.power.wheel == true)
	//if (player.power.needle == true)
	//if (player.power.spark == true)
	//if (player.power.wing == true)
	//if (player.power.sword == true)
	//if (player.power.parasol == true)
	//if (player.power.stone == true)
	//if (player.power.hammer == true)
	//if (player.power.bomb == true)
	//if (player.power.beam == true)
	//if (player.power.fighter == true)
	//if (player.power.cutter == true)
	//if (player.power.ice == true)
	
	//Special
	//if (player.power.mike == true)
	//if (player.power.crash == true)
	//if (player.power.UFO == true) --nahhhh
	
	//SuperStar
	//if (player.power.mirror == true)
	//if (player.power.yoyo == true)
	//if (player.power.ninja == true)
	
	//NEW
	//if (player.power.whip == true)
	//if (player.power.spear == true)
	//if (player.power.leaf == true)
	//if (player.power.archer == true)
	//if (player.power.beetle == true)
	//if (player.power.bell == true)
	//if (player.power.HYPERNOVA == true)
	
	--Custom graphic for HP and icons (just like Triple Deluxe!)
	v.draw(3, 162, kirby_hpbar, 0)
	
	
	--Old HP Code
	--Draw HP Based on low
	--[[V_DrawInverseMeter(v, k_posx, k_posy,
	HPmax,//-FixedInt(15*FRACUNIT-FRACUNIT/2), //Position fix
	stplyr.health, 1,//-FixedInt(2*FRACUNIT-FRACUNIT/2), 1, 
	k_blue, 0, k_grey, 0)]]--
	
end
hud.add(draw_kirbyui)

