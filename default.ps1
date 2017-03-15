#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS packer build script
#>

Properties {
    $version = [Version]"0.0.0"
}

FormatTaskName "box-centos-hyperv::{0}"

Task Default -Depends Packer

Task Packer -description "run packer build" {
    Exec { packer build -var "version=$version" .\centos.packer.json }
}

Task AddBox -description "add packed box to local vagrant installation" {
    Exec { vagrant box add packer-box .\target\centos7.hyperv.box }
}
