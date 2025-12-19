-- REPL command ===============================================================

local function python_repl_cmd(meta)
  -- Get buffer number
  local bufnr = meta and meta.current_bufnr or vim.api.nvim_get_current_buf()

  -- Validate bufnr
  if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Find the root of the project
  local buf = vim.api.nvim_buf_get_name(bufnr)
  local start_path = buf ~= "" and vim.fs.dirname(buf) or vim.loop.cwd()
  local anchor = vim.fs.find({ ".venv", "pyproject.toml", "requirements.txt", ".git" }, {
    upward = true,
    path = start_path,
  })[1]
  local root = anchor and vim.fs.dirname(anchor) or vim.loop.cwd()
  local venv = vim.fs.joinpath(root, ".venv")
  local venv_ipy = vim.fs.joinpath(venv, "bin", "ipython")
  local venv_py = vim.fs.joinpath(venv, "bin", "python")

  -- Look for ipython / python executable
  -- Construct the 'cmd' from the first executable found
  local cmd
  if vim.fn.executable(venv_ipy) == 1 then
    cmd = { venv_ipy, "--no-autoindent", "--colors=Linux" }
  elseif vim.fn.executable(venv_py) == 1 then
    cmd = { venv_py, "-m", "IPython", "--no-autoindent", "--colors=Linux" }
  else
    cmd = { "ipython", "--no-autoindent", "--colors=Linux" }
  end

  return cmd
end

-- Iron Configuration =========================================================

local iron = require('iron.core')
local view = require('iron.view')
local common = require('iron.fts.common')

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = python_repl_cmd,
        format = common.bracketed_paste_python,
        block_dividers = { '# %%', '#%%' },
      },
    },
    repl_open_cmd = view.split.vertical(0.4)
  },

  keymaps = { },
}

-- Iron Keymaps ===============================================================

-- Mapping functions
local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

local nxmap = function(lhs, rhs, desc)
  vim.keymap.set({ 'n', 'x' }, lhs, rhs, { desc = desc })
end

-- Define a function to clear the REPL
local clear_repl = function()
  require('iron.core').send(nil, string.char(12))
end

-- Function to move the cursor after `send_code_block`
local send_code_block_and_move = function()
  iron.send_code_block(true)
end

-- REPL control
nmap('<leader>rr', '<Cmd>IronRepl<CR>',    'repl open')
nmap('<leader>rR', '<Cmd>IronRestart<CR>', 'repl restart')
nmap('<leader>rf', '<Cmd>IronFocus<CR>',   'repl focus')
nmap('<leader>rh', '<Cmd>IronHide<CR>',    'repl hide')
nmap('<leader>rc', clear_repl,             'Clear REPL')

-- Sending code
nmap('<leader>rl',  iron.send_line,          'send line')
nmap('<leader>rp',  iron.send_paragraph,     'send paragraph')
nmap('<leader>ru',  iron.send_until_cursor,  'send until cursor')
nmap('<leader>rF',  iron.send_file,          'send file')


-- Blocks / marks
nmap('<leader>rb', iron.send_code_block,            'send block')
nmap('<leader>rn', send_code_block_and_move,        'send block + move')
nxmap('<leader>rm', iron.mark_motion,               'mark')


-- Jumping between cells ======================================================

local function cell_jump(dir)
  local patterns = { [[^# %%$]], [[^#%%$]] }
  local flags = (dir == 'next') and 'W' or 'bW'

  -- If you're on a divider and going "next", skip the current one
  if dir == 'next' then
    local line = vim.fn.getline('.')
    if line:match(patterns[1]) or line:match(patterns[2]) then
      vim.cmd('normal! j')
    end
  end

  for _, pat in ipairs(patterns) do
    if vim.fn.search(pat, flags) ~= 0 then return end
  end
end

nmap(']n', function() cell_jump('next') end, 'Next cell divider')
nmap('[n', function() cell_jump('prev') end, 'Previous cell divider')

-- "first/last" like mini.bracketed does for built-ins:
nmap('[N', function()
  vim.cmd('normal! gg')
  cell_jump('next')
end, 'First cell divider')

nmap(']N', function()
  vim.cmd('normal! G')
  cell_jump('prev')
end, 'Last cell divider')
