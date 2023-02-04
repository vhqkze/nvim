local autosave = require("auto-save")
autosave.setup({
    enabled = true,
    execution_message = {
        message = function()
            return ("   " .. vim.fn.strftime("%H:%M:%S"))
        end,
        dim = 0.18,
        cleaning_interval = 1250,
    },
    trigger_events = { "InsertLeave", "TextChanged" },
    conditions = function(buf)
        local utils = require("auto-save.utils.data")
        local disable_filetypes = {}
        if vim.fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(vim.fn.getbufvar(buf, "&filetype"), disable_filetypes) then
            return true
        end
        return false
    end,
    write_all_buffers = false,
})
