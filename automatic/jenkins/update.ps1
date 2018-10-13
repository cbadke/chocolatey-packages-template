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

function global:au_GetLatest {
    $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction Ignore

    if($request.StatusDescription -eq 'found')
    {
       $location = $request.Headers.Location
    }
    $filename = $location.Substring($location.LastIndexOf("/") + 1)
    $filename = "jenkins-2.121.3.zip"
    $version = ($filename -split '-|\.' | select -Last 3 -skip 1) -join '.'

    $checkSumUrl = "http://mirrors.jenkins-ci.org/windows-stable/$filename.sha256"
    Invoke-WebRequest -Uri $checkSumUrl -OutFile "$localPath/$filename.sha256"
    $checksum = (Get-Content "$localPath/$filename.sha256" -Raw).Split(' ')[0]

    Write-Host "checksum: $checksum"
    Write-Host "version: $version"

    $Latest = @{ URL = $location; Version = $version; CheckSum32 = $checkSum; CheckSumType = 'sha256' }
    return $Latest
}

update -NoCheckChocoVersion -NoCheckUrl -ChecksumFor all -Force
