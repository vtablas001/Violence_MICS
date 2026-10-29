$ErrorActionPreference = 'Stop'
$paperRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location -LiteralPath $paperRoot
try {
    for ($pass = 1; $pass -le 3; $pass++) {
        & pdflatex -interaction=nonstopmode -halt-on-error -file-line-error main.tex
        if ($LASTEXITCODE -ne 0) { throw "La compilacion fallo en la pasada $pass." }
    }
    $paperLog = Get-Content -LiteralPath 'main.log' -Raw
    $pageMatch = [regex]::Match($paperLog, 'Output written on main\.pdf\s+\((\d+) pages?')
    if (-not $pageMatch.Success) { throw 'No se pudo comprobar la paginacion.' }
    $paperPages = [int]$pageMatch.Groups[1].Value
    if ($paperPages -gt 27) { throw "El articulo tiene $paperPages paginas; el maximo es 27." }
    Write-Output "Compilacion verificada: $paperPages paginas, incluidas referencias y anexos."
} finally {
    Pop-Location
}
