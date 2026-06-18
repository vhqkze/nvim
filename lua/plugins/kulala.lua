local kulala = require("kulala")
local kulala_ui = require("kulala.ui")

local function prettier_format(parser, body)
    local cmd = { "prettier", "--no-config", "--parser", parser, "--print-width", "120", "--tab-width", "4" }
    local obj = vim.system(cmd, { text = true, stdin = body }):wait()
    if obj.code == 0 then
        return vim.trim(obj.stdout)
    else
        vim.notify(vim.inspect(obj))
        return body
    end
end

local lsp_attach = function(_, bufnr)
    vim.keymap.set("n", "<leader>kk", kulala.run, { buf = bufnr, desc = "Send request" })
    vim.keymap.set("n", "<leader>kr", kulala.replay, { buf = bufnr, desc = "Replay the last request" })
    vim.keymap.set("n", "<leader>kK", kulala.run_all, { buf = bufnr, desc = "Send all requests" })
    vim.keymap.set("n", "<leader>kt", kulala.toggle_view, { buf = bufnr, desc = "Toggle headers/body" })
    vim.keymap.set("n", "<leader>kc", kulala.copy, { buf = bufnr, desc = "Copy as cURL" })
    vim.keymap.set("n", "<leader>kp", kulala.from_curl, { buf = bufnr, desc = "Paste from curl" })
    vim.keymap.set("n", "<leader>kf", kulala.search, { buf = bufnr, desc = "Find request" })
    vim.keymap.set("n", "]r", kulala.jump_next, { buf = bufnr, desc = "Jump to next request" })
    vim.keymap.set("n", "[r", kulala.jump_prev, { buf = bufnr, desc = "Jump to previous request" })
    vim.keymap.set("n", "<leader>kC", kulala.clear_cached_files, { buf = bufnr, desc = "Find request" })

    vim.keymap.set("n", "<leader>kh", kulala_ui.show_headers, { buf = bufnr, desc = "Show headers" })
    vim.keymap.set("n", "<leader>kb", kulala_ui.show_body, { buf = bufnr, desc = "Show body" })
    vim.keymap.set("n", "<leader>ka", kulala_ui.show_headers_body, { buf = bufnr, desc = "Show headers and body" })
    vim.keymap.set("n", "<leader>kv", kulala_ui.show_verbose, { buf = bufnr, desc = "Show verbose" })
    vim.keymap.set("n", "<leader>ks", kulala_ui.show_script_output, { buf = bufnr, desc = "Show script output" })
    vim.keymap.set("n", "<leader>kS", kulala_ui.show_stats, { buf = bufnr, desc = "Show stats" })
    vim.keymap.set("n", "<leader>kR", kulala_ui.show_report, { buf = bufnr, desc = "Show report" })
    vim.keymap.set("n", "<leader>k?", kulala_ui.show_help, { buf = bufnr, desc = "Show help" })
    vim.keymap.set("n", "<leader>kq", kulala_ui.jump_to_response, { buf = bufnr, desc = "Jump to response" })
    vim.keymap.set("n", "<leader>kx", kulala_ui.clear_responses_history, { buf = bufnr, desc = "Clear responses history" })
    vim.keymap.set("n", "<leader>kw", kulala_ui.close_kulala_buffer, { buf = bufnr, desc = "Close kulala window" })

    vim.keymap.set("n", "<leader>ke", function()
        local response = kulala_ui.get_current_response()
        local buf = vim.api.nvim_create_buf(true, false)
        local contents = vim.split(response.body_raw, "\n")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
        local contenttype = require("kulala.internal_processing").get_config_contenttype(response.headers)
        local filetype = contenttype.ft
        vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
    end, { buf = bufnr, desc = "Edit response body" })
end

kulala.setup({
    contenttypes = {
        ["application/json"] = {
            ft = "json",
            formatter = function(body)
                return prettier_format("json", body)
            end,
        },
        ["text/html"] = {
            ft = "html",
            formatter = function(body)
                return prettier_format("html", body)
            end,
        },
        ["application/javascript"] = {
            ft = "javascript",
            formatter = function(body)
                return prettier_format("babel", body)
            end,
        },
        ["application/xml"] = {
            ft = "xml",
            formatter = function(body)
                return prettier_format("html", body)
            end,
        },
        ["application/rss+xml"] = {
            ft = "xml",
            -- formatter = {"xmllint", "--format", "--html", "--pretty", "1", "-"}
            formatter = function(body)
                return prettier_format("html", body)
            end,
        },
        ["application/atom+xml"] = {
            ft = "xml",
            formatter = function(body)
                return prettier_format("html", body)
            end,
        },
        ["text/css"] = {
            ft = "css",
            formatter = function(body)
                return prettier_format("css", body)
            end,
        },
        ["image/svg+xml"] = {
            ft = "svg",
            formatter = function(body)
                return prettier_format("html", body)
            end,
        },
    },
    response_format = {
        indent = 4,
        expand_tabs = true,
        sort_keys = false,
    },
    ui = {
        max_response_size = 1024 * 1024 * 10, -- 10MB
        win_opts = {
            wo = {
                number = true,
            },
        },
        default_winbar_panes = { "body", "headers", "headers_body", "verbose", "script_output", "stats", "report" },
        icons = {
            inlay = {
                loading = "󰔟",
                done = " ",
                error = " ",
            },
        },
        show_request_summary = false,
        report = {
            show_summary = true,
        },
        disable_news_popup = true,
    },
    lsp = {
        filetypes = { "http", "rest" },
        on_attach = lsp_attach,
    },
    global_keymaps = false,
    kulala_keymaps = {
        ["Previous tab"] = { "<s-tab>", kulala_ui.show_previous_tab, mode = { "n" } },
        ["Next tab"] = { "<tab>", kulala_ui.show_next_tab, mode = { "n" } },
    },
})
