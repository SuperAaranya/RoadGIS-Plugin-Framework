#!/usr/bin/env python3
import os
import platform
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ARTIFACTS_DIR = os.path.join(BASE_DIR, "artifacts")


def artifact_for_choice(choice):
    c = choice.lower()
    if "windows 11 (.exe)" in c:
        return os.path.join(ARTIFACTS_DIR, "windows", "RoadGISProSetup.exe"), "exe"
    if "windows 11 (.msi)" in c:
        return os.path.join(ARTIFACTS_DIR, "windows", "RoadGISProSetup.msi"), "msi"
    return None, None


def run_installer(path, kind):
    if not os.path.exists(path):
        messagebox.showerror("Installer Missing", f"Installer not found:\n{path}\n\nBuild/copy it into artifacts first.")
        return
    system = platform.system().lower()
    try:
        if kind in ("exe", "msi") and system.startswith("win"):
            if kind == "msi":
                subprocess.Popen(["msiexec", "/i", path])
            else:
                subprocess.Popen([path])
        elif kind == "deb" and system == "linux":
            subprocess.Popen(["x-terminal-emulator", "-e", f"sudo apt install '{path}'"])
        elif kind == "pkg" and system == "darwin":
            subprocess.Popen(["open", path])
        else:
            messagebox.showinfo(
                "OS Mismatch",
                f"You selected {kind.upper()} but current OS is {platform.system()}.\n"
                f"Installer path:\n{path}",
            )
            return
        messagebox.showinfo("Installer Started", f"Started installer:\n{path}")
    except Exception as ex:
        messagebox.showerror("Launch Failed", str(ex))


def main():
    root = tk.Tk()
    root.title("RoadGIS Universal Setup")
    root.geometry("760x420")
    root.configure(bg="#111520")

    tk.Label(
        root,
        text="RoadGIS Universal Setup",
        bg="#111520",
        fg="#4a7ef5",
        font=("Consolas", 15, "bold"),
        pady=12,
    ).pack(fill="x")

    tk.Label(
        root,
        text="Windows setup wizard (EXE/MSI only for now):",
        bg="#111520",
        fg="#dde4f8",
        font=("Consolas", 10),
    ).pack(fill="x", padx=14, pady=6)

    choice = tk.StringVar(value="Windows 11 (.exe)")
    options = ["Windows 11 (.exe)", "Windows 11 (.msi)"]
    cb = ttk.Combobox(root, textvariable=choice, values=options, state="readonly", font=("Consolas", 10))
    cb.pack(fill="x", padx=14, pady=(0, 10))

    tk.Label(
        root,
        text="Linux/macOS installers: Coming Soon",
        bg="#111520",
        fg="#ffcc66",
        font=("Consolas", 10, "bold"),
    ).pack(fill="x", padx=14, pady=(0, 6))

    info = tk.Text(root, bg="#0f1628", fg="#dde4f8", relief="flat", bd=0, font=("Consolas", 9), wrap="word")
    info.pack(fill="both", expand=True, padx=14, pady=8)
    info.insert(
        "1.0",
        "Non-dev install flow (Windows):\n"
        "1) Download this framework folder/repo.\n"
        "2) Open Run-Setup.bat.\n"
        "3) Select EXE or MSI package.\n"
        "4) Accept setup terms.\n"
        "5) Click Start Setup, then installer runs.\n\n"
        "Expected Windows artifacts:\n"
        "- installer/artifacts/windows/RoadGISProSetup.exe\n"
        "- installer/artifacts/windows/RoadGISProSetup.msi\n"
        "\nLinux/macOS package launchers are intentionally disabled for now.",
    )
    info.config(state="disabled")

    btn_row = tk.Frame(root, bg="#111520")
    btn_row.pack(fill="x", padx=14, pady=(4, 12))

    accepted = tk.BooleanVar(value=False)
    tk.Checkbutton(
        btn_row,
        text="I accept setup terms and want to start installer",
        variable=accepted,
        bg="#111520",
        fg="#dce7ff",
        activebackground="#111520",
        activeforeground="#dce7ff",
        selectcolor="#1a2640",
        font=("Consolas", 9),
        relief="flat",
        bd=0,
    ).pack(side="left", padx=(0, 10))

    def on_run():
        if not accepted.get():
            messagebox.showwarning("Setup", "Please accept setup terms before continuing.")
            return
        p, kind = artifact_for_choice(choice.get())
        if not p:
            messagebox.showerror("Invalid Choice", "Unknown OS/package option selected.")
            return
        run_installer(p, kind)

    tk.Button(btn_row, text="Start Setup", command=on_run, bg="#4a7ef5", fg="white", relief="flat", bd=0,
              font=("Consolas", 10, "bold"), padx=12, pady=7).pack(side="left")
    tk.Button(btn_row, text="Close", command=root.destroy, bg="#3e4f74", fg="white", relief="flat", bd=0,
              font=("Consolas", 10, "bold"), padx=12, pady=7).pack(side="left", padx=8)

    root.mainloop()


if __name__ == "__main__":
    main()
