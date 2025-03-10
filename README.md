# Railsgun.nvim

Railsgun.nvim is a lightweight Neovim plugin designed to quickly run **RSpec tests** in your Rails projects. Run individual tests or entire spec files instantly—without ever leaving Neovim.

## ✨ Features
- **Run RSpec tests inline or the whole file** with a single keybinding
- Configurable key mappings and settings

![Preview](https://imgur.com/i5EIglU.gif)


## 🚀 Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "ibramsterdam/railsgun.nvim",
  opts = {}, -- Uses default settings
}
```

## 🔧 Configuration
Railsgun allows you to configure options to customize behavior

```lua
{
  "ibramsterdam/railsgun.nvim",
  opts = {
    win_type = "floating-window", -- Use "vsplit" for a vertical split
    keys = {
      run_spec = "<Leader>rs",  -- Run test at cursor
      run_all_specs = "<Leader>rss",  -- Run entire spec file
    }
  }
}
```

## 🎯 Usage

### Keybindings (Default)
- **`<Leader>rs`** → Run RSpec test at the current line
- **`<Leader>rss`** → Run the entire spec file

### Running Tests via Command
You can also run tests with the `:Railsgun` command:
```vim
:Railsgun 15   " Runs test at line 15
:Railsgun      " Runs the whole file
```

## 📌 Contributing
Feel free to **open issues or pull requests** if you have improvements, bug fixes, or feature ideas!

## 📜 License
This plugin is licensed under the **MIT License**.

---
Enjoy fast and efficient testing with **Railsgun.nvim**! 🚀

