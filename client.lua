local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRPts = {}
Tunnel.bindInterface("tattoos",vRPts)
Proxy.addInterface("tattoos",vRPts)
vSERVER = Tunnel.getInterface('tattoos')

local cfg = module("tattoos","cfg/tattoos")

custom = {}
lista = {}

local onNui = false
local acao = nil
local marker = nil

function vRPts.setTattoos(data)
	ClearPedDecorations(PlayerPedId())
	if data then
		custom = data
	end
end

function vRPts.addTattoo(tattoo,store)
	ClearPedDecorations(PlayerPedId())
	if tattoo and store then
		custom[tattoo] = { store }
	end
end

function vRPts.delTattoo(tattoo)
	ClearPedDecorations(PlayerPedId())
	if tattoo then
		custom[tattoo] = nil
	end
end

function vRPts.getTattoos()
	return custom
end

function vRPts.cleanPlayer()
	ClearPedDecorations(PlayerPedId())
	custom = {}
end

RegisterNetEvent('reloadtattoos')
AddEventHandler('reloadtattoos',function()
	if custom then
		ClearPedDecorations(PlayerPedId())
		for k,v in pairs(custom) do
			SetPedDecoration(PlayerPedId(),GetHashKey(v[1]),GetHashKey(k))
		end
	end
end)

function DrawTxt(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.45)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)

    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.400, 0.855)
end

RegisterNetEvent('tattoos:showMenu')
AddEventHandler('tattoos:showMenu',function()
    old_custom = vSERVER.oldCustom()
    onNui = not onNui
    SetNuiFocus(true, true)
    SendNUIMessage({
        show = true
    })
end)

RegisterNetEvent('tattoos:hideMenu')
AddEventHandler('tattoos:hideMenu',function()
    acao = DrawTxt("PRESSIONE ~b~E")
    onNui = not onNui
    SetNuiFocus(false)
    SendNUIMessage({
        show = false
    })
end)

RegisterNUICallback("cancelar", function(data)
    custom = vSERVER.oldCustom()
    TriggerEvent('reloadtattoos')
    TriggerEvent("Notify",'Negado',"MODIFICAÇÕES CANCELADAS.")
    TriggerEvent('tattoos:hideMenu')
    disableCam()
end)

RegisterNUICallback("tatuar", function(data)
    vSERVER.tatuar()
    TriggerEvent('tattoos:hideMenu')
    onNui = false
    disableCam()
end)

RegisterNUICallback("escolha", function(data)
    escolha = data.parte

    if escolha == "limpar" then
        local ok = SendNUIMessage({
            opcoes = 'limpar'
        })
    else
        local lista = Lista(escolha)
        custom = vRPts.getTattoos()
        TriggerEvent('reloadtattoos')
        SendNUIMessage({
            opcoes = lista
        })
    end
end)

RegisterNUICallback("desenho", function(data)
    if data.modo == 'marcar' then
        local id= vSERVER.getId()
        local pedDecoration = vSERVER.pedDecoration(id)
        local ped_dec = GetPedDecorations(PlayerPedId())
        local collection = overlay(data.hash, data.indice)

        if type(collection) ~= 'string' then
            vRPts.addTattoo(data.hash, collection[1])
            vRPts.addTattoo(data.hash, collection[2])
            TriggerEvent('reloadtattoos')
        else
            vRPts.addTattoo(data.hash, collection)
            TriggerEvent('reloadtattoos')
            custom[data.hash] = {collection}
            for k,v in pairs(custom) do
                print(k, table.unpack(v))
            end

            for k,v in pairs(lista) do
                if lista[k][3] == data.hash then
                    lista[k][4] = true
                end
                print(table.unpack(lista[k]))
            end
        end
    elseif data.modo == 'desmarcar' then
        vRPts.delTattoo(data.hash)
        TriggerEvent('reloadtattoos')
    end

end)

RegisterNUICallback("request", function(arg)
    if arg.request == 's' then
        disableCam()
        cleanPlayer()
        TriggerEvent("Notify","sucesso","LIMPEZA CONCLUIDA.")
        TriggerEvent('tattoos:hideMenu')
        vSERVER.tatuar()
        onNui = false
    elseif arg.request == 'n' then
        TriggerEvent("Notify","negado","LIMPEZA CANCELADA.")
        local lista = Lista('head')
        SendNUIMessage({
            opcoes = lista
        })
    end
end)

function Lista(escolha)
    lista = {}
    ordem = 0
    for k, v in pairs(cfg.tattoos) do
        for x, z in pairs(v) do
            if escolha == "head" then
                if k == "ZONE_HEAD" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            if escolha == "torso" then
                if k == "ZONE_TORSO" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            if escolha == "right_arm" then
                if k == "ZONE_RIGHT_ARM" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            if escolha == "left_arm" then
                if k == "ZONE_LEFT_ARM" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            if escolha == "right_leg" then
                if k == "ZONE_RIGHT_LEG" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            if escolha == "left_leg" then
                if k == "ZONE_LEFT_LEG" and x ~= '_config' then
                    opc = {[x] = {z}}
                    table.insert(lista, {ordem, x, z[1]})
                end
            end

            for k,v in pairs(lista) do
                if v[1] == 0 then
                    local chave = v[2]
                    v[1] = tonumber(string.sub(chave,10,-1))
                end
            end
        end
    end

    table.sort(lista, function(value1, value2) return value1[1] < value2[1] end)

    local old_custom = vSERVER.oldCustom()

    for l, b in pairs(lista) do
        lista[l][4] = false
        for k,v in pairs(old_custom) do
            if lista[l][3] == k then
                lista[l][4] = true
            end
        end
    end

    return lista
end

function cleanPlayer()
	ClearPedDecorations(PlayerPedId())
	custom = {}
end

function overlay(hash, indice)
    local hash = hash
    local collection
    if string.sub(hash, 0, 7) == 'MP_Airr' then
        collection = 'mpairraces_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_MP_B' then
        collection = 'mpbiker_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_Xmas' then
        collection = 'mpchristmas2_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_Gunr' then
        collection = 'mpgunrunning_overlays'
    elseif string.sub(hash, 0, 7) == 'FM_Hip_' then
        collection = 'mphipster_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_MP_I' then
        collection = 'mpimportexport_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_LR_T' then
        collection = {'mplowrider_overlays' , 'mplowrider2_overlays'}
    elseif string.sub(hash, 0, 7) == 'MP_LUXE' then
        collection = {'mpluxe_overlays', 'mpluxe2_overlays'}
    elseif string.sub(hash, 0, 7) == 'MP_Smug' then
        collection = 'mpsmuggler_overlays'
    elseif string.sub(hash, 0, 7) == 'MP_MP_S' then
        collection = 'mpstunt_overlays'
    elseif string.sub(hash, 0, 7) == 'FM_Tat_' then
        collection = 'multiplayer_overlays'
    end
    return collection
end

-- {"MP_MP_ImportExport_Tat_009_M":["mpimportexport_overlays"],"MP_MP_ImportExport_Tat_004_F":["mpimportexport_overlays"],"MP_MP_ImportExport_Tat_007_F":["mpimportexport_overlays"]}

function VerDist(x, y, z)
    local player = PlayerPedId()
    local pcoords = GetEntityCoords(player)
    local dist = GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, x, y, z , true)
    return dist
end

CreateThread(function()
	while true do
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)
        for k, v in pairs(cfg.shops) do
            x, y, z = table.unpack(v)
            local dist = VerDist(x, y, z)
            if dist < 3.5 and dist > 2.5 then
                DrawMarker(1, x, y, z-2, 0, 0, 0, 0.0, 0, 0.0, 2.0, 2.0, 2.0, 255, 0, 255, 90, true, true, 2, nil, nil, false)
            end
            if dist < 2.5 and dist > 1.5 then
                DrawMarker(1, x, y, z-2, 0, 0, 0, 0.0, 0, 0.0, 2.0, 2.0, 2.0, 255, 0, 255, 65, true, true, 2, nil, nil, false)
            end
            if dist < 1.5 and dist > 1 then
                DrawMarker(1, x, y, z-2, 0, 0, 0, 0.0, 0, 0.0, 2.0, 2.0, 2.0, 255, 0, 255, 40, true, true, 2, nil, nil, false)
            end
            if dist < 1 then
                DrawMarker(1, x, y, z-2, 0, 0, 0, 0.0, 0, 0.0, 2.0, 2.0, 2.0, 255, 0, 255, 15, true, true, 2, nil, nil, false)
            end
        end
        Wait(1)
	end
end)

CreateThread(function()
    while true do
        
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)
        for k, v in pairs(cfg.shops) do
            x, y, z = table.unpack(v)
            local dist = VerDist(x, y, z)
            if dist < 1 and onNui == false then
                acao = DrawTxt("PRESSIONE ~b~E")
                if IsControlJustPressed(0, 38) then
                    local lista = Lista('head')
                    custom = vSERVER.oldCustom()
                    TriggerEvent('reloadtattoos')
                    --[[custom = vSERVER.oldCustom()
                    for k,v in pairs(custom) do
                        --print(k,v)
                        for l, b in pairs(lista) do
                            if lista[l][3] == k then
                                lista[l][4] = true
                            else 
                                lista[l][4] = false
                            end
                        end
                    end]]
                    TriggerEvent('tattoos:showMenu')
                    enableCam()
                    SendNUIMessage({
                        opcoes = lista,
                        open = true
                    })
                end
            end
            if dist < 1 and onNui == true then
                acao = nil
                marker = nil
            end
        end
        Wait(1)
    end
end)


local cam = -1

function enableCam()
	local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0,2.0,0)
	RenderScriptCams(false,false,0,1,0)
	DestroyCam(cam,false)

	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
		SetCamActive(cam,true)
		RenderScriptCams(true,false,0,true,true)
		SetCamCoord(cam,coords.x,coords.y,coords.z+0.1)
		SetCamRot(cam,0.0,0.0,GetEntityHeading(PlayerPedId())+180)
	end

	if customCamLocation ~= nil then
		SetCamCoord(cam,customCamLocation.x,customCamLocation.y,customCamLocation.z)
	end
end

RegisterNUICallback("setupCam",function(data)
	local value = data.value

	if value == 1 then
        enableCam()
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0,0.75,0)
		SetCamCoord(cam,coords.x,coords.y,coords.z+0.65)
	elseif value == 2 then
        enableCam()
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0,1.0,0)
		SetCamCoord(cam,coords.x,coords.y,coords.z+0.2)
	elseif value == 3 then
        enableCam()
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0,1.0,0)
		SetCamCoord(cam,coords.x,coords.y,coords.z+-0.5)
	else
        enableCam()
		local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0,2.0,0)
		SetCamCoord(cam,coords.x,coords.y,coords.z+0.1)
	end
end)

function disableCam()
	RenderScriptCams(false,true,250,1,0)
	DestroyCam(cam,false)
end

RegisterNUICallback("rotateRight",function()
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	SetEntityHeading(ped,heading+30)
end)

RegisterNUICallback("rotateLeft",function()
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	SetEntityHeading(ped,heading-30)
end)