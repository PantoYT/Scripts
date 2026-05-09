# =============================================================================
#  setup.ps1 - Master Dev Setup
#  Uruchom jako Administrator w PowerShell:
#  Set-ExecutionPolicy Bypass -Scope Process -Force; .\setup.ps1
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"

# --- Kolory do logowania ---
function Log-Step  { param($msg) Write-Host "`n===> $msg" -ForegroundColor Cyan }
function Log-OK    { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Log-Skip  { param($msg) Write-Host "  [--] $msg (juz istnieje, pomijam)" -ForegroundColor DarkGray }
function Log-Warn  { param($msg) Write-Host "  [!!] $msg" -ForegroundColor Yellow }

# --- Sprawdz uprawnienia ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host "Uruchom skrypt jako Administrator!" -ForegroundColor Red
    exit 1
}

# =============================================================================
#  1. WINGET - aktualizacja zrodla
# =============================================================================
Log-Step "Aktualizacja winget..."
winget source update | Out-Null

# Helper - instaluje przez winget tylko jesli jeszcze nie ma
function Install-Winget {
    param($id, $name)
    $check = winget list --id $id 2>$null | Select-String $id
    if ($check) { Log-Skip $name }
    else {
        winget install --id $id --silent --accept-package-agreements --accept-source-agreements
        Log-OK $name
    }
}

# =============================================================================
#  2. APLIKACJE GUI (winget)
# =============================================================================
Log-Step "Instalacja aplikacji GUI..."

Install-Winget "Microsoft.VisualStudioCode"   "VS Code"
Install-Winget "Git.Git"                       "Git"
Install-Winget "Python.Python.3"               "Python 3"
Install-Winget "OpenJS.NodeJS.LTS"             "Node.js LTS"
Install-Winget "Oracle.JDK.21"                 "Java JDK 21"
Install-Winget "Microsoft.PowerToys"           "PowerToys"
Install-Winget "ApacheFriends.Xampp.8.2"       "XAMPP 8.2"
Install-Winget "Notepad++.Notepad++"           "Notepad++"
Install-Winget "7zip.7zip"                     "7-Zip"
Install-Winget "Microsoft.WindowsTerminal"     "Windows Terminal"
Install-Winget "Postman.Postman"               "Postman"

# =============================================================================
#  3. SCOOP - CLI tools
# =============================================================================
Log-Step "Instalacja Scoop..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod get.scoop.sh -OutFile "$env:TEMP\install-scoop.ps1"
    & "$env:TEMP\install-scoop.ps1" -RunAsAdmin
    $env:Path += ";$env:USERPROFILE\scoop\shims"
    Log-OK "Scoop zainstalowany"
} else {
    Log-Skip "Scoop"
}

Log-Step "Instalacja CLI tools przez Scoop..."

$scoopTools = @(
    "git",
    "mingw",
    "cmake",
    "ripgrep",
    "bat",
    "fzf",
    "lazygit",
    "wget",
    "7zip",
    "composer"
)

scoop bucket add extras 2>$null | Out-Null
scoop bucket add main   2>$null | Out-Null

foreach ($tool in $scoopTools) {
    $check = scoop list $tool 2>$null | Select-String $tool
    if ($check) { Log-Skip $tool }
    else {
        scoop install $tool
        Log-OK $tool
    }
}

# =============================================================================
#  4. PATH - dodawanie sciezek systemowych
# =============================================================================
Log-Step "Konfiguracja PATH..."

function Add-ToPath {
    param($newPath, $label)
    if (-not (Test-Path $newPath)) { Log-Warn "Sciezka nie istnieje: $newPath ($label)"; return }
    $current = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($current -like "*$newPath*") { Log-Skip "PATH: $label" }
    else {
        [System.Environment]::SetEnvironmentVariable("Path", "$current;$newPath", "Machine")
        Log-OK "PATH dodany: $label ($newPath)"
    }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Add-ToPath "C:\xampp\php"         "PHP (XAMPP)"
Add-ToPath "C:\xampp\mysql\bin"   "MySQL (XAMPP)"
Add-ToPath "C:\xampp\apache\bin"  "Apache (XAMPP)"

$scoopMingw = "$env:USERPROFILE\scoop\apps\mingw\current\bin"
Add-ToPath $scoopMingw "MinGW (Scoop)"

# =============================================================================
#  5. WSL + UBUNTU
# =============================================================================
Log-Step "WSL + Ubuntu..."
$wslCheck = wsl --list 2>$null | Select-String "Ubuntu"
if ($wslCheck) {
    Log-Skip "WSL Ubuntu"
} else {
    Log-Warn "Instalacja WSL wymaga restartu. Uruchom po restarcie: wsl --install -d Ubuntu"
    wsl --install -d Ubuntu --no-launch
    Log-OK "WSL Ubuntu zainstalowany (wymagany restart)"
}

# =============================================================================
#  6. VS CODE EXTENSIONS
# =============================================================================
Log-Step "VS Code extensions..."

$env:Path += ";$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Log-Warn "VS Code nie znaleziony w PATH - extensions trzeba zainstalowac recznie po restarcie"
} else {
    $extensions = @(
        # Python
        "ms-python.python",
        "ms-python.debugpy",
        "ms-python.vscode-pylance",
        "ms-python.vscode-python-envs",

        # C / C++
        "ms-vscode.cpptools",
        "ms-vscode.cpptools-extension-pack",
        "ms-vscode.cpptools-themes",

        # Java
        "vscjava.vscode-java-pack",

        # Web / PHP / Laravel
        "bmewburn.vscode-intelephense-client",
        "amiralizadeh9480.laravel-extra-intellisense",
        "onecentlin.laravel-blade",
        "onecentlin.laravel5-snippets",
        "codingyu.laravel-goto-view",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "ritwickdey.liveserver",
        "formulahendry.auto-rename-tag",
        "zignd.html-css-class-completion",
        "vincaslt.highlight-matching-tag",

        # Git
        "eamodio.gitlens",

        # Database
        "damms005.devdb",
        "mtxr.sqltools",
        "mtxr.sqltools-driver-mysql",

        # Dotnet / Unity
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "ms-dotnettools.vscode-dotnet-runtime",
        "visualstudiotoolsforunity.vstuc",

        # Remote / WSL
        "ms-vscode-remote.remote-wsl",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-containers",

        # Jakosc i wyglad
        "oderwat.indent-rainbow",
        "vscode-icons-team.vscode-icons",
        "ahmadawais.shades-of-purple",
        "aykutsarac.jsoncrack-vscode",
        "tomoki1207.pdf",

        # Misc
        "ms-vscode.powershell",
        "xdebug.php-debug",
        "icrawl.discord-vscode"
    )

    $installedExts = code --list-extensions 2>$null

    foreach ($ext in $extensions) {
        if ($installedExts -contains $ext) {
            Log-Skip $ext
        } else {
            code --install-extension $ext --force 2>$null
            Log-OK $ext
        }
    }
}

# =============================================================================
#  7. PYTHON PACKAGES
# =============================================================================
Log-Step "Python packages (pip)..."

python -m pip install --upgrade pip --quiet

$pipPackages = @(
    "numpy",
    "pandas",
    "matplotlib",
    "seaborn",
    "pillow",
    "opencv-python",
    "pygame-ce",
    "requests",
    "beautifulsoup4",
    "selenium",
    "httpx",
    "flask",
    "fastapi",
    "uvicorn",
    "openai",
    "pydantic",
    "python-dotenv",
    "PyMySQL",
    "gTTS",
    "pyttsx3",
    "pydub",
    "SpeechRecognition",
    "click",
    "tqdm",
    "colorlog",
    "schedule",
    "psutil",
    "watchdog",
    "GitPython",
    "APScheduler",
    "questionary",
    "discord.py",
    "pyserial",
    "yt-dlp"
)

$installedPip = python -m pip list --format=columns 2>$null | ForEach-Object { ($_ -split "\s+")[0].ToLower() }

foreach ($pkg in $pipPackages) {
    if ($installedPip -contains $pkg.ToLower()) {
        Log-Skip $pkg
    } else {
        python -m pip install $pkg --quiet
        Log-OK $pkg
    }
}

# =============================================================================
#  8. NODE.JS - globalne paczki
# =============================================================================
Log-Step "Node.js globalne paczki..."

$nodePackages = @(
    "npm@latest",
    "nodemon",
    "typescript",
    "ts-node",
    "live-server"
)

foreach ($pkg in $nodePackages) {
    $name = $pkg -replace "@latest", ""
    $check = npm list -g $name 2>$null | Select-String $name
    if ($check) { Log-Skip $pkg }
    else {
        npm install -g $pkg --silent 2>$null
        Log-OK $pkg
    }
}

# =============================================================================
#  9. GIT - podstawowa konfiguracja
# =============================================================================
Log-Step "Git konfiguracja..."

$gitName  = git config --global user.name  2>$null
$gitEmail = git config --global user.email 2>$null

if (-not $gitName) {
    $inputName = Read-Host "  Podaj imie i nazwisko do Git (np. Jan Kowalski)"
    git config --global user.name $inputName
    Log-OK "git user.name ustawiony"
} else { Log-Skip "git user.name ($gitName)" }

if (-not $gitEmail) {
    $inputEmail = Read-Host "  Podaj email do Git"
    git config --global user.email $inputEmail
    Log-OK "git user.email ustawiony"
} else { Log-Skip "git user.email ($gitEmail)" }

# =============================================================================
#  9b. WINDOWS QUALITY OF LIFE
# =============================================================================
Log-Step "Windows QoL tweaks..."

function Set-Reg {
    param($path, $name, $value, $type = "DWord", $label)
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Value $value -Type $type -Force
    Log-OK $label
}

# Menu kontekstowe styl Win10
$cmKey = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (-not (Test-Path $cmKey)) {
    New-Item -Path $cmKey -Force | Out-Null
    Set-ItemProperty -Path $cmKey -Name "(Default)" -Value "" -Type String -Force
    Log-OK "Menu kontekstowe styl Win10"
} else { Log-Skip "Menu kontekstowe styl Win10" }

# Reklamy i telemetria
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled"      0 "DWord" "Reklamy w Start Menu"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled"   0 "DWord" "Suggested apps w Start"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled"   0 "DWord" "Tips i sugestie Windows"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353698Enabled"   0 "DWord" "Timeline suggestions"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SoftLandingEnabled"                0 "DWord" "Welcome Experience"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenEnabled"         0 "DWord" "Reklamy na ekranie blokady"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled"  0 "DWord" "Overlay na ekranie blokady"
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"               "AllowTelemetry"                    1 "DWord" "Telemetria poziom minimalny"

# Cortana i Bing
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"       0 "DWord" "Cortana wylaczona"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"   "BingSearchEnabled"  0 "DWord" "Bing w wyszukiwarce Start"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"   "CortanaConsent"     0 "DWord" "Cortana consent"

# Taskbar
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0 "DWord" "Task View button ukryty"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa"          0 "DWord" "Widgets ukryte"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn"          0 "DWord" "Chat (Teams) ukryty"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"            "SearchboxTaskbarMode" 1 "DWord" "Search tylko ikona"

# Explorer
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt"     0 "DWord" "Rozszerzenia plikow widoczne"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden"          1 "DWord" "Ukryte pliki widoczne"
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSuperHidden" 0 "DWord" "Pliki systemowe ukryte (bezpieczne)"

# Sticky Keys - wylacz skrot
Set-Reg "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String" "Sticky Keys skrot wylaczony"

# Aero Shake
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisallowShaking" 1 "DWord" "Aero Shake wylaczony"

# NumLock przy starcie
Set-Reg "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" "2" "String" "NumLock przy starcie"

# Dzwiek startu
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1 "DWord" "Dzwiek startu wylaczony"

# Restart Explorera
Log-Step "Restart Explorera..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer
Log-OK "Explorer zrestartowany"

# =============================================================================
#  9c. POWERSHELL PROFILE - yeet
# =============================================================================
Log-Step "PowerShell profile (yeet)..."

$yeetFunc = @'

function yeet {
    $msgs = @("yeet", "ship it", "works on my machine", "LGTM", "no idea what i did but ok", "pls work", "fixed (maybe)", "touched grass pushed code", "do not review", "trust me bro")
    $msg = $msgs | Get-Random
    git add .
    git commit -m $msg
    git push
}
'@

if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    Log-OK "Utworzono $PROFILE"
}

$profileContent = Get-Content $PROFILE -Raw 2>$null
if ($profileContent -like "*function yeet*") {
    Log-Skip "yeet (juz jest w profilu)"
} else {
    Add-Content -Path $PROFILE -Value $yeetFunc
    Log-OK "yeet dodany do profilu"
}

# =============================================================================
#  KONIEC
# =============================================================================
Write-Host "`n=============================================" -ForegroundColor Magenta
Write-Host "  SETUP ZAKONCZONY!" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Nastepne kroki:" -ForegroundColor Yellow
Write-Host "  1. RESTART KOMPUTERA (wymagany dla PATH i WSL)" -ForegroundColor Yellow
Write-Host "  2. Po restarcie otworz Ubuntu z menu Start i ustaw haslo" -ForegroundColor Yellow
Write-Host "  3. XAMPP: uruchom Apache i MySQL z XAMPP Control Panel" -ForegroundColor Yellow
Write-Host "  4. Pobierz Zen Browser: zen-browser.app" -ForegroundColor Yellow
Write-Host "  5. Pobierz Deskflow: github.com/deskflow/deskflow" -ForegroundColor Yellow
Write-Host ""