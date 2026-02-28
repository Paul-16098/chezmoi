Get-Process -Name nu | Stop-Process

cargo install --locked --git https://github.com/nushell/nushell.git nu -F full
if ($LASTEXITCODE -ne 0) {
    Write-Error "nu-selfupdate.ps1: 'cargo install' failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}
else {
    Write-Host "nu-selfupdate.ps1: 'cargo install' completed successfully."
}
