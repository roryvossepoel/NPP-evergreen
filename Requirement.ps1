function Detect-NPP()
{
    $EligibleForUpdate = $false
    $NPPInstalled      = Test-Path "C:\Program Files\Notepad++\Notepad++.exe"

    # Check if Notepad++ is installed
    if($NPPInstalled) {

        # Define the URL of the GitHub releases page
        $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/"

        try {
            # Use Invoke-WebRequest to download the HTML content of the page
            $response = Invoke-WebRequest -Uri $url
        
            # Collect most recent version number
            $latestReleaseVersion = ($response.ParsedHtml.body.getElementsByClassName('Link--primary Link') | Select-Object @{l="Version"; e={($_.nameProp).replace("v","")}} -First 1).Version
        }
        catch {
            Write-Error "Failed to collect Notepad++ version information from Github."
        }

        # Check currently installed version of Notepad++
        $installedversion = (Get-Item "C:\Program Files\Notepad++\notepad++.exe").VersionInfo.FileVersion

        # Compare currently installed version of Notepad++ with most recent version
        if([version]$installedversion -ne [version]$latestReleaseVersion) {
            $EligibleForUpdate = $true
        }
    }

    return $EligibleForUpdate
}

Detect-NPP