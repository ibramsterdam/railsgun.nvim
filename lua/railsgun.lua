local M = {}

M.options = {
  win_type = "floating-window",
  keys = {
    run_spec = "<Leader>rs",
    run_all_specs = "<Leader>rss",
    toggle_terminal = "<Leader>st",
  }
}

local state = {
  line_number = nil,
  view = {
    buf = -1,
    win = -1,
  }
}

local function prepare_floating_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  local buf = nil

  if vim.api.nvim_buf_is_valid(state.view.buf) then
    buf = state.view.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
    state.view.buf = buf
  end

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  if vim.bo[buf].buftype ~= "terminal" then
    vim.cmd.terminal()
  end

  state.view.buf = buf
  state.view.win = win
  return { buf = buf, win = win}
end

local function prepare_vsplit_window()
  local buf = nil
  local win = nil

  if vim.api.nvim_buf_is_valid(state.view.buf) then
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, state.view.buf)
  else
    buf = vim.api.nvim_create_buf(false, true)
    state.view.buf = buf

    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, buf)
    vim.cmd.terminal()
  end

  win = vim.api.nvim_get_current_win()
  state.view.win = win
  return { buf = buf, win = win }
end

local cursor_row_location = function()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local create_command = function()
  local file_path = vim.fn.expand("%:p")

  if file_path == "" then
    vim.notify("No file detected", vim.log.levels.WARN)
    return nil
  end

  if not file_path:match("_spec%.rb$") then
    vim.notify("Not an RSpec file", vim.log.levels.WARN)
    return nil
  end

  return "i bundle exec rspec " .. file_path .. (state.line_number and (":" .. state.line_number) or "") .. "\n"
end

local prepare_view = function()
  if M.options.win_type == "floating-window" then
    return prepare_floating_window()
  elseif M.options.win_type == "vsplit" then
    return prepare_vsplit_window()
  else
    vim.notify("win_type unknown", vim.log.levels.WARN)
    return nil
  end
end

local run_rspec = function()
  local cmd = create_command()
  state.line_number = nil

  if cmd then
    local view = prepare_view()

    if view then
      vim.api.nvim_set_current_win(view.win)
      vim.schedule(function()
        vim.api.nvim_feedkeys(cmd, "t", false)
      end)
    end
  end
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.view.win) then
    prepare_view()
  else
    if M.options.win_type == "vsplit" then
      vim.cmd("hide")
    else
      vim.api.nvim_win_hide(state.view.win)
    end
  end
end

local set_keymaps = function()
  pcall(vim.keymap.del, "n", "<Leader>rss")
  pcall(vim.keymap.del, "n", "<Leader>rs")
  pcall(vim.keymap.del, "n", "<Leader>rt")

  vim.keymap.set("n", M.options.keys.toggle_terminal, toggle_terminal)
  vim.keymap.set("n", M.options.keys.run_spec, function()
    state.line_number = cursor_row_location()
    run_rspec()
  end, { desc = "Run RSpec on current line" })

  vim.keymap.set("n", M.options.keys.run_all_specs, function()
    run_rspec()
  end, { desc = "Run RSpec on entire file" })
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.options, opts or {})
  set_keymaps()
end

vim.api.nvim_create_user_command("Railsgunterminal", toggle_terminal, {})
vim.api.nvim_create_user_command("Railsgun", function(opts)
  if tonumber(opts.args) then
    state.line_number = opts.args
  end

  run_rspec()
end, { nargs = "*"})

set_keymaps()

return M

