<#
.SYNOPSIS 
    Pack project into a NuGet package

.DESCRIPTION 
    This script is to pack a project into a NuGet package files (*.nupkg).

...

#>
Param (

    # Required
    
	[string] $project_path = "", # Required. Path to a project.json file or a folder containing project.json files.
    [string] $destination_folder = "", # Required. Destination folder.
	[string] $libraryOrchestratorUrl = "", # Required. The URL of the Orchestrator instance.
	[string] $libraryOrchestratorTenant = "", #(Optional, useful only for libraries) The Orchestrator tenant.

    ...

    # Version handling
    [string] $version = "",                 # Package version.
    [switch] $autoVersion,                  # Auto-generate package version.

    ...
)
# Log function
function WriteLog
{
	Param ($message, [switch] $err)
	
	$now = Get-Date -Format "G"
	$line = "$now`t$message"
	$line | Add-Content $debugLog -Encoding UTF8
	if ($err)
	{
		Write-Host $line -ForegroundColor red
	} else {
		Write-Host $line
	}
}

...

# Building uipath cli parameters
$ParamList = New-Object 'Collections.Generic.List[string]'

...

# Handle version parameter
if ($version -ne "") {
    $ParamList.Add("--version")
    $ParamList.Add($version)
} elseif ($autoVersion) {
    $ParamList.Add("--autoVersion")
    # Auto-generate version logic here if needed
    $version = "1.0.0" # Example: Set a default version or generate one dynamically
    WriteLog "Auto-generated version: $version"
}

...

# Log CLI call with parameters
WriteLog "Executing $uipathCLI $ParamMask"
WriteLog "-----------------------------------------------------------------------------"

# Call UiPath CLI 
& "$uipathCLI" $ParamList.ToArray()

...
