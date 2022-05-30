<#
    .SYNOPSIS
    funscript Stroke to Vibrate converter.

    .DESCRIPTION
    The script converts the stroking toy funscript to the vibrating toy funscript.
    The conversion logic is taken from the topic on the forum https://discuss.eroscripts.com/t/guide-transforming-a-stroking-script-into-a-vibration-script-with-simple-tools/37730
    Tested on ScriptPlayer 1.10 https://github.com/FredTungsten/ScriptPlayer/releases/tag/1.1.0

    .EXAMPLE
    PS> .\S2V-Converter.ps1 -SFile '.\ForStrokingToys.funscript' -VFile '.\ForVibratingToys.funscript'

#>
#region Param
param (
    [string]$SFile,
    [string]$VFile
)
#endregion Param

#region Script settigns
$ErrorActionPreference = 'Stop'
#endregion Script settings

#region Functions
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
        Write-Error -Message "Cannot read $SFile. $_"
    }

    try {
        Write-Host "Converting $SFile to JSON" -ForegroundColor 'Green'
        $SFileObject = $SFileContent | ConvertFrom-Json
    }
    catch {
        Write-Error -Message "$SFile is not valid JSON. $_"
    }

    $Array = @(
        [PSCustomObject]@{
            'at'    = [int]0
            'pos'   = [int]0.0001
            'delta' = [int]0.0001
        }
    )

    try {
        Write-Host "Do some Magic" -ForegroundColor 'Green'
        $SFileObject.actions | Sort-Object -Property 'at' -Descending | Foreach-Object {
            $Array += [PSCustomObject]@{
                'at'    = $_.at
                'pos'   = $_.pos
                'delta' = [Math]::Abs(($Array.pos[-1]-$_.pos)/($Array.at[-1]-$_.at))
            }
        }
    
        $MAX = ($Array.delta | Sort-Object)[-1]
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
}
#endregion Functions

#region Debug
$SFile = "\\192.168.0.10\CloudSync\Yandex.Disk\Torrents\Haptic\test.txt"
$VFile = "\\192.168.0.10\CloudSync\Yandex.Disk\Torrents\Haptic\The Box-S2V.txt"
#endregion Debug

#region Main script
try {
    $Runtime = Measure-Command {
        Convert-S2V -SFile $SFile -VFile $VFile
    }
    Write-Host "Conversion completed in $($Runtime.TotalSeconds) seconds" -ForegroundColor 'Yellow'
}
catch {
    Write-Error -Message $_
}
#endregion Main script