# INSTALACJA:
# 1. Odpal PowerShell
# 2. Wpisz: New-Item -Path $PROFILE -ItemType File -Force
# 3. Wpisz: notepad $PROFILE
# 4. Wklej zawartosc tego pliku (bez komentarzy instalacji)
# 5. Zapisz i zrestartuj terminal
# 6. Uzyj: yeet

function yeet {
    $msgs = @("yeet", "ship it", "works on my machine", "LGTM", "no idea what i did but ok", "pls work", "fixed (maybe)", "touched grass pushed code", "do not review", "trust me bro")
    $msg = $msgs | Get-Random
    git add .
    git commit -m $msg
    git push
}