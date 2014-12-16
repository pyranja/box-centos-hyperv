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

# export vm
Write-Verbose "stopping ${VmName}"
Stop-VM -Name ${VmName} -TurnOff
Export-VM -Name ${VmName} -Path ${PackWorkDir}
Optimize-VHD -Path (Join-Path (Join-Path ${VmDir} "Virtual Hard Disks") "${VmName}.vhdx")
Remove-Item -Path (Join-Path ${VmDir} "Snapshots")

# package in box format (broken up due to psx bug with piping a tar file)
Copy-Item -Path metadata.json -Destination ${VmDir}
$TarFile = (Join-Path ${PackWorkDir} "${VmName}.tar")
Remove-Item -Path ${TarFile} -Force -ErrorAction SilentlyContinue
7z a -ttar -r -y "${TarFile}" "${VmDir}/*"
7z a -tzip -y -mx9 -aoa "${VmName}.box" "${TarFile}"
