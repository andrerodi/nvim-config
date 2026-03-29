# NeoVim config based on 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## C-Sharp configuration with debugging, tests and LSP support

### Prerequisites

You need to have the .NET SDK installed on your system. You can download it configuration
the [official .NET website](https://dotnet.microsoft.com/download).
Or use a package manager (like pacman, apt etc.)

### Debugging

For debugging C# code, we use [netcoredbg]
Install `netcoredbg` using your package manager, e.g.:

- Arch-based: `sudo pacman -S netcoredbg`
- Debian-based: `sudo apt install netcoredbg`
- For MacOS and Windows, follow the instructions on the [netcoredbg GitHub page]

### Test adapter

For running tests, we use the [neotest-dotnet] adapter for [neotest].

### Keymaps

- `<leader>N`: Opens the dotnet menu
- `<leader>t`: Opens the neotest menu
- `<leader>d`: Opens the debug menu
