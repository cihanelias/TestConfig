# Setze dein Gitea API-Token und Server-URL
$token = "8859367dd51e3bf9e3e7fdafc5b1c2d46b57832f"
#$gitea_url = "http://localhost:3000"  # Ändere das auf deine Gitea-URL
$gitea_url = "https://k8s.ki.fh-swf.de/gitea"  # Ändere das auf deine Gitea-URL

# API-Endpunkt zum Abrufen aller Repositories
$repos_url = "$gitea_url/api/v1/user/repos"

# Headers für die API-Anfragen
$headers = @{
    Authorization = "token $token"
}

# Repositories abrufen
try {
    $repos = Invoke-RestMethod -Uri $repos_url -Method GET -Headers $headers
} catch {
    Write-Host "❌ Fehler beim Abrufen der Repository-Liste:" -ForegroundColor Red
    Write-Host "$($_.Exception.Message)" -ForegroundColor DarkRed
    exit 1
}

# Prüfen, ob Repositories existieren
if ($repos.Count -eq 0) {
    Write-Host "🚀 Keine Repositories gefunden." -ForegroundColor Yellow
    exit 0
}

# Jedes Repository löschen
foreach ($repo in $repos) {
    $repo_owner = $repo.owner.username
    $repo_name = $repo.name
    $delete_url = "$gitea_url/api/v1/repos/$repo_owner/$repo_name"

    try {
        Write-Host ("🗑️ Lösche Repository: {0}/{1} ..." -f $repo_owner, $repo_name) -ForegroundColor Cyan
        Invoke-RestMethod -Uri $delete_url -Method DELETE -Headers $headers
        Write-Host ("✅ Repository gelöscht: {0}/{1}" -f $repo_owner, $repo_name) -ForegroundColor Green
    } catch {
        Write-Host ("❌ Fehler beim Löschen von {0}/{1}:" -f $repo_owner, $repo_name) -ForegroundColor Red
        Write-Host "$($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

Write-Host "🎉 Alle Repositories wurden verarbeitet." -ForegroundColor Yellow
