<#
.SYNOPSIS 
    Pack project into a NuGet package

.DESCRIPTION 
    This script is to pack a project into NuGet package files (*.nupkg).

.PARAMETER project_path 
    Required. Path to a project.json file or a folder containing project.json files.

.PARAMETER destination_folder 
    Required. Destination folder.

.PARAMETER libraryOrchestratorUrl 
    (Optional, useful only for libraries) The Orchestrator URL.

.PARAMETER libraryOrchestratorTenant 
    (Optional, useful only for libraries) The Orchestrator tenant.

...

#>
Param (
    [string] $project_path = "",          # Required. Path to a project.json file or a folder containing project.json files.
    [string] $destination_folder = "",    # Required. Destination folder.
    [string] $libraryOrchestratorUrl = "",# Required. The URL of the Orchestrator instance.
    [string] $libraryOrchestratorTenant = "", # (Optional, useful only for libraries) The Orchestrator tenant.
    ...
    [string] $version = "", # Package version.
    [switch] $autoVersion, # Auto-generate package version.
    ...
    [string] $uipathCliFilePath = "" # If not provided, the script will auto-download the cli from UiPath Public feed.

)

# Log function
function WriteLog {
    Param ($message, [switch] $err)
    
    $now = Get-Date -Format "G"
    $line = "$now`t$message"
    $line | Add-Content $debugLog -Encoding UTF8
    if ($err) {
        Write-Host $line -ForegroundColor red
    } else {
        Write-Host $line
    }
}

# Running Path
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
# Log file
$debugLog = "$scriptPath\orchestrator-package-pack.log"

# Validate provided cli folder (if any)
if ($uipathCliFilePath -ne "") {
    $uipathCLI = "$uipathCliFilePath"
    if (-not(Test-Path -Path $uipathCLI -PathType Leaf)) {
        WriteLog "UiPath cli file path provided does not exist in the provided path $uipathCliFilePath.`r`nDo not provide uipathCliFilePath parameter if you want the script to auto-download the cli from UiPath Public feed"
        exit 1
    }
} else {
    # Verifying UiPath CLI installation
    $cliVersion = "22.10.8438.32859"; # CLI Version (Script was tested on this latest version at the time)

    $uipathCLI = "$scriptPath\uipathcli\$cliVersion\tools\uipcli.exe"
    if (-not(Test-Path -Path $uipathCLI -PathType Leaf)) {
        WriteLog "UiPath CLI does not exist in this folder. Attempting to download it..."
        try {
            if (-not(Test-Path -Path "$scriptPath\uipathcli\$cliVersion" -PathType Leaf)){
                New-Item -Path "$scriptPath\uipathcli\$cliVersion" -ItemType "directory" -Force | Out-Null
            }
            # Download UiPath CLI
            Invoke-WebRequest "https://uipath.pkgs.visualstudio.com/Public.Feeds/_apis/packaging/feeds/1c781268-d43d-45ab-9dfc-0151a1c740b7/nuget/packages/UiPath.CLI.Windows/versions/$cliVersion/content" -OutFile "$scriptPath\\uipathcli\\$cliVersion\\cli.zip";
            Expand-Archive -LiteralPath "$scriptPath\\uipathcli\\$cliVersion\\cli.zip" -DestinationPath "$scriptPath\\uipathcli\\$cliVersion";
            WriteLog "UiPath CLI is downloaded and extracted in folder $scriptPath\uipathcli\\$cliVersion"
            if (-not(Test-Path -Path $uipathCLI -PathType Leaf)) {
                WriteLog "Unable to locate uipath cli after it is downloaded."
                exit 1
            }
        }
        catch {
            WriteLog ("Error Occurred: " + $_.Exception.Message) -err $_.Exception
            exit 1
        }
    }
}

WriteLog "-----------------------------------------------------------------------------"
WriteLog "uipcli location :   $uipathCLI"
# END Verifying UiPath CLI installation

# Building uipath cli parameters
$ParamList = New-Object 'Collections.Generic.List[string]'

if ($project_path -eq "" -or $destination_folder -eq "") {
    WriteLog "Fill the required parameters (project_path, destination_folder)"
    exit 1
}

$ParamList.Add("package")
$ParamList.Add("pack")
$ParamList.Add($project_path)
$ParamList.Add("--output")
$ParamList.Add($destination_folder)

...

# Handle version parameter
if ($version -ne "") {
    $ParamList.Add("--version")
    $ParamList.Add($version)
} elseif ($PSBoundParameters.ContainsKey('autoVersion')) {
    $ParamList.Add("--autoVersion")
    # Auto-generate version logic here if needed
    $version = "1.0.0" # Example: Set a default version or generate one dynamically
    WriteLog "Auto-generated version: $version"
}

...

# Log CLI call with parameters
WriteLog "Executing $uipathCLI $ParamList"
WriteLog "-----------------------------------------------------------------------------"

# Call UiPath CLI 
& "$uipathCLI" $ParamList.ToArray()

if ($LASTEXITCODE -eq 0) {
    WriteLog "Done! Package(s) destination folder is : $destination_folder"
    Exit 0
} else {
    WriteLog "Unable to Pack project. Exit code $LASTEXITCODE"
    Exit 1
}
