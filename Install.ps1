function Install-NPP()
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Workfolder,
        [Parameter(Mandatory=$true)]
        [boolean]$AutoUpdate
    )

    # Define the URL of the GitHub releases page
    $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/"

    try {
        # Use Invoke-WebRequest to download the HTML content of the page
        $response = Invoke-WebRequest -Uri $url
        
        # Collect most recent version number
        $latestReleaseVersion = $response.ParsedHtml.body.getElementsByClassName('Link--primary Link') | Select-Object @{l="Version"; e={($_.nameProp).replace("v","")}}  -first 1
    }
    catch {
        Write-Error "Failed to collect Notepad++ version information from Github."
    }


    # Construct download URL
    $latestReleaseUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + ($latestReleaseVersion).Version + "/npp." + ($latestReleaseVersion).Version + ".Installer.x64.exe"

    # Construct file from download URL
    $latestReleaseFile = [System.IO.Path]::GetFileName($latestReleaseUrl)

    if (!(Test-Path $WorkFolder  -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $WorkFolder 
    }

    try {
        # Download Notepad++ installer
        Start-BitsTransfer -Source $latestReleaseUrl -Destination $WorkFolder -ErrorAction Stop
    } catch {
        Write-Error "Failed to download the Notepad++ installer."
    }

    # Stop any running Notepad++ processes
    Get-Process notepad++ -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    # Run Notepad++ installer
    Start-Process -FilePath ($WorkFolder + "\" + $latestReleaseFile) -ArgumentList "/S" -Wait

    if(-not($AutoUpdate)) {
        Remove-Item "C:\Program Files\Notepad++\updater" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Install-NPP-Plugins() {

    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Workfolder,
        [Parameter(Mandatory=$true)]
        [array]$Plugins
    )

    if(Test-Path "c:\Program Files\Notepad++\") {

        # Define the URL of the JSON file
        $PluginsJSON = "https://raw.githubusercontent.com/notepad-plus-plus/nppPluginList/master/src/pl.x64.json"

        # Use Invoke-RestMethod to fetch the JSON data from the URL
        $PluginsList = (Invoke-RestMethod -Uri $PluginsJSON -Method Get | Select-Object npp-plugins).'npp-plugins' | Where-Object 'display-name' -In $plugins

        if($PluginsList) {

            foreach ($plugin in $PluginsList)
            {
                $zipUrl        = $plugin.repository
                $zipFile       = [System.IO.Path]::GetFileName($plugin.repository)
                $pluginFolder  =  $plugin.'folder-name'
                $pluginExtract = ("C:\Program Files\Notepad++\plugins\" + $pluginFolder)
                $pluginDest    = ($WorkFolder + $zipFile)

                # Download the zip file
                Start-BitsTransfer -Source $zipUrl -Destination $WorkFolder

                if (!(Test-Path $pluginExtract  -PathType Container)) {
                    New-Item -ItemType Directory -Force -Path $pluginExtract 
                }

                # Extract the contents of the zip file
                Expand-Archive -Path $pluginDest  -DestinationPath $pluginExtract -Force
            }
        }
        else {
            Write-Error "No valid plugins found."
        }
    }
    else {
        Write-Error "Notepad++ is not installed."
    }
}

Install-NPP -AutoUpdate:$true -Workfolder "c:\temp\npp\"
Install-NPP-Plugins -plugins "XML Tools", "JSON Viewer" -Workfolder "c:\Windows\temp\"