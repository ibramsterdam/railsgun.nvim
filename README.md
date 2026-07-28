# Railsgun.nvim

Railsgun.nvim is a lightweight Neovim plugin designed to quickly run **RSpec tests** or **MiniTest** in your Rails projects. Run individual tests or entire spec files instantly—without ever leaving Neovim.

## ✨ Features
- **Run RSpec or MiniTest tests inline or the whole file** with a single keybinding
- **Toggle between a file and its spec/test** (both directions), keeping your cursor position in each file
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
      toggle_terminal = "<Leader>st", -- Toggle terminal
      toggle_claude = "<Leader>sc", -- Toggle a Claude Code terminal
      toggle_spec = "<Leader>tt", -- Jump between test and implementation
    }
  }
}
```

## 🎯 Usage

### Keybindings (Default)
- **`<Leader>rs`** → Run RSpec test at the current line
- **`<Leader>rss`** → Run the entire spec file
- **`<Leader>st`** → Ability to toggle the terminal that is specified by the win_type
- **`<Leader>sc`** → Toggle a [Claude Code](https://claude.com/claude-code) terminal in your project root — the session keeps running while the window is hidden

The two floating panes act like a switch: opening one while the other is visible swaps them, so `<Leader>st`/`<Leader>sc` always bring up the pane you asked for. Both panes open in normal mode at the live end of the session, and the Claude pane runs with `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`, so the whole conversation stays in the terminal buffer as scrollback — scroll it with the usual vim motions and press `i` when you want to type (to Claude or the shell). Mouse clicks and selections in the pane stay plain Neovim behavior instead of being captured by Claude's fullscreen UI. Note: while a pane is in terminal-insert mode, keys go to the program — leave it with `<C-\><C-n>` (or your own mapping) before using the toggles.
- **`<Leader>tt`** → Jump between a file and its spec/test counterpart (`app/models/user.rb` ↔ `spec/models/user_spec.rb` or `test/models/user_test.rb`, `lib/` included), restoring the cursor position you left in each file

### Running Tests via Command
You can also run tests with the `:Railsgun` command:
```vim
:Railsgun 15   " Runs test at line 15
:Railsgun      " Runs the whole file
```

You can also toggle the terminal with `:Railsgunterminal`, the Claude terminal with `:Railsgunclaude`, and jump between test and implementation with `:Railsgunalternate`

## 📌 Contributing
Feel free to **open issues or pull requests** if you have improvements, bug fixes, or feature ideas!

## 📜 License
This plugin is licensed under the **MIT License**.

---
Enjoy fast and efficient testing with **Railsgun.nvim**! 🚀

