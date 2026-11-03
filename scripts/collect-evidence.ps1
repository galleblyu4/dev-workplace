#requires -Version 5.1
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$logDir = Join-Path $root 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Section([string]$file, [string]$title, [scriptblock]$body) {
  $path = Join-Path $logDir $file
  "===== $title =====`r`nTimestamp: $(Get-Date -Format o)`r`nDirectory: $root`r`n" | Set-Content -Path $path -Encoding UTF8
  try {
    & $body *>&1 | Out-String -Width 250 | Add-Content -Path $path -Encoding UTF8
  } catch {
    "ERROR: $($_.Exception.Message)" | Add-Content -Path $path -Encoding UTF8
  }
  Write-Host "Saved $file"
}
function Invoke-Logged([string]$command, [scriptblock]$body) {
  Write-Output "`n> $command"
  try { & $body 2>&1 | Out-String -Width 250 | Write-Output }
  catch { Write-Output "ERROR: $($_.Exception.Message)" }
  if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Write-Output "EXIT CODE: $LASTEXITCODE" }
}

Section '01-environment.txt' 'Environment' {
  Invoke-Logged 'Get-CimInstance Win32_OperatingSystem | Select Caption, Version' { Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version | Format-List }
  Invoke-Logged '$PSVersionTable.PSVersion' { $PSVersionTable.PSVersion }
  Invoke-Logged 'git --version' { git --version }
  Invoke-Logged 'docker --version' { docker --version }
  Invoke-Logged 'docker info' { docker info }
}
Section '02-git.txt' 'Git status and remote (public-safe selection)' {
  Invoke-Logged 'git remote -v' { git remote -v }
  Invoke-Logged 'git status --short' { git status --short }
  Invoke-Logged 'git branch --show-current' { git branch --show-current }
  Invoke-Logged 'git config --get init.defaultBranch' { git config --get init.defaultBranch }
  Invoke-Logged 'git config --get core.autocrlf' { git config --get core.autocrlf }
  Invoke-Logged 'git config --get user.name (if configured)' { git config --get user.name }
  Invoke-Logged 'git config --get user.email (if configured)' { git config --get user.email }
  Write-Output 'NOTE: git config --list full output is in locally created git-config.txt; review/redact before publishing.'
}
Section '03-cli-windows.txt' 'PowerShell CLI file operations' {
  $work = Join-Path $root 'mission-cli-demo'
  Invoke-Logged 'Get-Location' { Get-Location }
  Invoke-Logged 'Get-ChildItem -Force' { Get-ChildItem -Force | Select-Object Mode,Name }
  Invoke-Logged 'New-Item -ItemType Directory mission-cli-demo' { New-Item -ItemType Directory -Force $work }
  Invoke-Logged 'Set-Location mission-cli-demo; Get-Location' { Push-Location $work; Get-Location; Pop-Location }
  Invoke-Logged 'New-Item -ItemType File empty.txt' { New-Item -ItemType File -Force (Join-Path $work 'empty.txt') }
  Invoke-Logged 'Set-Content note.txt ...; Get-Content note.txt' { Set-Content (Join-Path $work 'note.txt') 'CLI file practice'; Get-Content (Join-Path $work 'note.txt') }
  Invoke-Logged 'Copy-Item note.txt copy.txt' { Copy-Item (Join-Path $work 'note.txt') (Join-Path $work 'copy.txt') -Force; Get-ChildItem $work | Select-Object Name }
  Invoke-Logged 'Move-Item copy.txt renamed.txt' { Move-Item (Join-Path $work 'copy.txt') (Join-Path $work 'renamed.txt') -Force; Get-ChildItem $work | Select-Object Name }
  Invoke-Logged 'Remove-Item renamed.txt' { Remove-Item (Join-Path $work 'renamed.txt') -Force; Get-ChildItem $work | Select-Object Name }
}

$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
  Write-Warning 'Docker command not found: install/start Docker Desktop and rerun. Other docker logs not generated.'
  exit 1
}
docker info *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Warning 'Docker engine not ready: start Docker Desktop and rerun.'
  exit 1
}

# Fail safely if a previous run created containers; avoid deleting user resources.
$missionContainers = @('mission-hello','mission-ubuntu','mission-web-8081','mission-bind','mission-data-one')
foreach ($containerName in $missionContainers) {
  docker container inspect $containerName *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Warning "Container '$containerName' already exists. Inspect or remove it manually before rerun: docker rm -f $containerName"
    exit 1
  }
}

Section '04-linux-permissions.txt' 'Linux CLI and chmod on Linux-managed volume' {
  Invoke-Logged 'docker volume create mission-perms' { docker volume create mission-perms }
  $sh = 'set -x; pwd; ls -la; mkdir -p /proof/work; cd /proof/work; touch file.txt; echo sample > file.txt; cat file.txt; cp file.txt copied.txt; mv copied.txt renamed.txt; rm renamed.txt; ls -la; echo BEFORE; ls -l file.txt; ls -ld /proof/work; chmod 600 file.txt; chmod 700 /proof/work; echo RESTRICTED; ls -l file.txt; ls -ld /proof/work; chmod 644 file.txt; chmod 755 /proof/work; echo AFTER; ls -l file.txt; ls -ld /proof/work'
  Invoke-Logged 'docker run --rm -v mission-perms:/proof ubuntu:24.04 sh -c "... chmod ... ls -l ..."' { docker run --rm -v mission-perms:/proof ubuntu:24.04 sh -c $sh }
}
Section '05-containers.txt' 'hello-world and Ubuntu container' {
  Invoke-Logged 'docker run --name mission-hello hello-world' { docker run --name mission-hello hello-world }
  Invoke-Logged 'docker run -d --name mission-ubuntu ubuntu:24.04 sleep 600' { docker run -d --name mission-ubuntu ubuntu:24.04 sleep 600 }
  Invoke-Logged 'docker exec mission-ubuntu sh -c "pwd; ls; echo hello"' { docker exec mission-ubuntu sh -c 'pwd; ls; echo hello from inside Ubuntu' }
  Invoke-Logged 'docker ps -a' { docker ps -a }
}
Section '07-build.txt' 'Building existing Dockerfile' {
  Invoke-Logged 'docker build --progress=plain -t dev-workplace-web:1.0 .' { docker build --progress=plain -t dev-workplace-web:1.0 . }
}
Section '08-web-port.txt' 'Port mapping / curl' {
  Invoke-Logged 'docker run -d --name mission-web-8081 -p 8081:80 dev-workplace-web:1.0' { docker run -d --name mission-web-8081 -p 8081:80 dev-workplace-web:1.0 }
  Start-Sleep -Seconds 2
  Invoke-Logged 'curl.exe -i http://localhost:8081/' { curl.exe -i http://localhost:8081/ }
  Invoke-Logged 'docker logs mission-web-8081' { docker logs mission-web-8081 }
  Invoke-Logged 'docker ps -a' { docker ps -a }
}
Section '06-operations.txt' 'Docker operational verification' {
  Invoke-Logged 'docker images' { docker images }
  Invoke-Logged 'docker ps' { docker ps }
  Invoke-Logged 'docker ps -a' { docker ps -a }
  Invoke-Logged 'docker logs mission-web-8081' { docker logs mission-web-8081 }
  Invoke-Logged 'docker stats --no-stream' { docker stats --no-stream }
}
Section '09-bind-mount.txt' 'Bind mount change proof' {
  $site = Join-Path $root 'mission-bind-site'
  New-Item -ItemType Directory -Force -Path $site | Out-Null
  $html = Join-Path $site 'index.html'
  Invoke-Logged 'Set-Content mission-bind-site/index.html BEFORE' { Set-Content -Path $html -Value '<h1>BEFORE BIND CHANGE</h1>'; Get-Content $html }
  Invoke-Logged 'docker run -d --name mission-bind -p 8084:80 --mount type=bind,source=<project>/mission-bind-site,target=/usr/share/nginx/html,readonly nginx:alpine' { docker run -d --name mission-bind -p 8084:80 --mount "type=bind,source=$site,target=/usr/share/nginx/html,readonly" nginx:alpine }
  Start-Sleep -Seconds 2
  Invoke-Logged 'curl.exe http://localhost:8084/ (before)' { curl.exe http://localhost:8084/ }
  Invoke-Logged 'Set-Content mission-bind-site/index.html AFTER' { Set-Content -Path $html -Value '<h1>AFTER BIND CHANGE</h1>'; Get-Content $html }
  Invoke-Logged 'curl.exe http://localhost:8084/ (after)' { curl.exe http://localhost:8084/ }
}
Section '10-volume.txt' 'Docker volume persistence after container removal' {
  Invoke-Logged 'docker volume create mission-data' { docker volume create mission-data }
  Invoke-Logged 'docker run -d --name mission-data-one -v mission-data:/data ubuntu:24.04 sleep 600' { docker run -d --name mission-data-one -v mission-data:/data ubuntu:24.04 sleep 600 }
  Invoke-Logged 'docker exec mission-data-one sh -c "echo ... > /data/proof.txt; cat /data/proof.txt"' { docker exec mission-data-one sh -c 'echo Docker volume survives container deletion > /data/proof.txt; cat /data/proof.txt' }
  Invoke-Logged 'docker ps -a (before deletion)' { docker ps -a }
  Invoke-Logged 'docker rm -f mission-data-one' { docker rm -f mission-data-one }
  Invoke-Logged 'docker ps -a (after deletion)' { docker ps -a }
  Invoke-Logged 'docker run --rm -v mission-data:/data ubuntu:24.04 cat /data/proof.txt' { docker run --rm -v mission-data:/data ubuntu:24.04 cat /data/proof.txt }
}
Write-Host 'Temporary practice files are in mission-cli-demo and mission-bind-site. Review before cleaning them up.'
Write-Host 'Review all logs. Take browser and VS Code screenshots manually. Do NOT mark PASS for commands that failed.'
