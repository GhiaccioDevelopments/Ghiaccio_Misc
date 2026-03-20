Config = {}

Config.fpsCommand = "fps"

Config.Locali = {
    ["vanilla"] = { -- METTERE IL JOB NAME
        cucina = { 
            pos = vec3(132.5913, -1286.5905, 29.2726), 
            fornelliPos = vec4(129.3734, -1283.9531, 29.2740, 130.3559),
            marker = {type = 20, scale = vec3(0.5, 0.5, 0.5), color = {r = 0, g = 160, b = 2, a = 100}}
        },
        cambioBuonoPasto = { 
            pos = vec3(132.0465, -1290.5311, 29.2695), 
            marker = {type = 2, scale = vec3(0.5, 0.5, 0.5), color = {r = 0, g = 0, b = 0, a = 255}},
            minGrade = 0, -- GRADO MINIMO PER VEDERE IL MARKER E INTERAGIRE
            moneyPerBuono = 1500, -- QUANTI SOLDI DA DARE PER OGNI BUONO PASTO
        },
        import = {
            pos = vec3(10.1042, -1100.3934, 29.7972),
            marker = {type = 2, scale = vec3(0.5, 0.5, 0.5), color = {r = 0, g = 0, b = 0, a = 100}},
            itemsRequest = {
                {item = "farina", label = "Farina"},
                {item = "water", label = "Acqua"},
                {item = "luppolo", label = "Luppolo"},
                -----------------------add-----------------------
            }
        },
        menu = {
            cibi = {
                ["burger"] = {
                    label = "Burger",
                    icon = "fa-solid fa-burger",
                    ingredients = {
                        {label = "Burger", item = "burger"},
                        {label = "Acqua", item = "water"},
                    },
                }
            },
            bevande = {
                ["birra"] = {
                    label = "Birra",
                    icon = "fa-solid fa-beer-mug-empty",
                    ingredients = {
                        {label = "Acqua", item = "water"},
                        {label = "Luppolo", item = "luppolo"},
                    },
                }
            }
        },
    }, -- AGGIUNGI LOCALI
}

Config.importJobName = "import"
Config.SendNotifyToImportEmployee = true
Config.ImportPos = {
    ["armeria200"] = { -- job name
        pos = vec3(10.1042, -1100.3934, 29.7972),
        marker = {type = 2, scale = vec3(0.5, 0.5, 0.5), color = {r = 0, g = 0, b = 0, a = 100}},
        itemsRequest = {
            {item = "ferro", label = "Ferro", icon = "https://i.ibb.co/ds4FRfkV/ferro.png", price = 10},
            {item = "legna", label = "Legna", icon = "https://i.ibb.co/pqG1VJk/legna.png", price = 5},
            {item = "nastroadesivo", label = "Nastro Adesivo", icon = "https://i.ibb.co/Fq6PWNbm/nastroadesivo.png", price = 2},
            -----------------------add-----------------------
        },
        minGrade = 3, -- GRADO MINIMO PER VEDERE IL MARKER E INTERAGIRE
    }
}

---

-- FULL STATUS

Config.PrezzoFullStats = 3500
Config.MarkerCibi = {
    {pos = vec3(44.2676, -997.9899, 29.3362)},
    {pos = vec3(1139.5355, -463.9802, 66.8576)},
    {pos = vec3(783.1329, -2253.8813, 29.4631)},
    {pos = vec3(-528.5320, -1784.5302, 21.5836)},
    {pos = vec3(-827.2219, -696.8768, 28.0566)}
}



Config.PuliziaProp = "v_ret_fh_washmach"
Config.Puliziasoldi = {
    JobAllowed = {
        "cartello"
    },
    label = "Pulisci Soldi",
    icon = "fa-solid fa-hand-sparkles",
}

--- DROGHE

Config.Droghe = {
    Raccolta = {
        ["marijuana"] = {
            method = "marker", -- "ox_target" o "marker" o "ped"
            pedmodel = "a_m_m_skater_01", -- SOLO SE METHOD = "PED"
            itemLabel = "Marijuana", -- Label dell'item da scrivere, esempio: "Stai raccogliendo Marijuana..."
            label = "Raccogli Marijuana", -- COSA ESCE NEL MARKER O NELL'OX_TARGET
            icon = "fa-solid fa-leaf",

            pos = vec4(1383.2030, 2171.8440, 97.9490 - 1, 85.9042), -- SE IL METODO E' PED, CAMBIARE QUESTE COORDINATE
            markerPos = vec3(1383.2404, 2172.1816, 97.9400), -- SE IL METODO E' MARKER o OX_TARGET, CAMBIARE QUESTE COORDINATE !! SE IL METODO E' PED LASCIARE VUOTO !!

            marker = {type = 2, color = {r = 0, g = 0, b = 0, a = 100}}, -- SOLO SE METHOD = "MARKER"
            raccoltaLoop = true, -- se true, il giocatore clicca una volta e raccoglie in automatico
            itemname = "water", -- NOME DELL'ITEM DA DARE AL COMPLETAMENTO DELLA RACCOLTA
            count = {
                num = "random", -- numero / "random" -- Quantità da dare al completamento della raccolta, se è "random", il numero sarà randomico tra count.Min e count.Max
                min = 1, -- Quantità minima da dare se count.num = "random"
                max = 5, -- Quantità massima da dare se count.num = "random"
                val = 0, -- NON TOCCARE, serve per il conteggio interno, deve essere 0
            },
            progress = {
                position = "bottom", -- "middle" o "bottom"
                label = "Raccogliendo Marijuana...", -- Label del progress
                tempodiraccolta = 5 * 1000, -- cambiare il primo numero (Secondi)
                useWhileDead = false,
                allowRagdoll = false,
                allowSwimming = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = true,
                anim = {
                    dict = "amb@world_human_gardener_plant@male@idle_a",
                    clip = "idle_a"
                },
                prop = {
                    model = `prop_weed_01`,
                    pos = vec3(0.0, 0.0, 0.0),
                    rot = vec3(0.0, 0.0, 0.0)
                },
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    mouse = false,
                    sprint = true,
                }
            },
            blip = {
                show = true,
                name = "Raccolta Marijuana",
                sprite = 140,
                color = 2,
                scale = 0.5,
            }
        },
        -- add
    },
    Processo = {
        ["cannabis"] = {
            method = "marker", -- "marker" o "ox_target"
            itemLabel = "Cannabis", -- Label dell'item da scrivere, esempio: "Stai processando Cannabis..."
            label = "Processa Cannabis", -- COSA ESCE NEL MARKER O NELL'OX_TARGET
            icon = "fa-solid fa-leaf",
            pos = vec3(2663.0510, 1443.6960, 20.8224), -- Posizione
            marker = {type = 2, color = {r = 0, g = 0, b = 0, a = 100}},
            ricetta = {
                {item = "water", label = "Acqua", count = 1},
                {item = "burger", label = "Burger", count = 1}
            },
            itemname = "paperbag", -- NOME DELL'ITEM DA DARE AL COMPLETAMENTO DEL PROCESSO
            count = 1, -- Quantità da dare al completamento del processo
            processoLoop = false, -- se true, il giocatore clicca una volta e processa in automatico
            progress = {
                position = "bottom", -- "middle" o "bottom"
                label = "Processando Cannabis...", -- Label del progress
                tempodiprocesso = 5 * 1000, -- cambiare il primo numero (Secondi)
                useWhileDead = false,
                allowRagdoll = false,
                allowSwimming = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = true,
                anim = {
                    dict = "bunk_int-26",
                    clip = "mp_m_weapwork_01^2_dual-26"
                },
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    mouse = false,
                    sprint = true,
                }
            },
            blip = {
                show = false,
                name = "Processo Cannabis",
                sprite = 140,
                color = 2,
                scale = 0.5,
            }
        },
        -- add
    }
}

---

Config.Giubotti = {
    ["armeria200"] = {
        method = "marker", -- "marker" o "ox_target"
        pos = vec3(4.8602, -1108.9531, 29.7972), -- posizione del marker o dell'ox_target
        marker = {type = 41, color = {r = 0, g = 0, b = 0, a = 100}}, -- SOLO SE METHOD = "MARKER"
        icon = "fa-solid fa-shield-halved",
        textUiLabel = "Acquista Giubotto Antiproiettile",
        haveToPay = true, -- se true, il giocatore deve pagare per comprare il giubbotto, se false, il giubbotto è gratuito
        blip = {
            show = true,
            name = "Giubotto Antiproiettile",
            sprite = 175,
            color = 1,
            scale = 0.6,
        },
        showMenu = true, -- SE TRUE, mostrerà il menu, se comprare un giubotto 50% o 75% o 100%-- SE FALSE PRENDE GIUBBO 100% SENZA MOSTRARE MENU
        menu = {
            ["50"] = {
                label = "Giubotto 50%",
                price = 2000, -- PREZZO DEL GIUBOTTO
            },
            ["75"] = {
                label = "Giubotto 75%",
                price = 3000, -- PREZZO DEL GIUBOTTO
            },
            ["100"] = {
                label = "Giubotto 100%",
                price = 4000, -- PREZZO DEL GIUBOTTO
            }
        },
        progress = {
            position = "bottom", -- "middle" o "bottom"
            label = "Indossando Giubotto Antiproiettile...", -- Label del progress
            tempoIndossamento = 5 * 1000, -- cambiare il primo numero (Secondi)
            useWhileDead = false,
            allowRagdoll = false,
            allowSwimming = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            anim = {
                dict = "anim_heist@hs3f@ig12_change_clothes@",
                clip = "action_01_male"
            },
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
                sprint = true,
            }
        },
        jobPayment = {
            enabled = true, -- Se l'azienda riceve i soldi nel conto oppure li toglie solamente al player
            jobName = "armeria200", -- Nome della azienda che riceve i soldi, se jobPayment.enabled = false, non serve
        },
        permission = {
            enabled = false, -- Se può accedere solamente chi ha il job
            jobPerms = "police", -- Nome del job che può accedere, se permission.enabled = false, non serve
        }
    },
    ["police"] = {
        method = "ox_target", -- "marker" o "ox_target"
        pos = vec3(469.5898, -996.5530, 26.2737), -- posizione del marker o dell'ox_target
        marker = {type = 41, color = {r = 0, g = 0, b = 0, a = 100}}, -- SOLO SE METHOD = "MARKER"
        icon = "fa-solid fa-shield-halved",
        textUiLabel = "Indossa Giubotto Antiproiettile",
        haveToPay = false, -- se true, il giocatore deve pagare per comprare il giubbotto, se false, il giubbotto è gratuito
        blip = {
            show = false,
            name = "Giubotto Antiproiettile",
            sprite = 110,
            color = 1,
            scale = 0.5,
        },

        showMenu = false, -- SE TRUE, mostrerà il menu, se comprare un giubotto 50% o 75% o 100%-- SE FALSE PRENDE GIUBBO 100% SENZA MOSTRARE MENU
        menu = {
            ["50"] = {
                label = "Giubotto 50%",
                price = 2000, -- PREZZO DEL GIUBOTTO
            },
            ["75"] = {
                label = "Giubotto 75%",
                price = 3000, -- PREZZO DEL GIUBOTTO
            },
            ["100"] = {
                label = "Giubotto 100%",
                price = 4000, -- PREZZO DEL GIUBOTTO
            }
        },
        progress = {
            position = "bottom", -- "middle" o "bottom"
            label = "Indossando Giubotto Antiproiettile...", -- Label del progress
            tempoIndossamento = 5 * 1000, -- cambiare il primo numero (Secondi)
            useWhileDead = false,
            allowRagdoll = false,
            allowSwimming = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            anim = {
                dict = "anim_heist@hs3f@ig12_change_clothes@",
                clip = "action_01_male"
            },
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
                sprint = true,
            }
        },
        jobPayment = {
            enabled = false, -- Se l'azienda riceve i soldi nel conto oppure li toglie solamente al player
            jobName = "armeria200", -- Nome della azienda che riceve i soldi, se jobPayment.enabled = false, non serve
        },
        permission = {
            enabled = true, -- Se può accedere solamente chi ha il job
            jobPerms = "police", -- Nome del job che può accedere, se permission.enabled = false, non serve
        }
    },
    -- add
}


----------- ASCENSORI -------------
Config.UseMarker = true
Config.UseTarget = false
Config.BlackScreentime = 1 * 1000 -- DURATA PER IL BLACK SCREEN COMPLETO -- modificare 1
Config.FadeInTrans = 1 * 1000 -- DURATA RIPRESA SCREEN NORMALE COMPLETA -- modificare 1
Config.NeedToBeAlive = true -- Il giocatore deve essere vivo per accedere all'ascensore?

Config.Elevators = {
    ["police_elevator"] = {         -- mettete il nome che volete
        coordinateAscensori = {
            {piano = "Garage", coords = vector3(467.5204, -992.4981, 26.2735)},
            {piano = "Tetto", coords = vector3(463.7781, -982.1892, 43.6916)}, --ETC....
        }
    }
}








ConfigDJ = {}
ConfigDJ.Debug = true -- If you want debug in console
ConfigDJ.DefaultVolume = 0.1 -- Accepted values are 0.01 - 1
ConfigDJ.Distance = 5.0 -- Dont touch this

--- Target system ---
ConfigDJ.ox_target = true -- If you want to use qtarget you need also polyzone script

--- Locations ---
ConfigDJ.Locations = {
    {
        onlyJob = true, -- If false then everyone can access the location
        job = 'vanilla', -- if onJob true, you have to write the name of that job here like 'vanilla'
        name = 'Vanilla', -- Name of zone
        coords = vec3(120.7297, -1281.1974, 29.4805), -- Coordinates where menu will appear if you are nearby
        radius = 80, -- Playing music distance (radius)
        distance = 2.5, -- Menu appear distance
        isPlaying = false -- Dont touch this!!!!
    },
}

ConfigDJ.Language = {
    ['openMenu'] = '[E] - Apri menu console',
    ['titleMenu'] = '💿 | DJ Pult',
    ['playSong'] = '🎶 | Riproduci una canzone',
    ['playSongDesc'] = 'Inserisci un URL di YouTube',
    ['pauseMusic'] = '⏸️ | Metti in pausa',
    ['pauseMusicDesc'] = 'Metti in pausa la musica in riproduzione',
    ['resumeMusic'] = '▶️ | Riprendi la musica',
    ['resumeMusicDesc'] = 'Riprendi la riproduzione della musica in pausa',
    ['changeVolume'] = '🔈 | Cambia Volume',
    ['changeVolumeDesc'] = 'Cambia il volume della canzone',
    ['stopMusic'] = '❌ | Ferma la musica',
    ['stopMusicDesc'] = 'Ferma la musica e scegli una nuova canzone',
    ['songSel'] = 'Selezione canzone',
    ['url'] = 'URL YouTube',
    ['musicVolume'] = 'Volume musica',
    ['musicVolumeNm'] = 'Min: 0.01 - Max: 1', -- Pls dont change numbers (0.01 - 1)

    --- Playlist ---
    ['playlistMenu'] = '🎶 | DJ Pult Playlist',
    ['playlistDesc'] = 'Riproduci una canzone dalla playlist',
    ['playlistMenuTitle'] = '🎶 | Riproduci una canzone'
}

ConfigDJ.Playlist = {
    --- Prima canzone
    ['first'] = '💿 | Mess', -- Nome della prima canzone
    ['desc_first'] = 'Bass Boosted Song', -- Descrizione della canzone
    ['music_first_id'] = 'https://www.youtube.com/watch?v=-Kjrf-pxQc4', -- Url da YT

    --- Seconda canzone ---
    ['second'] = '💿 | Shiver', -- Nome della seconda canzone
    ['desc_second'] = 'Bass Boosted Song water effect',
    ['music_second_id'] = 'https://www.youtube.com/watch?v=NdUNtHqY5r8',

    --- Terza canzone ---
    ['third'] = '💿 | Good With It', -- Nome della terza canzone
    ['desc_third'] = 'Bass Boosted Song (chill)', -- Descrizione della canzone
    ['music_third_id'] = 'https://www.youtube.com/watch?v=RInypZYiiDM',

    --- Quarta canzone ---
    ['fourth'] = '💿 | Back To You',
    ['desc_fourth'] = 'Chill song',
    ['music_fourth_id'] = 'https://www.youtube.com/watch?v=rrzHAoA-oRI',

    --- Quinta canzone ---
    ['fifth'] = '💿 | Curse',
    ['desc_fifth'] = 'Bass Boosted Song 2',
    ['music_fifth_id'] = 'https://www.youtube.com/watch?v=XsmuiDRKbDk'
}

