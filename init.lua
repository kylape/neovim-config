vim.g.mapleader = "<Space>"
vim.g.maplocalleader = "<Space><Space>"

require("config.lazy")

local vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--hidden") -- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--glob") -- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "!**/.git/*")

require('telescope').setup{
  extensions = {
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
      filetypes = {"png", "webp", "jpg", "jpeg"},
      -- find command (defaults to `fd`)
      find_cmd = "rg"
    }
  },
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-k>"] = "move_selection_previous",
        ["<C-j>"] = "move_selection_next",
        ["<C-u>"] = false
      }
    }
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
    },
  }
}

require('telekasten').setup({
  home = vim.fn.expand("~/src/zettelkasten"),
})

require("mcphub").setup({
    auto_approve = true,
    extensions = {
        avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
        }
    }
})

require("avante").setup({
    -- other config
    -- The system_prompt type supports both a string and a function that
    -- returns a string. Using a function here allows dynamically updating the
    -- prompt with mcphub
    system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
    end,
    -- The custom_tools type supports both a list and a function that returns a
    -- list. Using a function here prevents requiring mcphub before it's loaded
    custom_tools = function()
        return {
            require("mcphub.extensions.avante").mcp_tool(),
        }
    end,
})

-- Launch panel if nothing is typed after <leader>z
vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten panel<CR>")

-- Most used functions
vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
vim.keymap.set("n", "<leader>zt", "<cmd>Telekasten goto_today<CR>")
vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten follow_link<CR>")
vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
vim.keymap.set("n", "<leader>zr", "<cmd>Telekasten show_backlinks<CR>")
vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")

-- Call insert link automatically when we start typing a link
vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>k', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<leader>r', '<cmd>Telescope lsp_references<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'ts_ls', 'clangd' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

nvim_lsp['gopls'].setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = { gopls = {
    buildFlags = {"-tags=test_e2e,sql_integration,scanner_e2e"}
  }},
}

nvim_lsp['groovyls'].setup{
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = { groovyls = {
    cmd = { "/usr/lib/jvm/java-17-openjdk/bin/java", "-jar", "/home/klape/src/groovy-language-server/build/libs/groovy-language-server-all.jar" },
  }},
  cmd = { "/usr/lib/jvm/java-17-openjdk/bin/java", "-jar", "/home/klape/src/groovy-language-server/build/libs/groovy-language-server-all.jar" },
}

nvim_lsp['yamlls'].setup({
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    yaml = {
      completion = true,
      validate = true,
      format = {
        enable = true,
      },
      schemas = {
        ["/home/klape/src/kubernetes-json-schema/v1.33.0-local/deployment-apps-v1.json"] = "/deploy-*.yaml",
        ["/home/klape/src/kubernetes-json-schema/v1.33.0-local/persistentvolumeclaim-v1.json"] = "/pvc-*.yaml",
      },
    },
  }
})

require'lspconfig'.terraformls.setup{}

local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)
