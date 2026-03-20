let deathTimer = null;
let timeRemaining = 0;
let maxTime = 300; // 5 minuti di default

// Mostra la schermata di morte
function showDeathScreen(duration = 300) {
    const deathScreen = document.getElementById('deathScreen');
    deathScreen.classList.remove('hidden');
    
    maxTime = duration;
    timeRemaining = duration;
    
    updateTimer();
    startTimer();
}

// Nascondi la schermata di morte
function hideDeathScreen() {
    const deathScreen = document.getElementById('deathScreen');
    deathScreen.classList.add('hidden');
    
    if (deathTimer) {
        clearInterval(deathTimer);
        deathTimer = null;
    }
}

// Avvia il timer
function startTimer() {
    if (deathTimer) {
        clearInterval(deathTimer);
    }
    
    deathTimer = setInterval(() => {
        timeRemaining--;
        
        if (timeRemaining <= 0) {
            timeRemaining = 0;
            clearInterval(deathTimer);
            deathTimer = null;
            // Notifica al gioco che il tempo è scaduto
            sendToGame('timeExpired');
        }
        
        updateTimer();
    }, 1000);
}

// Aggiorna il display del timer
function updateTimer() {
    const minutes = Math.floor(timeRemaining / 60);
    const seconds = timeRemaining % 60;
    const timeString = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    
    document.getElementById('timerValue').textContent = timeString;
}

// Invia messaggi al gioco (LUA)
function sendToGame(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).catch(() => {
        // Ignora errori in modalità preview
    });
}

// Helper per ottenere il nome della risorsa
function GetParentResourceName() {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const resourceName = urlParams.get('resource');
    return resourceName || 'un_misc';
}

// Ascolta i messaggi dal gioco
window.addEventListener('message', (event) => {
    const data = event.data;
    const respawnHint = document.getElementById('respawnHint');
    switch (data.action) {
        case 'showDeath':
            showDeathScreen(data.duration || 300);
            break;
            
        case 'hideDeath':
            hideDeathScreen();
            respawnHint.style.display = 'flex';
            respawnHint.innerHTML = '<span>Premi</span><span class="key-badge">SHIFT + SPAZIO</span><span>per chiamare i medici</span>';
            break;
            
        case 'callMedics':
            respawnHint.style.display = 'none';
        break;

        case 'endtimer':
            respawnHint.style.display = 'flex';
            respawnHint.innerHTML = '<span>Premi</span><span class="key-badge">SHIFT + E</span><span>per respawnare</span>';
        break;

        case 'updateTimer':
            timeRemaining = data.time;
            updateTimer();
        break;
            
        case 'ShowBanUI':
            // Converti i minuti in secondi
            showBanArmiUI(data.time * 60, data.reason);
            break;
            
        case 'UpdateBanTime':
            // Converti i minuti in secondi
            banTimeRemaining = data.time * 60;
            updateBanTimer();
            updateBanProgressBar();
            break;
            
        // case 'HideBanUI':
        //     hideBanArmiUI();
        //     break;
    }
});

// Tasti premuti
document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        // Previeni la chiusura accidentale
        event.preventDefault();
    }
});

// Test automatico (DISABILITATO - solo per FiveM)
// setTimeout(() => showDeathScreen(300), 100);

/* ========================================
   BAN ARMI FUNCTIONS
   ======================================== */

let banTimer = null;
let banTimeRemaining = 0;
let banMaxTime = 0;

// Mostra la UI del ban armi
function showBanArmiUI(timeInSeconds, reason) {
    const banScreen = document.getElementById('banArmiScreen');
    const banReasonElement = document.getElementById('banReason');
    
    banScreen.classList.remove('hidden');
    
    if (reason && reason.trim() !== '') {
        banReasonElement.textContent = reason;
    } else {
        banReasonElement.textContent = 'BASE';
    }
    
    banMaxTime = timeInSeconds;
    banTimeRemaining = timeInSeconds;
    
    updateBanTimer();
    updateBanProgressBar();
}

// Nascondi la UI del ban armi
function hideBanArmiUI() {
    const banScreen = document.getElementById('banArmiScreen');
    banScreen.classList.add('hidden');
    
    if (banTimer) {
        clearInterval(banTimer);
        banTimer = null;
    }
}

// Aggiorna il timer del ban
function updateBanTimer() {
    // Arrotonda per evitare decimali nei secondi
    const totalSeconds = Math.floor(banTimeRemaining);
    
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = Math.floor(totalSeconds % 60);
    
    const timeString = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    
    document.getElementById('banTimerValue').textContent = timeString;
}

// Aggiorna la barra di progresso del ban
function updateBanProgressBar() {
    const progressBar = document.getElementById('banProgressBar');
    const percentage = banMaxTime > 0 ? (banTimeRemaining / banMaxTime) * 100 : 0;
    progressBar.style.width = percentage + '%';
}


const menuItems = [
    { name: "Documenti Personali", icon: "fa-solid fa-file", action: () => emit('un:personal_docs') },
    { name: "Gestione Radio", icon: "fa-solid fa-walkie-talkie", action: () => emit('un:banca') },
    { name: "Chiama Taxi", icon: "fa-solid fa-taxi", action: () => emit('un:gestione_attivita') },
    { name: "Cambia Lavoro", icon: "fa-solid fa-user", action: () => emit('un:editor') },
    { name: "Rockstar Editor", icon: "fa-solid fa-video-camera", action: () => emit('un:rockstar_editor') },
    { name: "Report", icon: "fa-solid fa-circle-info", action: () => emit('un:report')}
];

let selectedIndex = 0;
let menuVisible = false;

function emit(eventName) {
    fetch(`https://${GetParentResourceName()}/${eventName}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function renderMenu() {
    const menu = document.getElementById("circle-menu");

    if (menu.children.length === 0) {
        menuItems.forEach((item, index) => {
            const div = document.createElement("div");
            div.className = "menu-item" + (index === selectedIndex ? " active" : "");

            const numLabel = String(index + 1).padStart(2, '0');
            div.innerHTML = `
                <div class="item-icon-wrapper">
                    <i class="${item.icon}"></i>
                </div>
                <div class="item-content">
                    <span class="item-name">${item.name}</span>
                </div>
                <span class="item-index">${numLabel}</span>
                <div class="item-arrow"><i class="fa-solid fa-chevron-right"></i></div>
            `;

            div.addEventListener("click", () => item.action());
            menu.appendChild(div);

            setTimeout(() => div.classList.add("appear"), 70 * index);
        });
    } else {
        [...menu.children].forEach((el, idx) => {
            el.classList.toggle("active", idx === selectedIndex);
        });
    }
}

window.addEventListener('message', function (event) {
    const data = event.data;
    if (data.action === "toggleMenu") {
        menuVisible = data.show;
        const menuWrapper = document.querySelector('.menu-wrapper');

        if (menuVisible) {
            selectedIndex = 0;
            renderMenu();
            menuWrapper.style.display = "block";
            setTimeout(() => {
                menuWrapper.classList.add("visible");
            }, 10);
        } else {
            menuWrapper.classList.remove("visible");
            setTimeout(() => {
                menuWrapper.style.display = "none";
            }, 500);
        }
    }
});

document.addEventListener("keydown", (e) => {
    if (!menuVisible) return;

    if (e.key === "ArrowUp") {
        selectedIndex = (selectedIndex - 1 + menuItems.length) % menuItems.length;
        renderMenu();
    }

    if (e.key === "ArrowDown") {
        selectedIndex = (selectedIndex + 1) % menuItems.length;
        renderMenu();
    }

    if (e.key === "Enter") {
        menuItems[selectedIndex].action();
    }

    if (e.key === "Escape" || e.key === "Backspace") {
        fetch(`https://${GetParentResourceName()}/un:closeMenu`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        menuVisible = false;
        const menuWrapper = document.querySelector('.menu-wrapper');
        menuWrapper.classList.remove("visible");
        setTimeout(() => {
            menuWrapper.style.display = "none";
        }, 500);
    }
});
