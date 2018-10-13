Add-Type -AssemblyName System.IO.Compression.FileSystem

import-module au

$url = 'http://mirrors.jenkins-ci.org/windows-stable/latest'
$localPath = $PSScriptRoot

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"       = "`$1'$($Latest.URL)'"
            "(^[$]checksum\s*=\s*)('.*')"  = "`$1'$($Latest.Checksum32)'"
            "(^[$]checksummsi\s*=\s*)('.*')"  = "`$1'$($Latest.MsiChecksum32)'"
        }
     }
}
Write-Output "test0"
function global:au_GetLatest {
    Write-Output "test1"
    return "bingo"
}

update -NoCheckUrl -ChecksumFor none
