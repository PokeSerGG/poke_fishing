Inventory = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent('poke_fishing:caughtFish')
AddEventHandler('poke_fishing:caughtFish', function(fish, weight)
	local _source = source
	Inventory.addItem(_source, fish['name'], 1)
end)

RegisterServerEvent('poke_fishing:CheckItems')
AddEventHandler('poke_fishing:CheckItems', function(k, v)
	local _source = source
	local count = Inventory.getItemCount(_source, "fishingrod")
	local count2 = Inventory.getItemCount(_source, "bait")
	if count > 0 then 
		if count2 > 0 then
			Inventory.subItem(_source, "bait", 1)
			TriggerClientEvent('poke_fishing:StartFishing', _source, k, v)
		else
			TriggerClientEvent("vorp:Tip", _source, _U('more_bait'), 3000)
		end
	else
		TriggerClientEvent("vorp:Tip", _source, _U('need_fishingrod'), 3000)
	end
end)

RegisterServerEvent('poke_fishing:breakFishingRod')
AddEventHandler('poke_fishing:breakFishingRod', function()
	local _source = source
	Inventory.subItem(_source, "fishingrod", 1)
end)

RegisterServerEvent('poke_fishing:sellFish')
AddEventHandler('poke_fishing:sellFish', function()
	local _source = source
	local cash = 0
	local foundFish = false
	for k,v in pairs(Config.Fishes) do
		local item = Inventory.getItemCount(_source, k)
		if item > 0 then
			foundFish = true
			cash = cash + (Config.Fishes[k]['price'] * item)
			Inventory.subItem(_source, k, item)
		end
	end
	if foundFish then
		Wait(100)
		TriggerEvent("vorp:addMoney", _source, 0, cash)
		TriggerClientEvent("vorp:Tip", _source, _U('you_sell', cash), 5000)
	else
		TriggerClientEvent("vorp:Tip", _source, _U('dont_have'), 3000)
	end
end)