$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies 'System.Drawing.dll' -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class FeralAlpha {
    public static void Process(Bitmap bitmap, int stage, int alphaCap) {
        var rect = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
        var data = bitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        var bytes = new byte[Math.Abs(data.Stride) * bitmap.Height];
        Marshal.Copy(data.Scan0, bytes, 0, bytes.Length);
        for (int y = 0; y < bitmap.Height; y++) for (int x = 0; x < bitmap.Width; x++) {
            int i = y * data.Stride + x * 4;
            int b = bytes[i], g = bytes[i + 1], r = bytes[i + 2];
            int ink = Math.Max(r, b);
            int greenDistance = Math.Max(Math.Abs(g - 255), ink);
            int alpha = Math.Min(alphaCap, Math.Max(0, (ink - 18) * alphaCap / 190));
            if (greenDistance < 20 && ink < 28) alpha = 0;
            if (stage == 1 && ink < 115) alpha = 0;
            else if (stage == 2 && ink < 65) alpha = 0;
            bytes[i] = 255; bytes[i + 1] = 255; bytes[i + 2] = 255; bytes[i + 3] = (byte)alpha;
        }
        Marshal.Copy(bytes, 0, data.Scan0, bytes.Length);
        bitmap.UnlockBits(data);
    }
}
'@

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$atlasPath = Join-Path $PSScriptRoot 'FeralPatternAtlas-v5.png'
$pngRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral\png-source'
$ddsRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral'
$texconv = 'C:\Games\nefaram\mods\VRAMr\VRAMr\tools\texconv.exe'
New-Item -ItemType Directory -Path $pngRoot,$ddsRoot -Force | Out-Null

$families = @(
    @{ Name='wolf_pelt'; Column=0; Row=0 },
    @{ Name='sabre_stripes'; Column=1; Row=0 },
    @{ Name='bear_mantle'; Column=2; Row=0 },
    @{ Name='skeever_mottle'; Column=3; Row=0 },
    @{ Name='spider_chitin'; Column=0; Row=1 },
    @{ Name='mudcrab_carapace'; Column=1; Row=1 },
    @{ Name='stag_dappling'; Column=2; Row=1 },
    @{ Name='troll_hide'; Column=3; Row=1 }
)
$stageAlpha = @(150, 205, 255)
$atlas = [Drawing.Bitmap]::new($atlasPath)
$panelWidth = [int]($atlas.Width / 4)
$panelHeight = [int]($atlas.Height / 2)

try {
    foreach ($family in $families) {
        $sourceRect = [Drawing.Rectangle]::new($family.Column * $panelWidth, $family.Row * $panelHeight, $panelWidth, $panelHeight)
        for ($stage = 1; $stage -le 3; $stage++) {
            $bitmap = [Drawing.Bitmap]::new(2048, 2048, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $graphics = [Drawing.Graphics]::FromImage($bitmap)
            $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($atlas, [Drawing.Rectangle]::new(0,0,2048,2048), $sourceRect, [Drawing.GraphicsUnit]::Pixel)
            $graphics.Dispose()

            [FeralAlpha]::Process($bitmap, $stage, $stageAlpha[$stage - 1])

            $fileName = "$($family.Name)_$stage"
            $png = Join-Path $pngRoot ($fileName + '.png')
            $bitmap.Save($png, [Drawing.Imaging.ImageFormat]::Png)
            $bitmap.Dispose()
            & $texconv -f BC7_UNORM -ft dds -y -o $ddsRoot $png | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "texconv failed for $fileName" }
        }
    }
}
finally {
    $atlas.Dispose()
}

Write-Output 'Generated 24 staged 2K Feral SlaveTats marking textures.'
