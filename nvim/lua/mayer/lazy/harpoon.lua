return {
    'ThePrimeagen/harpoon',
    lazy = false,
    config = function()
      local mark = require 'harpoon.mark'
      local ui = require 'harpoon.ui'
      local term = require 'harpoon.term'
  
      vim.keymap.set('n', '<leader>ht', function()
        term.gotoTerminal(1)
      end, { desc = 'Go to terminal' })
  
      vim.keymap.set('n', '<leader>ha', function()
        mark.add_file()
      end, { desc = 'Add' })
  
      vim.keymap.set('n', '<leader>hr', function()
        mark.rm_file()
      end, { desc = 'Remove' })
  
      vim.keymap.set('n', '<leader>ho', function()
        ui.toggle_quick_menu()
      end, { desc = 'Toggle' })
  
      -- Harpoon Bindings to quick files
      vim.keymap.set('n', '<leader>1', function()
        ui.nav_file(1)
      end, { desc = 'Switch to harpoon 2' })
      vim.keymap.set('n', '<leader>2', function()
        ui.nav_file(2)
      end, { desc = 'Switch to harpoon 3' })
      vim.keymap.set('n', '<leader>3', function()
        ui.nav_file(3)
      end, { desc = 'Switch to harpoon 4' })
      vim.keymap.set('n', '<leader>4', function()
        ui.nav_file(4)
      end, { desc = 'Switch to harpoon 5' })
    end,
  }