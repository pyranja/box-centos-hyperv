<#
.SYNOPSIS
  Prepare a CentOS installation image with kickstart configuration.
#>

[CmdletBinding()]
Param (
  [Parameter()] [string] $OsVersion = "6.8"
  , [Parameter()] [string] $OsArchitecture = "x86_64"
  , [Parameter()] [string] $OsMirror = "http://gd.tuwien.ac.at/opsys/linux/centos"
)

# prepare global working directory
$WorkDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\stage")
New-Item -ErrorAction SilentlyContinue -ItemType Directory -Force -Path ${WorkDir} | Out-Null
Write-Verbose "using ${WorkDir} as working directory"

## prepare installation image
$InstallIso = Join-Path ${WorkDir} "centos-netinstall-ks.iso"
Remove-Item -ErrorAction SilentlyContinue -Force -Recurse -Path ${InstallIso}
Write-Host "preparing installation image ${InstallIso}"

# prepare iso working directory
$IsoWorkDir = Join-Path ${WorkDir} "_pack-iso"
Remove-Item -ErrorAction SilentlyContinue -Force -Recurse -Path ${IsoWorkDir}
New-Item -ItemType directory -Path ${IsoWorkDir} | Out-Null
Write-Verbose "using ${IsoWorkDir} as image packaging directory"

$OsIsoName = "CentOS-${OsVersion}-${OsArchitecture}-netinstall.iso"
$OsIsoFile = Join-Path ${WorkDir} ${OsIsoName}

# download installation image if need be
If (-not (Test-Path -Path ${OsIsoFile})) {
  $OsIsoLink = "$OsMirror/$OsVersion/isos/$OsArchitecture/$OsIsoName"
  Write-Host "Downloading ${OsIsoLink}"
  Invoke-WebRequest ${OsIsoLink} -OutFile ${OsIsoFile}
}

# unpack iso
Write-Host "extracting source image"
Write-Verbose "Calling <7z x -tiso -o${IsoWorkDir} -y ${OsIsoFile}>"
7z x -tiso -o"${IsoWorkDir}" -y "${OsIsoFile}"

# inject kickstart
Write-Verbose "injecting kickstart configuration"
Copy-Item -Force -Path isolinux.cfg -Destination (Join-Path ${IsoWorkDir} "isolinux")
Copy-Item -Force -Path ks.cfg -Destination ${IsoWorkDir}

# repack iso
Write-Verbose "repackage installation image"
mkisofs --verbose -r -N -allow-leading-dots -d -J -T -b isolinux/isolinux.bin -c isolinux\boot.cat -no-emul-boot -V centos-netinstall-ks -boot-load-size 4 -boot-info-table -o ${InstallIso} ${IsoWorkDir}

# clean up
Remove-Item -Recurse -Path ${IsoWorkDir}
