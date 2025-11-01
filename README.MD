# iname - Enhanced Kernel Information Utility

`iname` is a comprehensive kernel information tool that provides detailed system analysis beyond the standard `uname` command. It offers security status, virtualization detection, hardware information, and much more in a clean and complete output.

## Features

- **Comprehensive Kernel Analysis**: Build information, configuration, and runtime details
- **Security Status**: SELinux, AppArmor, and kernel security features
- **Virtualization Detection**: VM, container, and bare metal environment detection  
- **Hardware Information**: CPU, memory, architecture, and boot method
- **Network Stack**: TCP configuration and network features
- **Filesystem Details**: Root filesystem and supported filesystems
- **Clean Output**: `[OK]`, `[FAIL]`, `[INFO]` status indicators

## Quick Install
### Universal Installer (Linux & macOS):
```bash
curl -s https://raw.githubusercontent.com/IRodriguez13/Iname/master/install.sh | bash
```

## Manual Instalation 
```bash
sudo curl -s -o /usr/local/bin/iname https://raw.githubusercontent.com/IRodriguez13/Iname/master/iname.sh
sudo chmod +x /usr/local/bin/iname
```

