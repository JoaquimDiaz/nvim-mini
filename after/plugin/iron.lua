-- Iron Configuration =========================================================

local iron = require('iron.core')
local view = require('iron.view')
local common = require('iron.fts.common')

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = { 'ipython', '--no-autoindent' },
        format = common.bracketed_paste_python,
        block_dividers = { '# %%', '#%%' },
      },
    },
    repl_open_cmd = view.split.vertical(0.4)
  },

  keymaps = { },
}

-- Iron Keymaps ===============================================================

local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

local nxmap = function(lhs, rhs, desc)
  vim.keymap.set({ 'n', 'x' }, lhs, rhs, { desc = desc })
end

-- REPL control
nmap('<leader>rr', '<cmd>IronRepl<cr>',    'repl open')
nmap('<leader>rR', '<cmd>IronRestart<cr>', 'repl restart')
nmap('<leader>rf', '<cmd>IronFocus<cr>',   'repl focus')
nmap('<leader>rh', '<cmd>IronHide<cr>',    'repl hide')

-- Sending code
nmap('<leader>rl',  iron.send_line,          'send line')
nmap('<leader>rp',  iron.send_paragraph,     'send paragraph')
nmap('<leader>ru',  iron.send_until_cursor,  'send until cursor')
nmap('<leader>rF',  iron.send_file,          'send file')
nxmap('<leader>rc', iron.send_motion,        'send chunk')

-- Function to move the cursor after `send_code_block`
local send_code_block_and_move = function()
  iron.send_code_block(true)
end

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
