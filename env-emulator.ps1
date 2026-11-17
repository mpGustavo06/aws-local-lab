param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$TfArgs
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvFile = Join-Path $ScriptDir ".env"
$TerraformDir = Join-Path $ScriptDir "terraform"

if (-not (Test-Path $EnvFile)) {
    Write-Host "Erro: Arquivo .env nao encontrado em $EnvFile." -ForegroundColor Red
    exit 1
}

if (-not $TfArgs -or $TfArgs.Count -eq 0) {
    Write-Host "Uso: .\env-emulator.ps1 <comando> [opcoes]"
    Write-Host "Exemplo: .\env-emulator.ps1 apply -auto-approve"
    exit 1
}

# Carrega as variaveis do .env para o processo atual
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        $parts = $line -split "=", 2
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"').Trim("'")
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

# Divide strings com multiplas opcoes (ex: "-check -recursive") em argumentos individuais
$ParsedArgs = @()
foreach ($arg in $TfArgs) {
    if (-not [string]::IsNullOrWhiteSpace($arg)) {
        $ParsedArgs += ($arg -split '\s+' | Where-Object { $_ -ne '' })
    }
}

# Entra na pasta terraform/ e repassa os argumentos
Push-Location $TerraformDir
try {
    & terraform @ParsedArgs
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}