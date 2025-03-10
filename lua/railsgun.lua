local M = {}

M.options = {
  win_type = "floating-window",
  keys = {
    run_spec = "<Leader>rs",
    run_all_specs = "<Leader>rss",
  }
}

local state = {
  line_number = nil,
}

local function create_floating_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  vim.cmd.terminal()

  return { buf = buf, win = win }
end

local function create_vsplit_window()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd.terminal()

  return { buf = buf, win = vim.api.nvim_get_current_win() }
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

local create_view = function()
  if M.options.win_type == "floating-window" then
    return create_floating_window()
  elseif M.options.win_type == "vsplit" then
    return create_vsplit_window()
  else
    vim.notify("win_type unknown", vim.log.levels.WARN)
    return nil
  end
end

local run_rspec = function()
  local cmd = create_command()
  state.line_number = nil

  if cmd then
    local view = create_view()

    if view then
      vim.api.nvim_set_current_win(view.win)
      vim.schedule(function()
        vim.api.nvim_feedkeys(cmd, "t", false)
      end)
    end
  end
end

local set_keymaps = function()
  pcall(vim.keymap.del, "n", "<Leader>rss")
  pcall(vim.keymap.del, "n", "<Leader>rs")

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

vim.api.nvim_create_user_command("Railsgun", function(opts)
  if tonumber(opts.args) then
    state.line_number = opts.args
  end

  run_rspec()
end, { nargs = "*"})

set_keymaps()

return M

