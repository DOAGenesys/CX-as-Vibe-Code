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

    [switch]$SkipPlan,

    [string]$PlanOut = "tfplan",

    [string[]]$PlanArgs = @()
)

$ErrorActionPreference = "Stop"

function Invoke-Terraform {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host "terraform $($Arguments -join ' ')"
    & terraform @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed with exit code $LASTEXITCODE."
    }
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform CLI was not found on PATH."
}

Push-Location -LiteralPath $TerraformDir
try {
    Invoke-Terraform -Arguments @("fmt", "-check", "-recursive")
    Invoke-Terraform -Arguments @("init", "-input=false")
    Invoke-Terraform -Arguments @("validate")

    if (-not $SkipPlan) {
        $arguments = @("plan", "-input=false", "-out=$PlanOut") + $PlanArgs
        Invoke-Terraform -Arguments $arguments
    }
}
finally {
    Pop-Location
}
