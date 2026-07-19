local M = {}

M.options = {
  win_type = "floating-window", -- "floating-window" | "vsplit"
  keys = {
    run_spec = "<Leader>rs",
    run_all_specs = "<Leader>rss",
    toggle_terminal = "<Leader>st",
    toggle_spec = "<Leader>tt",
  },
}

local state = {
  view = {
    buf = -1,
    win = -1,
  },
}

local function view_buf()
  if not vim.api.nvim_buf_is_valid(state.view.buf) then
    state.view.buf = vim.api.nvim_create_buf(false, true)
  end
  return state.view.buf
end

local function open_floating_window(buf)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
end

local function open_vsplit_window(buf)
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

local function prepare_view()
  if vim.api.nvim_win_is_valid(state.view.win) then
    vim.api.nvim_set_current_win(state.view.win)
    return state.view
  end

  local buf = view_buf()

  if M.options.win_type == "floating-window" then
    state.view.win = open_floating_window(buf)
  elseif M.options.win_type == "vsplit" then
    state.view.win = open_vsplit_window(buf)
  else
    vim.notify("railsgun: unknown win_type: " .. tostring(M.options.win_type), vim.log.levels.WARN)
    return nil
  end

  -- :terminal converts the current (scratch) buffer in place, so the
  -- session survives toggling the window
  if vim.bo[buf].buftype ~= "terminal" then
    vim.cmd.terminal()
  end

  return state.view
end

local function build_test_command(line_number)
  local file_path = vim.fn.expand("%:p")

  if file_path == "" then
    vim.notify("railsgun: no file detected", vim.log.levels.WARN)
    return nil
  end

  local location = file_path .. (line_number and (":" .. line_number) or "")

  if file_path:match("_spec%.rb$") then
    return "bundle exec rspec " .. location
  elseif file_path:match("_test%.rb$") then
    return "rails test " .. location
  end

  vim.notify("railsgun: not a test file (must be *_spec.rb or *_test.rb)", vim.log.levels.WARN)
  return nil
end

local function run_test(line_number)
  -- build the command before switching away from the test file
  local cmd = build_test_command(line_number)
  if not cmd then
    return
  end

  local view = prepare_view()
  if not view then
    return
  end

  vim.fn.chansend(vim.bo[view.buf].channel, cmd .. "\r")
  vim.cmd.startinsert()
end

-- cursor positions per absolute file path, saved when toggling away
local positions = {}

-- Rails mirrors tests: app/models/user.rb <-> spec/models/user_spec.rb
-- (or test/models/user_test.rb), lib/x.rb <-> spec/lib/x_spec.rb.
-- The counterpart is computable from the path, so no searching is needed.
local function counterpart_candidates(rel)
  local rest = rel:match("^spec/(.*)_spec%.rb$") or rel:match("^test/(.*)_test%.rb$")
  if rest then
    return { "app/" .. rest .. ".rb", rest .. ".rb" }
  end

  local impl = rel:match("^app/(.*)%.rb$") or rel:match("^(.*)%.rb$")
  if impl then
    return { "spec/" .. impl .. "_spec.rb", "test/" .. impl .. "_test.rb" }
  end

  return {}
end

local function toggle_spec()
  local file = vim.api.nvim_buf_get_name(0)
  if not file:match("%.rb$") then
    vim.notify("railsgun: not a ruby file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, { "Gemfile", ".git" })
  if not root then
    vim.notify("railsgun: project root not found (no Gemfile or .git)", vim.log.levels.WARN)
    return
  end

  local rel = file:sub(#root + 2)
  local target
  for _, candidate in ipairs(counterpart_candidates(rel)) do
    local path = root .. "/" .. candidate
    if vim.uv.fs_stat(path) then
      target = path
      break
    end
  end

  if not target then
    vim.notify("railsgun: no counterpart found for " .. rel, vim.log.levels.WARN)
    return
  end

  positions[file] = vim.api.nvim_win_get_cursor(0)

  local was_loaded = vim.fn.bufloaded(target) == 1
  vim.cmd.edit(vim.fn.fnameescape(target))

  -- a loaded buffer already remembers its own cursor; otherwise restore
  -- the position from the last toggle, or the shada last-position mark
  if not was_loaded then
    if positions[target] then
      pcall(vim.api.nvim_win_set_cursor, 0, positions[target])
    else
      pcall(vim.cmd, [[normal! g`"]])
    end
  end
end

local function toggle_terminal()
  if vim.api.nvim_win_is_valid(state.view.win) then
    vim.api.nvim_win_hide(state.view.win)
  else
    prepare_view()
  end
end

local active_keys = {}

local function set_keymaps()
  for _, key in ipairs(active_keys) do
    pcall(vim.keymap.del, "n", key)
  end

  local keys = M.options.keys
  vim.keymap.set("n", keys.toggle_terminal, toggle_terminal, { desc = "Railsgun: toggle terminal" })
  vim.keymap.set("n", keys.run_spec, function()
    run_test(vim.api.nvim_win_get_cursor(0)[1])
  end, { desc = "Railsgun: run test under cursor" })
  vim.keymap.set("n", keys.run_all_specs, function()
    run_test()
  end, { desc = "Railsgun: run test file" })
  vim.keymap.set("n", keys.toggle_spec, toggle_spec, { desc = "Railsgun: toggle between test and implementation" })

  active_keys = { keys.toggle_terminal, keys.run_spec, keys.run_all_specs, keys.toggle_spec }
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.options, opts or {})
  set_keymaps()
end

vim.api.nvim_create_user_command("Railsgunterminal", toggle_terminal, {})
vim.api.nvim_create_user_command("Railsgunalternate", toggle_spec, {})
vim.api.nvim_create_user_command("Railsgun", function(opts)
  run_test(tonumber(opts.args))
end, { nargs = "*" })

set_keymaps()

return M
