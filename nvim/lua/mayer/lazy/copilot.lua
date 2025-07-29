return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "github/copilot.vim",
    -- Optional but recommended dependencies
    "hrsh7th/nvim-cmp",  -- For completion in chat buffer
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
    { "stevearc/dressing.nvim", opts = {} }
  },
  config = function()
    -- Disable Tab mapping for Copilot - this is crucial!
    vim.g.copilot_no_tab_map = true
    
    require("codecompanion").setup({
      -- Configure adapters
      adapters = {
        -- For GitHub Copilot
        copilot = function()
          -- Use extend instead of get
          return require("codecompanion.adapters").extend("copilot")
        end,

        -- If you want to have OpenAI as an alternative, uncomment this
        -- openai = function()
        --   return require("codecompanion.adapters").extend("openai", {
        --     env = {
        --       api_key = os.getenv("OPENAI_API_KEY"), -- Use environment variable
        --     },
        --     schema = {
        --       model = {
        --         default = "gpt-4o",
        --       },
        --     },
        --   })
        -- end,
      },

      -- General settings
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = "CodeCompanion: ",
          provider = "telescope",
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
      },

      -- Strategy settings for chat and inline
      strategies = {
                chat = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4",
      },
    },
        -- chat = {
        --   adapter = "copilot",  -- Use Copilot adapter for chat
        --   model = "claude-sonnet-4",  -- Specify the model for chat
        -- },
        inline = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4",
      },
          auto_trigger = true,
          trigger_chars = 3,
          accept = "<C-a>",
        },
        cmd = {
      adapter = {
        name = "copilot",
        model = "claude-sonnet-4",
      },
                }
      },
    })

    -- Keybindings
    vim.keymap.set("i", "<C-a>", 'copilot#Accept("<CR>")', {
        expr = true,
        silent = true,
        replace_keycodes = false
    })
    vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>ce", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
  end
}
-- return {
--     "github/copilot.vim",
--     event = "InsertEnter",
--     config = function()
--         -- Basic settings for copilot
--         vim.g.copilot_no_tab_map = true
--
--         -- Use <C-a> for accepting suggestions
--
--         -- Use <C-j> and <C-k> to navigate through suggestions
--         vim.keymap.set("i", "<C-j>", 'copilot#Next()', {
--             expr = true,
--             silent = true
--         })
--
--         vim.keymap.set("i", "<C-k>", 'copilot#Previous()', {
--             expr = true,
--             silent = true
--         })
--
--         -- Enable copilot for all filetypes by default
--         vim.g.copilot_filetypes = {
--             ["*"] = true
--         }
--     end
-- }
