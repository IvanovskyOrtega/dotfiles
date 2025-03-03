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
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use 'nvim-treesitter/nvim-treesitter-context'

  use 'ray-x/lsp_signature.nvim'


end)

-- General settings
-- Numeración relativa de líneas
-- -- Lualine 
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
  transparent_background = true,
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
    ['<C-k>'] = cmp.mapping(function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      else
        vim.lsp.buf.hover()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })  -- Formatea el código antes de guardar
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" } }, -- Limpia los imports
      apply = true
    })
  end
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

-- Lualine 
require('lualine').setup {
  options = {
    theme = 'catppuccin',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    icons_enabled = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}

-- Treesitter context
require'treesitter-context'.setup{
  enable = true,  -- Activa el plugin
  max_lines = 5,  -- Máximo de líneas que se mostrarán en el encabezado
  trim_scope = 'outer', -- Elimina líneas innecesarias si el espacio es reducido
  mode = 'cursor',  -- Muestra el contexto de la función actual
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Activar firma de funciones
    require("lsp_signature").on_attach({
      bind = true,  -- Muestra la firma mientras escribes
      floating_window = true,  -- Usa una ventana flotante para mostrar la firma
      hint_enable = false,  -- Desactiva los hints en línea si molestan
      handler_opts = {
        border = "rounded"  -- Borde redondeado para la ventana flotante
      }
    }, bufnr)

    -- Autoformateo al guardar
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        vim.lsp.buf.format({ async = false })
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
      end
    })
  end
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
