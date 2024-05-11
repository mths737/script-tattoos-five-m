resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "template/index.html"

files {
    "template/index.html",
	"template/style.css"
}

client_scripts { 
	"@vrp/lib/utils.lua",
	"client.lua",
	"cfg/tattoos.lua"
}

server_scripts { 
	"@vrp/lib/utils.lua",
	"server.lua"
}