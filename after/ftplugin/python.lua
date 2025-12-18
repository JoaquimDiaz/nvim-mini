vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

vim.g.python_indent = {
  open_paren = 'shiftwidth()',
  closed_paren_align_last_line = false,
}

vim.opt_local.indentkeys = "0{,0},0),0],:,!^F,o,O,e,<:>,=elif,=except"
