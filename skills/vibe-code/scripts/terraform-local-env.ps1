[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({
        if ([System.IO.Path]::IsPathRooted($_)) {
            if (-not (Test-Path -LiteralPath $_ -PathType Container)) {
                throw "TerraformDir must be an existing directory."
            }
        }
        return $true
    })]
    [string]$TerraformDir,

    [Parameter(Mandatory = $true)]
    [ValidateSet("init", "fmt", "validate", "plan", "apply", "test", "providers")]
    [string]$TerraformCommand,

    [string[]]$TerraformArgs = @(),

    [string]$EnvFile,

    [switch]$AllowApply
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform CLI was not found on PATH."
}

if ($TerraformCommand -eq "apply" -and -not $AllowApply) {
    throw "Terraform apply requires -AllowApply so live mutations are explicit."
}

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..\..")

if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    $EnvFile = Join-Path $repoRoot ".env.local"
}
elseif (-not [System.IO.Path]::IsPathRooted($EnvFile)) {
    $EnvFile = Join-Path $repoRoot $EnvFile
}

if (-not [System.IO.Path]::IsPathRooted($TerraformDir)) {
    $TerraformDir = Join-Path $repoRoot $TerraformDir
}

if (-not (Test-Path -LiteralPath $TerraformDir -PathType Container)) {
    throw "TerraformDir must be an existing directory."
}

if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    throw "Environment file was not found. Expected a local secret file at the configured path."
}

function ConvertFrom-EnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $trimmed = $Value.Trim()

    if ($trimmed.Length -ge 2) {
        $first = $trimmed[0]
        $last = $trimmed[$trimmed.Length - 1]

        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            return $trimmed.Substring(1, $trimmed.Length - 2)
        }
    }

    return $trimmed
}

$loadedNames = New-Object System.Collections.Generic.List[string]
$allowedPrefixes = @("GENESYSCLOUD_", "TF_VAR_")

foreach ($line in [System.IO.File]::ReadLines($EnvFile)) {
    $trimmed = $line.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
        continue
    }

    $separatorIndex = $trimmed.IndexOf("=")
    if ($separatorIndex -lt 1) {
        continue
    }

    $name = $trimmed.Substring(0, $separatorIndex).Trim()
    $value = ConvertFrom-EnvValue -Value $trimmed.Substring($separatorIndex + 1)

    if ($name -notmatch "^[A-Za-z_][A-Za-z0-9_]*$") {
        throw "Invalid environment variable name in local env file."
    }

    $isAllowed = $false
    foreach ($prefix in $allowedPrefixes) {
        if ($name.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $isAllowed = $true
            break
        }
    }

    if (-not $isAllowed) {
        continue
    }

    [Environment]::SetEnvironmentVariable($name, $value, "Process")
    $loadedNames.Add($name)
}

if ($TerraformCommand -in @("plan", "apply")) {
    $missing = New-Object System.Collections.Generic.List[string]
    $hasAccessToken = -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable("GENESYSCLOUD_ACCESS_TOKEN", "Process"))

    if (-not $hasAccessToken) {
        foreach ($requiredName in @("GENESYSCLOUD_OAUTHCLIENT_ID", "GENESYSCLOUD_OAUTHCLIENT_SECRET")) {
            if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($requiredName, "Process"))) {
                $missing.Add($requiredName)
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable("GENESYSCLOUD_REGION", "Process"))) {
        $missing.Add("GENESYSCLOUD_REGION")
    }

    if ($missing.Count -gt 0) {
        throw "Required environment variable names are missing: $($missing -join ', ')"
    }
}

Write-Output "Loaded $($loadedNames.Count) allowed environment variable name(s) from the local env file."
Write-Output "Running Terraform command in $TerraformDir."

Push-Location -LiteralPath $TerraformDir
try {
    $commandArgs = @($TerraformCommand) + $TerraformArgs
    & terraform @commandArgs
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
