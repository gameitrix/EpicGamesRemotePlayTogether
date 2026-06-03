# Manejo de errores general
try {
    # 1. Cerrar Epic y Helpers (Silencio total)
    Get-Process -Name "EpicGamesLauncher", "EpicWebHelper" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3

    # 2. Iniciar Epic Games Launcher
    $appBase = "C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
    $null = Start-Process $appBase

    # Asignación del nombre del proceso (Nombre del ejecutable del juego sin el .exe)
    $processName = "EpicGamesLauncher"

    # Foco (C#)
    $code = @"
        using System;
        using System.Runtime.InteropServices;
        public class WindowUtils {
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
        }
"@
    # Evitar ventanas emergentes que afecten el Steam Overlay
    $null = Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue

    # 3. Esperar a que el Epic Games Launcher abra
    $proc = $null
    for ($i = 0; $i -lt 120; $i++) {
        $proc = Get-Process -Name "*$processName*" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
        if ($proc) { break }
        Start-Sleep -Seconds 1
    }

    if ($proc) {
        Start-Sleep -Seconds 3
        # Intentar poner al frente
        try { $null = [WindowUtils]::SetForegroundWindow($proc.MainWindowHandle) } catch {}
        
        # Mantener vivo el script
        Wait-Process -Id $proc.Id -ErrorAction SilentlyContinue
    }
}
catch {
    # Si algo falla, el script simplemente muere en silencio sin mostrar ventana de OK
    exit
}