$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$pngRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral\png-source'
$ddsRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral'
$texconv = 'C:\Games\nefaram\mods\VRAMr\VRAMr\tools\texconv.exe'
New-Item -ItemType Directory -Path $pngRoot,$ddsRoot -Force | Out-Null

$names = @('wolf_pelt','sabre_stripes','bear_mantle','skeever_mottle','spider_chitin','mudcrab_carapace','horse_stride','troll_hide')
foreach ($name in $names) {
    $bitmap = [Drawing.Bitmap]::new(512,512,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $pen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(220,255,255,255)),18
    $thin = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(190,255,255,255)),10
    $brush = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(205,255,255,255))
    switch ($name) {
        'wolf_pelt' {
            $graphics.DrawArc($pen,120,105,270,270,35,290)
            0..2 | ForEach-Object { $x=185+($_*60); $graphics.DrawLine($pen,$x,165,$x-55,345) }
        }
        'sabre_stripes' {
            0..4 | ForEach-Object { $y=120+($_*58); $graphics.DrawArc($pen,115,$y,280,100,200,140) }
            $graphics.DrawLine($thin,256,95,256,420)
        }
        'bear_mantle' {
            $graphics.FillEllipse($brush,185,205,145,130)
            $graphics.FillEllipse($brush,115,135,70,80)
            $graphics.FillEllipse($brush,205,105,70,85)
            $graphics.FillEllipse($brush,310,135,70,80)
            $graphics.FillEllipse($brush,125,285,70,80)
        }
        'skeever_mottle' {
            $graphics.DrawArc($pen,130,130,250,250,20,310)
            $graphics.DrawArc($thin,185,185,140,140,20,300)
            $graphics.DrawLine($thin,255,245,405,175)
            $graphics.DrawLine($thin,255,265,420,265)
            $graphics.DrawLine($thin,255,285,405,355)
        }
        'spider_chitin' {
            $graphics.FillEllipse($brush,215,170,82,105)
            $graphics.FillEllipse($brush,195,265,122,145)
            0..3 | ForEach-Object { $d=$_*36; $graphics.DrawLine($thin,210,220+$d,95,145+$d); $graphics.DrawLine($thin,300,220+$d,415,145+$d) }
        }
        'mudcrab_carapace' {
            $graphics.DrawArc($pen,145,150,220,200,180,180)
            $graphics.DrawLine($pen,150,250,95,335)
            $graphics.DrawLine($pen,360,250,415,335)
            $graphics.DrawArc($pen,65,300,95,95,200,230)
            $graphics.DrawArc($pen,350,300,95,95,110,230)
            $graphics.DrawLine($thin,185,170,155,95)
            $graphics.DrawLine($thin,325,170,355,95)
        }
        'horse_stride' {
            $graphics.DrawArc($pen,130,90,250,320,20,320)
            $graphics.DrawArc($thin,185,150,140,210,20,320)
            $graphics.DrawLine($pen,150,325,205,370)
            $graphics.DrawLine($pen,360,325,305,370)
        }
        'troll_hide' {
            $points = [Drawing.PointF[]]@((New-Object Drawing.PointF 256,75),(New-Object Drawing.PointF 345,190),(New-Object Drawing.PointF 305,405),(New-Object Drawing.PointF 205,405),(New-Object Drawing.PointF 165,190))
            $graphics.DrawPolygon($pen,$points)
            $graphics.DrawLine($pen,170,190,340,190)
            $graphics.DrawLine($pen,205,405,300,120)
            $graphics.DrawLine($thin,255,195,355,330)
        }
    }
    $png = Join-Path $pngRoot ($name + '.png')
    $bitmap.Save($png,[Drawing.Imaging.ImageFormat]::Png)
    $pen.Dispose(); $thin.Dispose(); $brush.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
    & $texconv -f R8G8B8A8_UNORM -ft dds -y -o $ddsRoot $png | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "texconv failed for $name" }
}

Write-Output "Generated $($names.Count) Feral SlaveTats marking textures."
