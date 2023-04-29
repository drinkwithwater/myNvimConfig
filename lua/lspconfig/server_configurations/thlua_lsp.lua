local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { '/home/cz/project/TypeHintLua/3rd/vscode-lsp/server/lua', '/home/cz/project/TypeHintLua/bin/thls' },
    filetypes = { 'thlua' },
    root_dir = function(fname)
      return util.root_pattern("root.thlua")(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
    end,
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Log,
    settings = { },
  },
  docs = {
    description = [[  ]],
  },
}
