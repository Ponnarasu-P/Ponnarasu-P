$username = Read-Host -Prompt "Enter your GitHub Username"
$token = Read-Host -Prompt "Enter your GitHub Personal Access Token (PAT) (It will not be displayed)" -AsSecureString

# Convert SecureString back to plain text to pass to environment variable
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$tokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

$env:GH_USERNAME = $username
$env:GH_TOKEN = $tokenPlain

Write-Host "Generating GitHub Jet Heatmap SVG files..." -ForegroundColor Cyan
node generate.mjs

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully generated SVGs!" -ForegroundColor Green

    # Update README.md
    $readmePath = "README.md"
    if (Test-Path $readmePath) {
        $content = Get-Content $readmePath
        $content = $content -replace "Sushmitadasari/Sushmitadasari", "$username/$username"
        $content = $content -replace "Sushmitadasari", $username
        Set-Content $readmePath -Value $content
        Write-Host "Updated README.md with your username." -ForegroundColor Green
    }
    
    # Remove origin so it can be pushed to user's new repository
    git remote remove origin
    
    Write-Host "`nAll done! You are ready to push this to your GitHub profile." -ForegroundColor Green
    Write-Host "1. Go to GitHub and create a new repository named: $username" -ForegroundColor Yellow
    Write-Host "2. Run the following commands to push your changes:" -ForegroundColor Yellow
    Write-Host "   git add ."
    Write-Host "   git commit -m `"Add GitHub Jet Heatmap animation`""
    Write-Host "   git branch -M main"
    Write-Host "   git remote add origin https://github.com/$username/$username.git"
    Write-Host "   git push -u origin main"
} else {
    Write-Host "Failed to generate SVGs. Please check your token and username." -ForegroundColor Red
}
