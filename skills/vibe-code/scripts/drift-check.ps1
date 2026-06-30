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

    [string[]]$PlanArgs = @()
)

$ErrorActionPreference = "Stop"

function Invoke-TerraformChecked {
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
    Invoke-TerraformChecked -Arguments @("init", "-input=false")

    $arguments = @("plan", "-refresh-only", "-input=false", "-detailed-exitcode") + $PlanArgs
    Write-Host "terraform $($arguments -join ' ')"
    & terraform @arguments

    switch ($LASTEXITCODE) {
        0 {
            Write-Host "No drift detected."
            exit 0
        }
        2 {
            Write-Warning "Terraform detected drift."
            exit 2
        }
        default {
            throw "Terraform drift check failed with exit code $LASTEXITCODE."
        }
    }
}
finally {
    Pop-Location
}
