$code = @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management;
using System.Runtime.InteropServices;

public static class TaskbarFlasher {
    [DllImport("kernel32.dll")]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool IsWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, ref FindContext ctx);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool FlashWindowEx(ref FLASHWINFO pwfi);
    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool FlashWindow(IntPtr hWnd, bool bInvert);

    delegate bool EnumWindowsProc(IntPtr hWnd, ref FindContext ctx);

    [StructLayout(LayoutKind.Sequential)]
    struct FLASHWINFO {
        public uint cbSize;
        public IntPtr hwnd;
        public uint dwFlags;
        public uint uCount;
        public uint dwTimeout;
    }

    struct FindContext {
        public IntPtr resultHwnd;
        public HashSet<int> ancestorPids;
    }

    static bool EnumCallback(IntPtr hWnd, ref FindContext ctx) {
        if (!IsWindowVisible(hWnd)) return true;
        uint pid;
        GetWindowThreadProcessId(hWnd, out pid);
        if (ctx.ancestorPids.Contains((int)pid)) {
            ctx.resultHwnd = hWnd;
            return false;
        }
        return true;
    }

    static HashSet<int> GetAncestorPids() {
        var pids = new HashSet<int>();
        int pid = Process.GetCurrentProcess().Id;
        for (int i = 0; i < 10; i++) {
            pids.Add(pid);
            int parent = GetParentPid(pid);
            if (parent <= 0) break;
            pid = parent;
        }
        return pids;
    }

    static int GetParentPid(int pid) {
        try {
            using (var searcher = new ManagementObjectSearcher(
                "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = " + pid))
            {
                foreach (var obj in searcher.Get())
                    return Convert.ToInt32(obj["ParentProcessId"]);
            }
        } catch {}
        return 0;
    }

    static IntPtr FindTerminalWindow() {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd != IntPtr.Zero && IsWindow(hwnd)) return hwnd;

        int pid = Process.GetCurrentProcess().Id;
        for (int i = 0; i < 10; i++) {
            try {
                using (var p = Process.GetProcessById(pid)) {
                    if (p.MainWindowHandle != IntPtr.Zero && IsWindow(p.MainWindowHandle))
                        return p.MainWindowHandle;
                }
            } catch {}
            int parent = GetParentPid(pid);
            if (parent <= 0) break;
            pid = parent;
        }

        var ctx = new FindContext {
            resultHwnd = IntPtr.Zero,
            ancestorPids = GetAncestorPids()
        };
        EnumWindows(EnumCallback, ref ctx);
        if (ctx.resultHwnd != IntPtr.Zero && IsWindow(ctx.resultHwnd))
            return ctx.resultHwnd;

        return IntPtr.Zero;
    }

    static bool IsForegroundInOurTree() {
        IntPtr fgw = GetForegroundWindow();
        if (fgw == IntPtr.Zero) return false;
        uint fgPid;
        GetWindowThreadProcessId(fgw, out fgPid);
        var ancestors = GetAncestorPids();
        return ancestors.Contains((int)fgPid);
    }

    public static int Flash() {
        IntPtr hwnd = FindTerminalWindow();
        if (hwnd == IntPtr.Zero) return -1;

        if (IsForegroundInOurTree()) return 0;

        // Phase 1: Flash 3 times to grab attention (~300ms each)
        FLASHWINFO fi = new FLASHWINFO();
        fi.cbSize = (uint)Marshal.SizeOf(typeof(FLASHWINFO));
        fi.hwnd = hwnd;
        fi.dwFlags = 0x3; // FLASHW_ALL = caption + taskbar
        fi.uCount = 3;
        fi.dwTimeout = 300; // ms per flash
        FlashWindowEx(ref fi);

        // Phase 2: After flashes complete, if still in background,
        // keep taskbar icon highlighted (steady orange) until user focuses the window.
        System.Threading.Thread.Sleep(1200);
        if (!IsForegroundInOurTree())
            FlashWindow(hwnd, true);

        return (int)hwnd;
    }
}
'@

Add-Type -TypeDefinition $code -ReferencedAssemblies "System.Management"
$result = [TaskbarFlasher]::Flash()
if ($result -eq -1) { exit 1 }
