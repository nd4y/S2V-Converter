param (
    [string]$SFile,
    [string]$VFile
)

$ErrorActionPreference = 'Stop'
function Convert-S2V {
    param (
        [string]$SFile,
        [string]$VFile
    )

    try {
        Write-Host "Getting content from $SFile" -ForegroundColor 'Green'
        $SFileContent = Get-Content $SFile
    }
    catch {
        Write-Error -Message "Cannot read $SFile"
    }

    try {
        Write-Host "Converting $SFile to JSON" -ForegroundColor 'Green'
        $SFileObject = $SFileContent | ConvertFrom-Json
    }
    catch {
        Write-Error -Message "$SFile in not valid JSON"
    }

    $Array = @(
        [PSCustomObject]@{
            'at'  = [int]0
            'pos' = [int]0.0001
            'Delta' = [int]0.0001
        }
    )

    try {
        Write-Host "Do some Magic" -ForegroundColor 'Green'
        $SFileObject.actions | Sort-Object -Property 'at' -Descending | Foreach-Object {
            $Array += [PSCustomObject]@{
                'at'    = $_.at
                'Delta' = [Math]::Abs(($Array.pos[-1]-$_.pos)/($Array.at[-1]-$_.at))
            }
        }
    
        $MAX = ($Array.Delta | Sort-Object)[-1]
        $Actions = @()
        $Array | Foreach-Object {
            $Actions += [PSCustomObject]@{
                'at'    = $_.at
                'pos' = 100-$_.Delta*100/$MAX
            }
        }
        
        $Actions = $Actions | Sort-Object -Property 'at'
    }
    catch {
        Write-Error -Message $_
    }

    $VFileObject = [PSCustomObject]@{
        'OpenFunscripter' = $SFileObject.OpenFunscripter
        'actions'         = $Actions
        'inverted'        = $SFileObject.OpenFunscripter
        'metadata'        = $SFileObject.OpenFunscripter
        'range'           = $SFileObject.OpenFunscripter
        'version'         = $SFileObject.OpenFunscripter
    }

    try {
        Write-Host "Writing result to $VFile" -ForegroundColor 'Green'
        Set-Content -Path $VFile -Value ($VFileObject | ConvertTo-Json -Depth 5)
    }
    catch {
        Write-Error -Message $_
    }
    Write-Host "Finished" -ForegroundColor 'Yellow'  
}

#$SourceFilePath = "\\192.168.0.10\CloudSync\Yandex.Disk\Torrents\Haptic\The Box-origin.txt"
#$DestinationFilePath = "\\192.168.0.10\CloudSync\Yandex.Disk\Torrents\Haptic\The Box-S2V.txt"

Convert-S2V -SFile $SFile -VFile $VFile