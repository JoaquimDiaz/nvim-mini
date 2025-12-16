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
    repl_open_cmd = view.split.vertical(40),
  },

  keymaps = {
    -- REPL control
    toggle_repl = '<leader>rr',
    restart_repl = '<leader>rR',

    -- Sending code
    send_motion = '<leader>rc',
    visual_send = '<leader>rc',
    send_line = '<leader>rl',
    send_paragraph = '<leader>rp',
    send_until_cursor = '<leader>ru',
    send_file = '<leader>rF',

    -- Blocks / marks (optional but consistent)
    send_code_block = '<leader>rb',
    send_code_block_and_move = '<leader>rn',
    mark_motion = '<leader>rm',
    mark_visual = '<leader>rm',
    remove_mark = '<leader>rd',
  },
}

-- Extra UI helpers (not part of iron.setup)
vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>', { desc = 'REPL focus' })
vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>',  { desc = 'REPL hide' })
