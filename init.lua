-- 21-12-2025 (Windows wsl)

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.swapfile = false
vim.opt.wildmenu = true -- for having auto-completion in command pane with tab

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
--
vim.g.mapleader = " ";

--file explorer
vim.keymap.set("n", "<leader>e", ":Ex<CR>")
vim.keymap.set("n", "<leader>ve", ":Vex<CR>")

--terminal
vim.keymap.set("n", "<leader>t", ":split | resize 10 | terminal bash<CR>")
vim.keymap.set("n", "<leader>vt", ":vsplit | terminal bash<CR>")

--hide not close the buffer for terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.bo.bufhidden = "hide"
  end,
})

-- :Cmd for shell commands
vim.api.nvim_create_user_command("Cmd", function()
  local cmd = vim.fn.input("command: ")
  local mode = vim.fn.input("mode (s=stream, t=time): ")
  if mode == "" then mode = "s" end  -- default to streaming

  local stderr_lines = {}
  local qf_items = {}

  local streaming = (mode == "s")

  -- clear quickfix
  vim.fn.setqflist({}, 'r', { title = cmd })

  if mode == "t" then cmd = "time " .. cmd end -- concat

  vim.fn.jobstart(cmd, {
    stdout_buffered = not streaming,
    stderr_buffered = not streaming,

    on_stdout = function(_, data)
      if not data then return end

      if streaming then
        -- streaming mode 
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(qf_items, { text = line })
          end
        end

        vim.fn.setqflist({}, 'r', {
          title = cmd,
          items = qf_items,
        })

        vim.cmd("cbottom")
      else
        -- time mode 
        if #data > 0 then
          vim.fn.setqflist({}, ' ', {
            title = cmd,
            lines = data,
          })
        end
      end
    end,

    on_stderr = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(stderr_lines, line)
        end
      end
    end,

    on_exit = function()
      if #stderr_lines > 0 then
        print("Error:\n" .. table.concat(stderr_lines, "\n"))
      end
    end,
  })

  vim.cmd("copen")
end, {})



--grep
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.keymap.set("n", "<leader>co", ":copen<CR>")

-- copy paste to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>yy", '"+yy')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')

--highlighting
vim.opt.syntax = on
vim.opt.termguicolors = true
vim.opt.hlsearch = on
vim.opt.incsearch = true

-- fold
-- zc  " close fold under cursor
-- zo  " open fold under cursor
-- za  " toggle fold under cursor
-- zR  " open all folds
-- zM  " close all folds
vim.opt.foldenable = true
--vim.opt.foldmethod = "indent"
--
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
--
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", 
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--lazy
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy")
require("lazy").setup({
  {
    "nvim-lua/plenary.nvim",
    lazy = false
  },
  {
    "ThePrimeagen/harpoon",
    lazy = false
  },
  {
    "vim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require 'nvim-treesitter'.setup {
        highlight = { enable = true },
        indent = { enable = true },
        fold = { enable = true },
        auto_install = true,
      }
    end
  },
 {
    "nvim-telescope/telescope.nvim",
    lazy = false
  },
  -- themes
  {
    "EdenEast/nightfox.nvim",
    lazy = false
    -- carbonfox, dawnfox, nightfox, duskfox, dayfox, terafox, nordfox
  },
  {
    "catppuccin/nvim",
    lazy = false
    -- catppuccin-macchiato, catppuccin-frappe, catppuccin-mocha, catppuccin-latte
  },
  {
    "uhs-robert/oasis.nvim",
    lazy = false
    -- oasis-dust, oasis-desert, oasis-dawnlight, oasis-dawn, oasis-night, oasis-rose, oasis-abis,
    -- oasis-starlight, oasis-cactus, oasis-lagoon, oasis-mirage, oasis-twilight
  },

  --lsp
  {
    "neovim/nvim-lspconfig",
    lazy = false
  },
  {
    "williamboman/mason.nvim",
    lazy = false
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false
  },
  {
    "hrsh7th/nvim-cmp", --autocomplete
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  }


})


--theme
vim.cmd("colorscheme oasis-lagoon")

-- NAVIGATION
-- [{  previous block
-- ]}  next block
-- *  search word under cursor
-- gd (without LSP) → local declaration
-- gg  top of file
-- G  bottom of file
-- 0 or ^ start of line
-- $ end of line
-- ''  jump back to last location 
-- <C-o> for next position
-- <C-i> for next position
--
-- MARKS :marks 
-- mA to add mark A (small case for marks in current buffer)
-- 'A or `A  to go to mark A
-- `. 	jump to position where last change occurred in current buffer
-- `" 	jump to position where last exited current buffer
-- `0 	jump to position in last file edited (when exited Vim)
-- `1 	like `0 but the previous file (also `2 etc)
-- '' 	jump back (to line in current buffer where jumped from)
-- `` 	jump back (to position in current buffer where jumped from)
-- `[ or `] 	jump to beginning/end of previously changed or yanked text
-- `< or `> 	jump to beginning/end of last visual selection
--
-- EXTRA
-- The :g command is useful to apply a command to all lines matching a search.
-- :g/pattern/d will delete all lines matching pattern. more
-- Using the * key searches for the word under the cursor. 
-- Use # to do the same thing backwards. more
-- Using the % key on brackets ([{<>}]) will find the matching one. 
-- Using the . key will repeat last change.

--harpoon
require('harpoon').setup()
local mark = require('harpoon.mark')
local ui   = require('harpoon.ui')

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
vim.keymap.set("n", "<leader>hn", ui.nav_next)
vim.keymap.set("n", "<leader>hp", ui.nav_prev)

-- telescope
require('telescope').load_extension('harpoon')
local t = require('telescope.builtin')

vim.keymap.set('n', '<leader>ft', t.builtin)
vim.keymap.set('n', '<leader>ff', t.find_files)
vim.keymap.set('n', '<leader>fg', t.live_grep)
vim.keymap.set('n', '<leader>fb', t.buffers)
vim.keymap.set('n', '<leader>fh', t.help_tags)
-- =============================================================================
-- TELESCOPE USEFUL METHODS REFERENCE
-- =============================================================================
-- Usage: require('telescope.builtin').<method_name>()

-- 📂 FILE NAVIGATION
-- find_files          -> Search for files by name (respects .gitignore)
-- git_files           -> Search for files tracked by Git (extremely fast)
-- oldfiles            -> Recently opened files
-- buffers             -> List currently open buffers
-- find_command        -> Define a custom command to find files (e.g., fd, find)

-- 🔍 SEARCH & TEXT
-- live_grep           -> Search for string across all files (as you type)
-- grep_string         -> Search for word under cursor in the project
-- current_buffer_fuzzy_find -> Search for string inside current file only

-- 🧠 LSP (CODE INTELLIGENCE)
-- lsp_definitions      -> Jump to definition of word under cursor
-- lsp_references       -> List all usages of word under cursor
-- lsp_implementations   -> Find interface implementations
-- lsp_type_definitions -> Find type definitions
-- lsp_document_symbols -> List all functions/variables in current file
-- lsp_workspace_symbols -> List all functions/variables in whole project
-- diagnostics          -> List all linting errors/warnings in project

-- 🌿 GIT INTEGRATION
-- git_status          -> List changed files with diff preview
-- git_commits         -> Browse project commit history
-- git_bcommits        -> Browse commit history for the current buffer
-- git_branches        -> List, switch, and delete branches
-- git_stash           -> List and apply stashes

-- ⚙️ NEOVIM INTERNALS
-- help_tags           -> Search Neovim documentation (:help)
-- keymaps             -> Search all currently active keybindings
-- commands            -> List all available Vim commands
-- vim_options         -> Browse and search through Neovim settings
-- colorscheme         -> Live preview and switch themes
-- marks               -> List and jump to your marks
-- registers           -> View and paste from your clipboards/registers

-- 🧪 EXTENSIONS (If installed)
-- telescope.extensions.fzf.fzf -> Faster C-based fuzzy matching
-- telescope.extensions.ui-select -> Use telescope for native vim.ui selects
-- =============================================================================

--auto complete

local cmp = require("cmp")
local capabilities = require('cmp_nvim_lsp').default_capabilities()
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = "buffer" },
    { name = "path" },
  },

  completion = {
    -- autocomplete = false,
    -- completeopt = 'menu,menuone,noinsert,noselect',
    keyword_length = 5
  },

  --snippet = {
   -- expand = function(args)
    --  require("luasnip").lsp_expand(args.body)
   -- end,
  --},

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<Esc>"] = cmp.mapping.abort(),
  }),

})

--lsp
require("mason").setup()
require("mason-lspconfig").setup(
  {
    ensure_installed = {
      "lua_ls"
    },
  }

)

vim.keymap.set({ "n", "v" }, '<leader>lf', vim.lsp.buf.format)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set({ "n", "v" }, '<leader>k', vim.diagnostic.open_float)

