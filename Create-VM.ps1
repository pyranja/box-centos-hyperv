<#
.SYNOPSIS
  Create and initialize base box virtual machine
#>

[CmdletBinding(PositionalBinding = $false)]
Param (
  [Parameter()] [string] $VmSwitchName = "vm-network"
  , [Parameter()] [string] $VmName = "dev.centos6"
  , [Parameter()] [switch] $Purge
)

# prepare global working directory
$WorkDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\stage")
New-Item -ErrorAction SilentlyContinue -ItemType Directory -Force -Path ${WorkDir} | Out-Null
Write-Verbose "using ${WorkDir} as working directory"

$InstallIso = Join-Path ${WorkDir} "centos-netinstall-ks.iso"

Write-Host "creating virtual machine ${VmName}"
$VmWorkDir = Join-Path ${WorkDir} "_vm"
$VmDisk = Join-Path ${VmWorkDir} "${VmName}.vhdx"
Write-Verbose "using virtual hard disk @ ${VmDisk}"

# clear state
Write-Verbose "clearing old vm instance"
Remove-VM -Name ${VmName} -Force -ErrorAction SilentlyContinue
Remove-Item -Path ${VmDisk} -Force -ErrorAction SilentlyContinue

# init new vm
Write-Verbose "starting new vm instance"
New-VM -Name ${VmName} -Generation 1 -MemoryStartupBytes 1024MB -NewVHDPath ${VmDisk} -NewVHDSizeBytes 32GB -SwitchName ${VmSwitchName}
Set-VMDvdDrive -VMName ${VmName} -Path ${InstallIso}
Start-VM -Name ${VmName}

# show installation progress
Write-Host "started ${VmName} - connecting now..."
vmconnect "localhost" ${VmName}
