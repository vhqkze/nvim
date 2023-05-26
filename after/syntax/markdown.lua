vim.cmd([[syntax match unorderedlist '\v^\s*[-*]'hs=e conceal cchar=∙]])
vim.cmd([[syntax match todoCheckbox '\v(\s+)?(-|\*)\s\[\s\]'hs=e-4 conceal cchar=󰝣]])
vim.cmd([[syntax match todoCheckbox '\v(\s+)?(-|\*)\s\[X\]'hs=e-4 conceal cchar=󰄲]])
vim.cmd([[syntax match todoCheckbox '\v(\s+)?(-|\*)\s\[-\]'hs=e-4 conceal cchar=󰛲]])
