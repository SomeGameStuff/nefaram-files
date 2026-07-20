param(
    [switch]$PreviewMask
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies 'System.Drawing.dll' -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class FeralAlpha {
    static float Smooth(float edge0, float edge1, float value) {
        if (value <= edge0) return 0f;
        if (value >= edge1) return 1f;
        float t = (value - edge0) / (edge1 - edge0);
        return t * t * (3f - 2f * t);
    }

    // Horizontal window: 0 outside [x0,x1], ramping to 1 across taper.
    static float WindowX(float x, float x0, float x1, float taper) {
        return Smooth(x0, x0 + taper, x) * (1f - Smooth(x1 - taper, x1, x));
    }

    // CBBE body-UV seam fades, in normalized 2048x2048 coordinates.
    // Neck front: top of the front-torso island fades to skin at the collar.
    // Neck back:  top of the back island fades to skin at the nape.
    // Wrists:     outer ends of the horizontal arm band fade to skin.
    public static float BodyMask(int px, int py, int w, int h) {
        float x = (float)px / w;
        float y = (float)py / h;
        float mask = 1f;
        float neckFrontWindow = WindowX(x, 0.36f, 0.64f, 0.04f);
        if (neckFrontWindow > 0f) {
            // Invisible at the collar (y ~0.585), full by the upper chest
            // (y ~0.66); islands above the collar are not touched.
            float fade = (y < 0.585f) ? 1f : Smooth(0.585f, 0.66f, y);
            mask *= 1f - neckFrontWindow * (1f - fade);
        }
        float neckBackWindow = WindowX(x, 0.38f, 0.62f, 0.04f);
        if (neckBackWindow > 0f) {
            // Invisible at the nape (y ~0.02), full by the upper back
            // (y ~0.10), and untouched everywhere below that.
            float fade = Smooth(0.02f, 0.10f, y);
            mask *= 1f - neckBackWindow * (1f - fade);
        }
        float armBand = Smooth(0.36f, 0.39f, y) * (1f - Smooth(0.60f, 0.63f, y));
        if (armBand > 0f) {
            float wrist = Smooth(0.005f, 0.09f, x) * (1f - Smooth(0.91f, 0.995f, x));
            mask *= 1f - armBand * (1f - wrist);
        }
        return mask;
    }

    // Hand-UV fade: each 1024x1024 half fades to skin at all island edges,
    // which covers both wrist boundaries and the fingertip extremes.
    public static float HandsMask(int px, int py, int w, int h) {
        int half = w / 2;
        float lx = (float)(px % half) / half;
        float ly = (float)py / h;
        float fx = Smooth(0.0f, 0.13f, lx) * (1f - Smooth(0.87f, 1.0f, lx));
        float fy = Smooth(0.0f, 0.13f, ly) * (1f - Smooth(0.87f, 1.0f, ly));
        return Math.Min(fx, fy);
    }

    // White-ink-on-green source -> white RGB with ink-strength alpha, then a
    // UV seam mask multiplies the alpha so markings dissolve at the seams.
    public static void Process(Bitmap bitmap, int stage, int alphaCap, bool hands) {
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
            float mask = hands ? HandsMask(x, y, bitmap.Width, bitmap.Height)
                               : BodyMask(x, y, bitmap.Width, bitmap.Height);
            alpha = (int)(alpha * mask);
            bytes[i] = 255; bytes[i + 1] = 255; bytes[i + 2] = 255; bytes[i + 3] = (byte)alpha;
        }
        Marshal.Copy(bytes, 0, data.Scan0, bytes.Length);
        bitmap.UnlockBits(data);
    }

    // Grayscale render of a mask for offline placement review.
    public static void MaskPreview(int width, int height, bool hands, string path) {
        using (var bitmap = new Bitmap(width, height, PixelFormat.Format32bppArgb)) {
            var rect = new Rectangle(0, 0, width, height);
            var data = bitmap.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            var bytes = new byte[Math.Abs(data.Stride) * height];
            for (int y = 0; y < height; y++) for (int x = 0; x < width; x++) {
                int i = y * data.Stride + x * 4;
                float mask = hands ? HandsMask(x, y, width, height) : BodyMask(x, y, width, height);
                byte gray = (byte)(mask * 255);
                bytes[i] = gray; bytes[i + 1] = gray; bytes[i + 2] = gray; bytes[i + 3] = 255;
            }
            Marshal.Copy(bytes, 0, data.Scan0, bytes.Length);
            bitmap.UnlockBits(data);
            bitmap.Save(path, ImageFormat.Png);
        }
    }
}
'@ -IgnoreWarnings

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$atlasPath = Join-Path $PSScriptRoot 'FeralPatternAtlas-v5.png'
$pngRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral\png-source'
$ddsRoot = Join-Path $projectRoot 'build-output\Textures\Actors\Character\slavetats\Feral'
$previewRoot = Join-Path $projectRoot 'build-output\texture-inspect'
$texconv = 'C:\Games\nefaram\mods\VRAMr\VRAMr\tools\texconv.exe'
New-Item -ItemType Directory -Path $pngRoot,$ddsRoot,$previewRoot -Force | Out-Null

if ($PreviewMask) {
    [FeralAlpha]::MaskPreview(2048, 2048, $false, (Join-Path $previewRoot 'seam-mask-body.png'))
    [FeralAlpha]::MaskPreview(2048, 1024, $true, (Join-Path $previewRoot 'seam-mask-hands.png'))
    Write-Output "Wrote mask previews to $previewRoot (white = marking fully visible, black = faded to skin)."
    return
}

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
$handsAlpha = 205
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

            [FeralAlpha]::Process($bitmap, $stage, $stageAlpha[$stage - 1], $false)

            $fileName = "$($family.Name)_$stage"
            $png = Join-Path $pngRoot ($fileName + '.png')
            $bitmap.Save($png, [Drawing.Imaging.ImageFormat]::Png)
            $bitmap.Dispose()
            & $texconv -f BC7_UNORM -ft dds -y -o $ddsRoot $png | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "texconv failed for $fileName" }
        }

        $hands = [Drawing.Bitmap]::new(2048, 1024, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [Drawing.Graphics]::FromImage($hands)
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($atlas, [Drawing.Rectangle]::new(0,0,2048,1024), $sourceRect, [Drawing.GraphicsUnit]::Pixel)
        $graphics.Dispose()

        [FeralAlpha]::Process($hands, 3, $handsAlpha, $true)

        $handsName = "$($family.Name)_hands"
        $png = Join-Path $pngRoot ($handsName + '.png')
        $hands.Save($png, [Drawing.Imaging.ImageFormat]::Png)
        $hands.Dispose()
        & $texconv -f BC7_UNORM -ft dds -y -o $ddsRoot $png | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "texconv failed for $handsName" }
    }
}
finally {
    $atlas.Dispose()
}

Write-Output 'Generated 24 staged 2K Feral SlaveTats marking textures (neck fade applied) and 8 hand textures.'
