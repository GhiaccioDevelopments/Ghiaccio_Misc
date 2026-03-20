local ESX = exports["es_extended"]:getSharedObject()

local function OpenDocumentiPersonali() 
    ESX.TriggerServerCallback("documentiPersonali", function(data)
        local opt =  {
            {
                title = "Nome: " .. data.nome,
                icon = "fa-solid fa-id-card",
            },
            {
                title = "Lavoro Attivo: " .. data.lavoroAttivo .. " | " .. data.lavoroGrado,
                description = "clicca per modificare...",
                onSelect = function() 
                    exports["un_multiJobs"]:ShowJobMenu()
                end,
                icon = "fa-solid fa-briefcase",
            },
            {
                title = "Soldi Contanti: $" .. data.soldiContanti,
                icon = "fa-solid fa-money-bill-wave",
            },
            {
                title = "Soldi in Banca: $" .. data.soldiBanca,
                icon = "fa-solid fa-university",
            }
        }
        if data.numerodiTelefono then
            table.insert(opt, {
                title = "Numero di Telefono: " .. data.numerodiTelefono,
                icon = "fa-solid fa-phone",
            })
        end
        lib.registerContext({
            id = "documenti_personali",
            title = "Documenti Personali",
            options = opt
        })
        lib.showContext("documenti_personali")
    end)
end

exports("documenti_personali", OpenDocumentiPersonali)