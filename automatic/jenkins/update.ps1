import-module au

$url = 'http://mirrors.jenkins-ci.org/windows-stable/latest'

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"       = "`$1'$($Latest.URL)'"
            "(^[$]checksum\s*=\s*)('.*')"  = "`$1'$($Latest.Checksum32)'"
        }
     }
}

function global:au_GetLatest {

    $location = ./curl.exe -sI $url | Where-Object {$_ -like "Location: *"}

    Write-Host = $location

    $filename = $location.Substring($location.LastIndexOf("/") + 1)
    $version = ($filename -split '-|\.' | select -Last 3 -skip 1) -join '.'

    $checkSumUrl = "http://mirrors.jenkins-ci.org/windows-stable/$filename.sha256"
    $checksum = (.\curl.exe $checkSumUrl).Split(' ')[0]


    Write-Host $version
    Write-Host $checkSum


    $Latest = @{ URL = $location; Version = $version; CheckSum32 = $checkSum; CheckSumType = 'sha256' }
    return $Latest
}

update -NoCheckUrl -ChecksumFor none
