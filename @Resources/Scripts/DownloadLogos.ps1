<#
================================================================================
FootballSuite - Automatischer Wappen-Downloader
Laedt die offiziellen Vereinswappen fuer den lokalen Eigengebrauch direkt
von der OpenLigaDB API herunter.
================================================================================
#>

$ErrorActionPreference = 'SilentlyContinue'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogosDir  = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir "..\logos"))

if (-not (Test-Path $LogosDir)) {
    New-Item -ItemType Directory -Path $LogosDir -Force | Out-Null
}

$UserAgent = 'FootballSuite/2.0 (Rainmeter Skin; Windows NT 10.0; Win64; x64)'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  FootballSuite - Wappen-Download" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Zielverzeichnis: $LogosDir"

$leagues = @('bl1', 'bl2', 'bl3', 'pl', 'la1', 'lg1', 'ch1', 'ucl')
$downloaded = 0
$skipped = 0

function Save-Image ($url, $targetPath) {
    try {
        $req = [System.Net.HttpWebRequest]::Create($url)
        $req.UserAgent = $UserAgent
        $req.Timeout = 8000
        $resp = $req.GetResponse()
        $stream = $resp.GetResponseStream()
        $fileStream = [System.IO.File]::Create($targetPath)
        $stream.CopyTo($fileStream)
        $fileStream.Close()
        $stream.Close()
        $resp.Close()

        # Validieren, ob PNG Header vorhanden ist
        $bytes = Get-Content $targetPath -AsByteStream -TotalCount 4 -ErrorAction SilentlyContinue
        if ($bytes -and $bytes.Count -ge 4 -and $bytes[0] -eq 137 -and $bytes[1] -eq 80 -and $bytes[2] -eq 78 -and $bytes[3] -eq 71) {
            return $true
        } else {
            Remove-Item -Force $targetPath -ErrorAction SilentlyContinue
            return $false
        }
    } catch {
        if (Test-Path $targetPath) {
            Remove-Item -Force $targetPath -ErrorAction SilentlyContinue
        }
        return $false
    }
}

foreach ($lg in $leagues) {
    Write-Host "Pruefe Liga: $lg ..." -NoNewline
    try {
        $apiUrl = "https://api.openligadb.de/getbltable/$lg/2026"
        $req = [System.Net.HttpWebRequest]::Create($apiUrl)
        $req.UserAgent = $UserAgent
        $req.Timeout = 10000
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $jsonText = $reader.ReadToEnd()
        $reader.Close()
        $resp.Close()

        $teams = ConvertFrom-Json $jsonText -ErrorAction SilentlyContinue
        if ($teams) {
            Write-Host " ($($teams.Count) Teams)" -ForegroundColor Green
            foreach ($t in $teams) {
                $id = $t.teamInfoId
                $icon = $t.teamIconUrl
                $name = $t.teamName

                if (-not $id -or -not $icon) { continue }
                $target = Join-Path $LogosDir "$id.png"

                if (Test-Path $target) {
                    $skipped++
                    continue
                }

                # SVG in PNG-Thumbnail-URL von Wikimedia konvertieren, falls noetig
                $urlToDownload = $icon
                if ($icon -match 'upload\.wikimedia\.org' -and $icon -match '\.svg$') {
                    $fileName = Split-Path -Leaf $icon
                    $urlToDownload = $icon.Replace('/wikipedia/commons/', '/wikipedia/commons/thumb/').Replace('/wikipedia/de/', '/wikipedia/de/thumb/').Replace('/wikipedia/en/', '/wikipedia/en/thumb/') + "/200px-$fileName.png"
                }

                $ok = Save-Image $urlToDownload $target
                if ($ok) {
                    Write-Host "  + [$id] $name geladen." -ForegroundColor Gray
                    $downloaded++
                }
                Start-Sleep -Milliseconds 150
            }
        } else {
            Write-Host " (keine Daten)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " (Fehler beim Abruf)" -ForegroundColor Red
    }
}

Write-Host "`nFertig! $downloaded Wappen neu geladen, $skipped bereits vorhanden." -ForegroundColor Cyan

# Rainmeter Skins aktualisieren
$rmExe = (Get-Process Rainmeter -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -First 1)
if (-not $rmExe -or -not (Test-Path $rmExe)) {
    $candidates = @("$env:ProgramFiles\Rainmeter\Rainmeter.exe", "${env:ProgramFiles(x86)}\Rainmeter\Rainmeter.exe")
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { $rmExe = $c; break }
    }
}

if ($rmExe -and (Test-Path $rmExe)) {
    & $rmExe '!UpdateMeter' '*' 'FootballSuite\Table'
    & $rmExe '!Redraw' 'FootballSuite\Table'
    & $rmExe '!UpdateMeter' '*' 'FootballSuite\NextMatch'
    & $rmExe '!Redraw' 'FootballSuite\NextMatch'
    Write-Host "Rainmeter Skins aktualisiert!" -ForegroundColor Green
}