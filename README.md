# 📶 WlanPasswords v1.0.0 📶

> **Extract all your saved WLAN passwords with one click!** 🔐  
> *A PowerShell-based tool for Windows to recover WiFi passwords easily.*

A Windows-based WLAN password extraction tool that reads all saved WiFi credentials from your PC/Laptop.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2F11-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🎯 Features

### Core Features
- **Extract All Passwords**: Get all saved WLAN passwords at once
- **Export to File**: Save all credentials to a timestamped text file
- **Search Single Network**: Look up a specific WiFi network by name
- **Interactive Menu**: Easy-to-use console interface
- **Silent Mode**: Run non-interactively with command-line parameters
- **About Page**: With Bart Simpson ASCII art! 🎭

### Language Support
- Works with English and German Windows installations
- Automatically detects the system language for netsh output parsing

## ⚠️ Legal Disclaimer

**This tool is for legitimate purposes only!**

- Use ONLY on your own devices
- Use ONLY to recover passwords you have previously saved
- Do NOT use for unauthorized access to networks
- The authors are NOT responsible for misuse

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- PowerShell 5.1 or higher (pre-installed on Windows 10/11)
- Administrator rights (recommended for full access)

### Installation

1. **Download or Clone**
   ```bash
   git clone https://github.com/iamrealguexoxo/wlanpasswords.git
   cd wlanpasswords
   ```

2. **Run the Tool**
   - Double-click `run.bat`
   - OR: Right-click `run.bat` → "Run as administrator"
   - OR: Run directly in PowerShell:
     ```powershell
     .\WlanPasswords.ps1
     ```

### Command Line Usage

```powershell
# Interactive mode (default)
.\WlanPasswords.ps1

# Export all passwords to file directly
.\WlanPasswords.ps1 -Export

# Export silently (no prompts)
.\WlanPasswords.ps1 -Export -Silent
```

## 🎮 Usage

### Main Menu

```
========================================
    WiFi WlanPasswords v1.0.0
========================================

  by iamrealguexoxo

  [1] Show All WLAN Passwords
  [2] Export All Passwords to File
  [3] Search Single Network
  [4] About
  [5] Exit

========================================
```

### Options Explained

| Option | Description |
|--------|-------------|
| **[1] Show All** | Display all saved WLAN credentials in the console |
| **[2] Export** | Save all credentials to a text file |
| **[3] Search** | Look up a specific network by SSID name |
| **[4] About** | Show program info and Bart! |
| **[5] Exit** | Close the application |

## 📁 Project Structure

```
wlanpasswords/
├── WlanPasswords.ps1    # Main PowerShell script
├── run.bat              # Windows batch launcher
├── README.md            # This file
├── README_DE.md         # German documentation
├── LICENSE              # MIT License
└── .gitignore           # Git ignore rules
```

## 📄 Export Format

When you export passwords, the file looks like this:

```
============================================
 WlanPasswords - WLAN Password Export
 by iamrealguexoxo
 Generated: 2024-01-15 14:30:00
============================================

Total profiles found: 5

============================================

SSID: MyHomeWiFi
Password: SuperSecretPassword123
--------------------------------------------

SSID: Office-Network
Password: WorkPassword456
--------------------------------------------

SSID: CoffeeShop_Guest
Password: (No password / Open network)
--------------------------------------------

============================================
 End of Export
============================================
```

## ⚙️ How It Works

The tool uses Windows' built-in `netsh` command to extract WLAN information:

1. **List Profiles**: `netsh wlan show profiles`
2. **Get Password**: `netsh wlan show profile name="SSID" key=clear`

The PowerShell script parses the output and extracts the relevant information.

## 🔧 Troubleshooting

### "No WLAN profiles found"
- Make sure you have connected to WiFi networks before
- Run as Administrator for full access
- Check if the WLAN service is running: `services.msc` → WLAN AutoConfig

### "Access Denied"
- Right-click `run.bat` → "Run as administrator"
- Some networks may require elevated privileges

### Script won't run
- Check PowerShell execution policy:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Or use the `run.bat` which bypasses execution policy

## 🛡️ Security Tips

- **Delete export files** after use - they contain sensitive data!
- **Don't share** exported password files
- **Encrypt** sensitive exports if you need to store them
- Consider using a **password manager** instead

## 🙏 Credits

- **Created by**: [iamrealguexoxo](https://github.com/iamrealguexoxo) 🎭
- **Style from**: BartsTOK & DeadMan projects

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## 🌍 Languages

- **English**: This file
- **Deutsch**: [README_DE.md](README_DE.md)

---

**Enjoy WlanPasswords!** 📶🔐

*Remember: With great power comes great responsibility. Use wisely!* 😎
