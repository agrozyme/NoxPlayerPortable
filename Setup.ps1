Set-StrictMode -Version Latest

function Invoke-Administrator([String] $FilePath, [String[]] $ArgumentList = '') {
  $Current = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
  $Administrator = [Security.Principal.WindowsBuiltInRole]::Administrator

  if (-not $Current.IsInRole($Administrator)) {
    $PowerShellPath = (Get-Process -Id $PID).Path
    $Command = "" + $FilePath + "$ArgumentList" + ""
    Start-Process $PowerShellPath "-NoProfile -ExecutionPolicy Bypass -File $Command" -Verb RunAs
    exit
  } else {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
  }
}

Invoke-Administrator $PSCommandPath
Import-Module BitsTransfer

function Receive-File([String] $Source, [String] $Destination) {
  Start-BitsTransfer -Source $Source -Destination $Destination
  #  Invoke-WebRequest -Uri $Source -OutFile $Destination
}

function Main {
  $NoxPlayerSetupUri = 'https://res06.bignox.com/full/20201121/7e00b14bd18746908269dd8e648e109e.exe?filename=nox_setup_v6.6.1.5_full_intl.exe'

  $AssetFolder = $PSScriptRoot + '\assets'
  $Expand = $AssetFolder + '\7za.exe'

  $NoxPlayerFolder = $PSScriptRoot + '\NoxPlayer'
  $NoxPlayerSetupFile = $NoxPlayerFolder + '\NoxPlayerSetup.exe'

  Write-Host 'Creating NoxPlayer Folder...'
  New-Item -ItemType Directory -Path $NoxPlayerFolder -Force

  Write-Host 'Copy Scripts...'
  Copy-Item -Path ($AssetFolder + '\SecretRunScripts\*.*') -Destination $NoxPlayerFolder -Force

  Write-Host 'Downloading NoxPlayerSetup Package...'
  Receive-File $NoxPlayerSetupUri $NoxPlayerSetupFile

  Write-Host 'Extracting NoxPlayerSetup Files...'
  & $Expand x $NoxPlayerSetupFile -o"$NoxPlayerFolder" -y

  Write-Host 'Removing NoxPlayerSetup Package...'
  Remove-Item -Path $NoxPlayerSetupFile -Force

  Write-Host
  Write-Host 'Copy The NoxPlayer Folder To Where Ever You Like, Like A USB-Stick'
  Write-Host 'To Run NoxPlayer Go To The NoxPlayer Folder And Run Nox.cmd'
  Write-Host
}

Main
