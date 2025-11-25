<# 
    Script : support-tool.ps1
    Auteur : Erti (erti-it-tech)
    Description :
    Outil interactif pour technicien support IT :
    - Infos système
    - Tests réseau
    - Tests DNS / Port 443
    - Nettoyage fichiers temporaires
    - Réinitialisation de mot de passe AD (optionnel)
#>

function Show-Header {
    Clear-Host
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   OUTIL SUPPORT IT - POWERSHELL" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Return {
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour revenir au menu"
}

function Show-SystemInfo {
    Show-Header
    Write-Host "[1] Informations système" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "Nom de la machine : $(hostname)"
    Write-Host "Utilisateur connecté : $env:USERNAME"

    Write-Host "`nVersion de Windows :"
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" |
        Select-Object ProductName, ReleaseId, CurrentBuild

    Write-Host "`nAdresses IPv4 :"
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } |
        Select-Object IPAddress, InterfaceAlias

    Write-Host "`nUptime (date/heure du dernier démarrage) :"
    (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    Pause-Return
}

function Test-NetworkConnectivity {
    Show-Header
    Write-Host "[2] Test de connectivité réseau" -ForegroundColor Yellow
    Write-Host ""

    $target = Read-Host "Entrez une adresse à tester (ex: google.com, 8.8.8.8)"

    if ([string]::IsNullOrWhiteSpace($target)) {
        Write-Host "Aucune adresse saisie, retour au menu..." -ForegroundColor Red
        Pause-Return
        return
    }

    Write-Host "`nPing de $target :"
    try {
        ping $target
    } catch {
        Write-Host "Erreur lors du ping." -ForegroundColor Red
    }

    Write-Host "`nRésultat Test-NetConnection (port 443) :"
    try {
        Test-NetConnection -ComputerName $target -Port 443
    } catch {
        Write-Host "Erreur lors du test de port." -ForegroundColor Red
    }

    Pause-Return
}

function Test-DnsAndHttps {
    Show-Header
    Write-Host "[3] Test DNS + Port 443 (HTTPS)" -ForegroundColor Yellow
    Write-Host ""

    $target = Read-Host "Entrez un nom de domaine (ex: outlook.office365.com)"

    if ([string]::IsNullOrWhiteSpace($target)) {
        Write-Host "Aucun nom de domaine saisi, retour au menu..." -ForegroundColor Red
        Pause-Return
        return
    }

    Write-Host "`nRésolution DNS (nslookup) :"
    try {
        nslookup $target
    } catch {
        Write-Host "Erreur nslookup." -ForegroundColor Red
    }

    Write-Host "`nTest de connexion au port 443 :"
    try {
        Test-NetConnection -ComputerName $target -Port 443
    } catch {
        Write-Host "Erreur Test-NetConnection." -ForegroundColor Red
    }

    Pause-Return
}

function Clean-TempFolders {
    Show-Header
    Write-Host "[4] Nettoyage des dossiers temporaires" -ForegroundColor Yellow
    Write-Host ""

    $tempUser = $env:TEMP
    $tempWindows = "C:\Windows\Temp"

    Write-Host "Dossier temporaire utilisateur : $tempUser"
    Write-Host "Dossier temporaire Windows   : $tempWindows"
    Write-Host ""

    $confirm = Read-Host "Voulez-vous vraiment supprimer les fichiers temporaires ? (o/n)"

    if ($confirm -ne "o" -and $confirm -ne "O") {
        Write-Host "Nettoyage annulé." -ForegroundColor Red
        Pause-Return
        return
    }

    try {
        Write-Host "`nNettoyage du dossier utilisateur..."
        Remove-Item "$tempUser\*" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "Nettoyage du dossier Windows Temp..."
        Remove-Item "$tempWindows\*" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "`nNettoyage terminé." -ForegroundColor Green
    } catch {
        Write-Host "Erreur pendant le nettoyage." -ForegroundColor Red
    }

    Pause-Return
}

function Reset-AdUserPassword {
    Show-Header
    Write-Host "[5] Réinitialisation mot de passe AD (optionnel)" -ForegroundColor Yellow
    Write-Host ""

    # Vérifier si le module AD est disponible
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Host "Module ActiveDirectory non disponible sur cette machine." -ForegroundColor Red
        Write-Host "Cette fonction doit être exécutée sur un serveur ou poste avec RSAT/AD installé."
        Pause-Return
        return
    }

    Import-Module ActiveDirectory

    $sam = Read-Host "Entrez le SamAccountName de l'utilisateur (ex: user1)"
    $newPwd = Read-Host "Entrez le nouveau mot de passe"

    if ([string]::IsNullOrWhiteSpace($sam) -or [string]::IsNullOrWhiteSpace($newPwd)) {
        Write-Host "SamAccountName ou mot de passe vide, annulation." -ForegroundColor Red
        Pause-Return
        return
    }

    try {
        $securePwd = ConvertTo-SecureString $newPwd -AsPlainText -Force
        Set-ADAccountPassword -Identity $sam -NewPassword $securePwd -Reset
        Set-ADUser -Identity $sam -ChangePasswordAtLogon $true

        Write-Host "`nMot de passe réinitialisé pour l'utilisateur $sam." -ForegroundColor Green
        Write-Host "L'utilisateur devra changer son mot de passe à la prochaine connexion."
    } catch {
        Write-Host "Erreur lors de la réinitialisation du mot de passe : $_" -ForegroundColor Red
    }

    Pause-Return
}

function Show-Menu {
    Show-Header
    Write-Host "Sélectionnez une option :" -ForegroundColor White
    Write-Host ""
    Write-Host "  1) Afficher les informations système"
    Write-Host "  2) Test de connectivité réseau (ping + port 443)"
    Write-Host "  3) Test DNS + HTTPS (port 443)"
    Write-Host "  4) Nettoyer les fichiers temporaires"
    Write-Host "  5) Réinitialisation mot de passe AD (si module présent)"
    Write-Host "  0) Quitter"
    Write-Host ""
}

# Boucle principale
do {
    Show-Menu
    $choice = Read-Host "Votre choix"

    switch ($choice) {
        "1" { Show-SystemInfo }
        "2" { Test-NetworkConnectivity }
        "3" { Test-DnsAndHttps }
        "4" { Clean-TempFolders }
        "5" { Reset-AdUserPassword }
        "0" { Write-Host "Fermeture de l'outil..." -ForegroundColor Cyan }
        default {
            Write-Host "Choix invalide. Merci de sélectionner une option du menu." -ForegroundColor Red
            Start-Sleep -Seconds 1.5
        }
    }

} while ($choice -ne "0")
