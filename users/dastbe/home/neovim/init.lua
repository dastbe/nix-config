-- Plugins are installed by nix (see default.nix); this file only configures
-- them. Keymaps lean on helix habits: space-prefixed pickers and LSP actions.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.showmode = false -- lualine shows it

--------------------------------------------------------------------------
-- Look
--------------------------------------------------------------------------

-- Frappe, to match ghostty and zellij.
require("catppuccin").setup({ flavour = "frappe" })
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({ options = { theme = "auto" } })
require("fidget").setup({})
require("gitsigns").setup({})
require("which-key").setup({ preset = "helix" })

-- Grammars come from nvim-treesitter.withAllGrammars; start highlighting
-- for any filetype that has one.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

--------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------

require("mini.ai").setup({})
require("mini.pairs").setup({})
require("mini.surround").setup({})

require("oil").setup({})
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  signature = { enabled = true },
})

require("conform").setup({
  formatters_by_ft = {
    go = { "gofmt" },
    lua = { "stylua" },
    nix = { "nixfmt" },
    rust = { "rustfmt" },
  },
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})

--------------------------------------------------------------------------
-- Pickers
--------------------------------------------------------------------------

local telescope = require("telescope")
local builtin = require("telescope.builtin")
telescope.setup({})
telescope.load_extension("fzf")

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<leader>f", builtin.find_files, "Find files")
map("<leader>/", builtin.live_grep, "Grep")
map("<leader>b", builtin.buffers, "Buffers")
map("<leader>s", builtin.lsp_document_symbols, "Document symbols")
map("<leader>S", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
map("<leader>d", builtin.diagnostics, "Diagnostics")
map("<leader>'", builtin.resume, "Resume last picker")

--------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------

-- nvim-lspconfig supplies the server definitions; neovim's built-in client
-- does the rest. Neovim already maps K (hover), grn (rename), gra (code
-- action), grr (references) and gri (implementation).
-- Point lua_ls at neovim's runtime so the vim.* API has types.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
    },
  },
})
vim.lsp.enable({ "gopls", "lua_ls", "nil_ls", "rust_analyzer" })

vim.diagnostic.config({ virtual_text = true })

map("gd", vim.lsp.buf.definition, "Go to definition")
map("gy", vim.lsp.buf.type_definition, "Go to type definition")
map("<leader>a", vim.lsp.buf.code_action, "Code action")
map("<leader>r", vim.lsp.buf.rename, "Rename symbol")
map("<leader>k", vim.lsp.buf.hover, "Hover")
