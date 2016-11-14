import-module au

$url = 'http://mirrors.jenkins-ci.org/windows-stable/latest'
$localPath = $PSScriptRoot

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"       = "`$1'$($Latest.URL)'"
            "(^[$]checksum\s*=\s*)('.*')"  = "`$1'$($Latest.Checksum32)'"
        }
     }
}

function global:au_GetLatest {

    $location = (iex "$localPath/curl.exe -sI '$url'") | Where-Object {$_ -like "Location: *"}
    $location = $location.Substring(10)

    $filename = $location.Substring($location.LastIndexOf("/") + 1)
    $version = ($filename -split '-|\.' | select -Last 3 -skip 1) -join '.'

    $checkSumUrl = "http://mirrors.jenkins-ci.org/windows-stable/$filename.sha256"
    $checksum = (iex "$localPath/curl.exe '$checkSumUrl'").Split(' ')[0]

    $Latest = @{ URL = $location; Version = $version; CheckSum32 = $checkSum; CheckSumType = 'sha256' }
    return $Latest
}

update -NoCheckUrl -ChecksumFor none
