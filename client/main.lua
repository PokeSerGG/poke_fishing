local active = false
local SellPrompt
local hasAlreadyEnteredMarker, lastZone
local currentZone = nil

function PromptSetup()
    Citizen.CreateThread(function()
        local str = _U('sell_fish')
        SellPrompt = PromptRegisterBegin()
        PromptSetControlAction(SellPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(SellPrompt, str)
        PromptSetEnabled(SellPrompt, false)
        PromptSetVisible(SellPrompt, false)
        PromptSetHoldMode(SellPrompt, true)
        PromptRegisterEnd(SellPrompt)
    end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

        if currentZone then
            if active == false then
                PromptSetEnabled(SellPrompt, true)
                PromptSetVisible(SellPrompt, true)
                active = true
            end
            if PromptHasHoldModeCompleted(SellPrompt) then
				if currentZone == 'sell' then
                    TriggerServerEvent('poke_fishing:sellFish')
                    PromptSetEnabled(SellPrompt, false)
                    PromptSetVisible(SellPrompt, false)
                    active = false
				end

				currentZone = nil
			end
        else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('poke_fishing:hasEnteredMarker', function(zone)
	currentZone = zone
end)

AddEventHandler('poke_fishing:hasExitedMarker', function(zone)
    if active == true then
        PromptSetEnabled(SellPrompt, false)
        PromptSetVisible(SellPrompt, false)
        active = false
    end
	currentZone = nil
end)

Citizen.CreateThread(function()
    PromptSetup()
	while true do
		Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
		local isInMarker, currentZone = false

		for k = 1, #Config.LocationsToSell do
			local ShopCoords = vector3(Config.LocationsToSell[k]["x"], Config.LocationsToSell[k]["y"], Config.LocationsToSell[k]["z"])
			local distance = #(coords - ShopCoords)
			if distance < 1.5 then
				isInMarker  = true
				currentZone = 'sell'
				lastZone    = 'sell'
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('poke_fishing:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('poke_fishing:hasExitedMarker', lastZone)
		end
	end
end)

Citizen.CreateThread(function()
	PromptSetup()
	while true do
		local sleepThread = 1000
		if not fishing then
			local playerPed = PlayerPedId()
			local coords    = GetEntityCoords(playerPed, true)
			for k,v in pairs(Config.Locations) do
				local distance = GetDistanceBetweenCoords(coords, v['x'], v['y'], v['z'], true)
				if distance < 15.0 then
					sleepThread = 5
					if distance < 1.0 then
						DrawText3D(v['x'], v['y'], v['z'], _U('press_to_fish'))
						if IsControlJustReleased(0, 0xD9D0E1C0) then
							TriggerServerEvent('poke_fishing:CheckItems', k, v)
						end
					end
				end
			end
		end
		Citizen.Wait(sleepThread)
	end
end)

RegisterNetEvent('poke_fishing:StartFishing')
AddEventHandler('poke_fishing:StartFishing', function(k, v)
	StartFishing(k, v)
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.Locations) do
		local blip = N_0x554d9d53f696d002(1664425300, v['x'], v['y'], v['z'])
		SetBlipSprite(blip, -852241114, 1)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, _U('fishing_blip'))
	end
	for k,v in pairs(Config.LocationsToSell) do
		local blip2 = N_0x554d9d53f696d002(1664425300, v['x'], v['y'], v['z'])
		SetBlipSprite(blip2, -1575595762, 1)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip2, _U('sell_blip'))
	end
end)

StartFishing = function(location, data)
	local fishes = {}
	local randomWait = math.random(800, 4000) 
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, true)
	local boneIndex = GetEntityBoneIndexByName(playerPed, "SKEL_R_HAND")
	local modelHash = GetHashKey("p_fishingpole01x")
	local count = 1
	local catchPeriod = 1000
	local failure = 500
	local msg = ''
	local dic = "amb_work@world_human_stand_fishing@male_b@base"
	local anim = "base"
	for k,v in pairs(data['fishes']) do
		Citizen.Wait(5)
		table.insert(fishes, Config.Fishes[v])
	end
	SetEntityHeading(playerPed, data["h"])
	loadAnimDict(dic)
	local entity = CreateObject(modelHash, coords.x+0.3, coords.y,coords.z, true, false, false)
    AttachEntityToEntity(entity, playerPed, boneIndex, 0.1, -0.1, -0.0, -66.0, -0.2, -0.2, false, false, false, true, 2, true)
	TaskPlayAnim(playerPed, dic, anim, 1.0, 8.0, -1, 1, 0, false, false, false)
	fishing = true
	while fishing do
		if randomWait > 0 then
			count = count + 1
			if count >= 100 then 
				count = 1
				msg = _U('fishing', '..')
			elseif count >= 75 then 
				msg = _U('fishing', '...')
			elseif count >= 50 then
				msg = _U('fishing', '..')
			elseif count >= 25 then
				msg = _U('fishing', '.')
			end
			randomWait = randomWait - 1
		elseif catchPeriod > 0 and randomWait <= 0 then
			catchPeriod = catchPeriod - 1
			msg = _U('press_to_catch')
			DrawTxt(_U('fish_rod_bends'), 0.4, 0.25, 0.4, 0.4, true, 255, 255, 255, 150, false)
		elseif failure > 0 then
			failure = failure - 1
			if failure == 1 then
				local breakChance = math.random(1, 100)
				if breakChance == 1 then
					x = 0.700
					msg = _U('fishing_broke')
					TriggerServerEvent('poke_fishing:breakFishingRod')
				else
					msg = 'El pez se escapó...'
				end
			else
				msg = 'El pez se escapó...'
			end
		else
			fishing = false
			ClearPedTasks(playerPed)
			DeleteObject(entity)
		end
		if IsControlJustReleased(0, 0xC7B5340A) then
			fishing = false
			ClearPedTasks(playerPed)
			DeleteObject(entity)
			if randomWait <= 0 and catchPeriod > 0 then 
				GetFishProbability(fishes)
			end
		elseif IsControlJustReleased(0, 0x8CC9CD42) then
			fishing = false
			ClearPedTasks(playerPed)
			DeleteObject(entity)
		end
		DrawTxt(msg, 0.40, 0.3, 0.4, 0.4, true, 255, 255, 255, 150, false)
		Citizen.Wait(5)
	end
end

GetFishProbability = function(fishes)
	local defaultFish = Config.Fishes['mackerel']
	local rNbr = math.random()
	local baseVal = 0
	local turn = 0
	for name, fish in pairs(fishes) do
		turn = turn + 1
		baseVal = baseVal + fish['value']
		if rNbr <= baseVal then
			local weight = math.random(fish['weight'][1], fish['weight'][2])
			TriggerEvent("vorp:Tip", _U('you_fishing', fish['label'], weight), 3000)
			TriggerServerEvent('poke_fishing:caughtFish', fish, weight)
			break
		elseif turn == 6 then
			local weight = math.random(defaultFish['weight'][1],defaultFish['weight'][2])
			TriggerEvent("vorp:Tip", _U('you_fishing', defaultFish['label'], weight), 3000)
			TriggerServerEvent('poke_fishing:caughtFish', defaultFish, weight)
        end
	end
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 52, 52, 52, 190, 0)
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    --Citizen.InvokeNative(0x66E0276CC5F6B9DA, 2)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end
