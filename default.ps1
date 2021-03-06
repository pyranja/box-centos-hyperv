#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS packer build script
#>

FormatTaskName "box-centos-hyperv::{0}"

Task Default -Depends Packer, AddBox

Task Clean -description "clear transient workspace data" {
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue .\target
}

Task Packer -description "run packer build" {
    Exec { packer build .\centos.packer.json }
}

Task AddBox -description "add packed box to local vagrant installation" {
    Exec { vagrant box add packer-box .\target\centos7.hyperv.box }
}
