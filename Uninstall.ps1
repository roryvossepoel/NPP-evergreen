function Uninstall-NPP() {
    # Stop any running Notepad++ processes
    Get-Process notepad++ -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    # Uninstall Notepad++
    Start-Process "C:\Program Files\Notepad++\uninstall.exe" -ArgumentList "/S" -Wait

    # Remove Notepad++ folder as this is not full cleaned up due to copied plugins which are not handled by the uninstaller.
    Remove-Item "C:\Program Files\Notepad++\" -Recurse -Force -ErrorAction SilentlyContinue
}

Uninstall-NPP