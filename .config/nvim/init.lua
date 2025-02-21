-- Iniciar packer.nvim para manejar plugins
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Autocompletion engine (nvim-cmp)
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  
  -- LSP and language servers for various languages
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  
  -- Snippets support for autocompletion
  use 'L3MON4D3/LuaSnip' 
  use 'saadparwaiz1/cmp_luasnip'
  
  -- Language servers for Go, Rust, C, Lua, C++, Python, JavaScript, TypeScript
  use 'williamboman/mason.nvim'  -- Easy LSP/DAP installation
  use 'williamboman/mason-lspconfig.nvim'
  
  -- Treesitter for syntax highlighting and additional features
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  
  -- Code formatting and linting
  use 'jose-elias-alvarez/null-ls.nvim'
  
  -- File explorer
  use 'nvim-tree/nvim-tree.lua'

  -- Terminal inside Neovim
  use 'akinsho/toggleterm.nvim'

  --use 'sheerun/vim-polyglot'  -- Añadir soporte básico para lenguajes no soportados por Treesitter

  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use 'kyazdani42/nvim-web-devicons'

  use { "catppuccin/nvim", as = "catppuccin" }

  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  use {
    'echasnovski/mini.map',
    branch = 'stable',
  }

end)

-- General settings
-- Numeración relativa de líneas
vim.g.mapleader = ","  -- Define la barra espaciadora como tecla Leader
vim.o.number = true        -- Activa la numeración de líneas
vim.o.relativenumber = true -- Activa la numeración relativa
vim.o.termguicolors = true

-- Gitsigns config
require('gitsigns').setup()

-- Minimap
require('mini.map').setup({
  -- Configure window size, symbol, etc. if needed
  integrations = {
    require('mini.map').gen_integration.builtin_search(),
    require('mini.map').gen_integration.gitsigns(),
  },
  symbols = {
    encode = require('mini.map').gen_encode_symbols.dot('4x2'),
  },
  window = {
    side = 'right',  -- Minimap will appear on the right side
    width = 10,      -- Adjust the width of the minimap
    winblend = 15,   -- Set transparency level
  },
})

-- Keybinding to toggle the minimap
vim.api.nvim_set_keymap('n', '<Leader>m', ':lua MiniMap.toggle()<CR>', { noremap = true, silent = true })


-- Load and configure Catppuccin theme
require("catppuccin").setup({
  flavour = "mocha", -- You can also choose "latte", "frappe", or "macchiato"
  transparent_background = false,
  term_colors = true,
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
    },
    lsp_trouble = true,
    cmp = true,
    gitsigns = true,
    telescope = true,
    nvimtree = {
      enabled = true,
      show_root = true,
      transparent_panel = false,
    },
    bufferline = true,
    markdown = true,
  }
})

-- Set the colorscheme
vim.cmd("colorscheme catppuccin")


-- Key bindings for essential features
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>t', ':ToggleTerm<CR>', { noremap = true, silent = true })

-- Configure LSP servers and completion
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'gopls',        -- Go
    'rust_analyzer',-- Rust
    'clangd',       -- C, C++
    'lua_ls',       -- Lua
    'pyright',      -- Python
    'ts_ls',     -- JavaScript, TypeScript
  }
})

-- LSP server settings
local lspconfig = require('lspconfig')
local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_lsp.default_capabilities()

-- Setup autocompletion
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})


local lspconfig = require'lspconfig'
local capabilities = require'cmp_nvim_lsp'.default_capabilities()


-- Configure each language server
local servers = { 'gopls', 'rust_analyzer', 'clangd', 'lua_ls', 'pyright', 'ts_ls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

-- Configure null-ls for linting and formatting
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "json", "yaml", "html", "css", "javascript", "typescript", "toml", "conf", "dockerfile", "containerfile" }
    }),
    null_ls.builtins.diagnostics.eslint.with({
      filetypes = { "javascript", "typescript" }
    }),
    -- Add other linters and formatters as needed for Go, Rust, C, etc.
  },
})

-- Terminal settings
require("toggleterm").setup{
  size = 20,
  open_mapping = [[<c-\>]],
  direction = 'horizontal',
  close_on_exit = true,
  shade_terminals = true,
}

-- Treesitter setup for syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = {
     "go", "rust", "c", "lua", "cpp", "python", "javascript", "typescript",
    "html", "css", "yaml", "json", "toml", "dockerfile"
  },
  highlight = {
    enable = true,
  },
}

require('telescope').setup{
  defaults = {
    prompt_prefix = "> ",
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
    },
  }
}

-- Configuración para nvim-tree
require('nvim-tree').setup {
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
}

-- Opcional: Si deseas que los íconos se vean en otros lugares además de nvim-tree
require('nvim-web-devicons').setup {
  default = true;
}

-- Keybindings comunes
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true, silent = true })

-- Keybindings:
-- <Leader>e : Toggle file explorer
-- <Leader>t : Toggle terminal
-- <C-\>     : Open terminal with key mapping
