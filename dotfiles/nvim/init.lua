vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 6
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

-- Plugins are pinned by Nix. Lazy only handles loading and dependency order.
require("lazy").setup(nix_plugins, {
	defaults = { lazy = false },
	install = { missing = false },
	checker = { enabled = false },
	change_detection = { enabled = false },
	pkg = { enabled = false },
	rocks = { enabled = false },
	performance = {
		reset_packpath = false,
		rtp = { reset = false },
	},
})

-- Treesitter parsers are built by Nix; Neovim must never install them at runtime.
require("nvim-treesitter").setup({})
vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable Treesitter highlighting when a parser is available",
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

local telescope = require("telescope.builtin")
require("telescope").setup({
	defaults = {
		mappings = { i = { ["<C-u>"] = false, ["<C-d>"] = false } },
	},
})
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Grep repository" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Search help" })

require("neo-tree").setup({
	close_if_last_window = true,
	filesystem = {
		follow_current_file = { enabled = true },
		hijack_netrw_behavior = "open_current",
	},
	window = {
		width = 32,
		mappings = {
			["<space>"] = "none",
		},
	},
})
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Make `nvim .` open the project tree and use the directory as Neovim's cwd.
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Open Neo-tree when Neovim starts with a directory",
	callback = function()
		local directory = vim.fn.argv(0)
		if vim.fn.argc() ~= 1 or directory == "" or vim.fn.isdirectory(directory) == 0 then
			return
		end

		vim.cmd.cd(vim.fn.fnameescape(directory))
		require("neo-tree.command").execute({ action = "show", dir = directory })
	end,
})

require("which-key").setup({ delay = 300 })
require("which-key").add({
	{ "<leader>d", group = "debug" },
	{ "<leader>l", group = "lint" },
	{ "<leader>r", group = "refactor" },
	{ "<leader>x", group = "diagnostics" },
})
vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<CR>", { desc = "Show all keybindings" })

require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<CR>"] = { "accept", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
	},
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 300 },
	},
	signature = { enabled = true },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = true,
	signs = true,
	virtual_text = true,
})
vim.keymap.set("n", "<leader>xx", telescope.diagnostics, { desc = "Workspace diagnostics" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	capabilities = capabilities,
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				nilness = true,
				shadow = true,
				unusedparams = true,
				unusedwrite = true,
			},
		},
	},
})
vim.lsp.enable("gopls")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Go LSP keybindings",
	callback = function(event)
		local map = function(keys, action, description)
			vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gr", vim.lsp.buf.references, "Find references")
		map("gi", vim.lsp.buf.implementation, "Go to implementation")
		map("K", vim.lsp.buf.hover, "Hover documentation")
		map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
	end,
})

local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		go = { "goimports", "gofumpt" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		sh = { "shfmt" },
	},
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},
})
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

local lint = require("lint")
lint.linters_by_ft = { go = { "golangcilint" } }
vim.api.nvim_create_autocmd("BufWritePost", {
	desc = "Run golangci-lint after saving Go files",
	callback = function()
		lint.try_lint()
	end,
})
vim.keymap.set("n", "<leader>ll", function()
	lint.try_lint()
end, { desc = "Run golangci-lint" })

local dap = require("dap")
local dap_go = require("dap-go")
dap_go.setup({ delve = { path = "dlv" } })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug continue/start" })
vim.keymap.set("n", "<leader>dt", dap_go.debug_test, { desc = "Debug nearest Go test" })
vim.keymap.set("n", "<leader>dl", dap_go.debug_last_test, { desc = "Debug last Go test" })
vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Stop debugger" })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})
