<#
.SYNOPSIS
  package a hyperv virtual machine as vagrant box
#>

[CmdletBinding()]
Param(
  [Parameter()] [string] $VmName = "dev.centos6"
)

# prepare global working directory
$WorkDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\stage")
New-Item -ErrorAction SilentlyContinue -ItemType Directory -Force -Path ${WorkDir} | Out-Null
Write-Verbose "using ${WorkDir} as working directory"

$PackWorkDir = Join-Path ${WorkDir} "_pack-vm"
$VmDir = Join-Path ${PackWorkDir} ${VmName}
Remove-Item -Recurse -Path ${PackWorkDir} -Force -ErrorAction SilentlyContinue

# export vm
Write-Verbose "stopping ${VmName}"
Stop-VM -Name ${VmName} -TurnOff
Set-VMDvdDrive -VMName ${VmName} -path $null
Write-Verbose "exporting ${VmName}"
Export-VM -Name ${VmName} -Path ${PackWorkDir}
Optimize-VHD -Path (Join-Path (Join-Path ${VmDir} "Virtual Hard Disks") "${VmName}.vhdx")
Remove-Item -Path (Join-Path ${VmDir} "Snapshots")

# package in zip-box format
Write-Verbose "packing ${VmName}"
Copy-Item -Path metadata.json -Destination ${VmDir}
7z a -tzip -r -y -mx9 -aoa "${VmName}.box" "${VmDir}/*"
