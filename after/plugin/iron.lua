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

local send_code_block_and_move = function()
  iron.send_code_block(true)
end

-- Blocks / marks
nmap('<leader>rb', iron.send_code_block,            'send block')
nmap('<leader>rn', send_code_block_and_move,        'send block + move')
nxmap('<leader>rm', iron.mark_motion,               'mark')
