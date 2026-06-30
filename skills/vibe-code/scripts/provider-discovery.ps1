[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({
        if (-not (Test-Path -LiteralPath $_ -PathType Container)) {
            throw "TerraformDir must be an existing directory."
        }
        return $true
    })]
    [string]$TerraformDir,

    [string]$Search = "",

    [switch]$IncludeDataSources
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform CLI was not found on PATH."
}

function Select-MatchingNames {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    if ([string]::IsNullOrWhiteSpace($Search)) {
        return $Names
    }

    return $Names | Where-Object { $_ -like "*$Search*" }
}

Push-Location -LiteralPath $TerraformDir
try {
    $schemaJson = & terraform providers schema -json

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read Terraform provider schema. Run terraform init first in '$TerraformDir'."
    }

    $schema = $schemaJson | ConvertFrom-Json -Depth 100
    $providers = $schema.provider_schemas.PSObject.Properties |
        Where-Object { $_.Name -like "*genesyscloud*" }

    if (-not $providers) {
        throw "No Genesys Cloud provider schema found. Check the provider source and run terraform init."
    }

    foreach ($provider in $providers) {
        Write-Output "Provider: $($provider.Name)"

        $resourceSchemas = $provider.Value.resource_schemas
        if ($resourceSchemas) {
            $resourceNames = $resourceSchemas.PSObject.Properties.Name | Sort-Object
            $matchedResources = Select-MatchingNames -Names $resourceNames

            Write-Output ""
            Write-Output "Resources:"
            foreach ($name in $matchedResources) {
                Write-Output "- $name"
            }
        }

        if ($IncludeDataSources) {
            $dataSourceSchemas = $provider.Value.data_source_schemas
            if ($dataSourceSchemas) {
                $dataSourceNames = $dataSourceSchemas.PSObject.Properties.Name | Sort-Object
                $matchedDataSources = Select-MatchingNames -Names $dataSourceNames

                Write-Output ""
                Write-Output "Data Sources:"
                foreach ($name in $matchedDataSources) {
                    Write-Output "- $name"
                }
            }
        }
    }
}
finally {
    Pop-Location
}
