local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRPts = {}
Tunnel.bindInterface("tattoos",vRPts)
Proxy.addInterface("tattoos",vRPts)
vCLIENT = Tunnel.getInterface("tattoos")

local cfg = module("tattoos","cfg/tattoos")

function vRPts.getId()
    local source = source
    local id = vRP.getUserId(source)
    return id
end

function vRPts.pedDecoration(id)
    local pedDecoration = vRP.getUData(id, 'vRP:tattoos')
    return pedDecoration
end

function vRPts.oldCustom()
    local user_id = vRP.getUserId(source)
    local old_custom = {}
    local data = vRP.getUData(user_id,"vRP:tattoos")
	if type(data) == 'string' then
		old_custom = json.decode(data)
    else
        old_custom = {}
	end
    return old_custom
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		if user_id then
			local custom = {}
			local data = vRP.getUData(user_id,"vRP:tattoos")
			if data then
				custom = json.decode(data)
				vCLIENT.setTattoos(source,custom)
			end
		end
	end
end)

function vRPts.tatuar()
    local source = source
    local old_custom = vRPts.oldCustom()
    local user_id = vRP.getUserId(source)
    local custom = vCLIENT.getTattoos(source)
	local price = 0
	for k,v in pairs(custom) do
		local old = old_custom[k]
		if not old then price = price + 500 end
	end
    
    if vRP.tryPayment(user_id,price) then
        vRP.setUData(user_id,"vRP:tattoos",json.encode(custom))
        if price > 0 then
            TriggerClientEvent("Notify",source,"sucesso","Pagou <b>$"..price.." dólares</b>.")
        end
    else
        TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.")
        vCLIENT.setTattoos(source,old_custom)
    end
end