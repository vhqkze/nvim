return {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift", "objc", "objcpp", "c", "cpp" },
    rook_markers = { "Package.swift", "buildServer.json", "compile_commands.json", ".git" },
    get_language_id = function(_, ftype)
        local t = { objc = "objective-c", objcpp = "objective-cpp" }
        return t[ftype] or ftype
    end,
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
        textDocument = {
            diagnostic = {
                dynamicRegistration = true,
                relatedDocumentSupport = true,
            },
        },
    },
}
