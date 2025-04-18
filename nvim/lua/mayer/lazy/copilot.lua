return {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
        -- Basic settings for copilot
        vim.g.copilot_no_tab_map = true

        -- Use <C-a> for accepting suggestions
        vim.keymap.set("i", "<C-a>", 'copilot#Accept("<CR>")', {
            expr = true,
            silent = true,
            replace_keycodes = false
        })

        -- Use <C-j> and <C-k> to navigate through suggestions
        vim.keymap.set("i", "<C-j>", 'copilot#Next()', {
            expr = true,
            silent = true
        })

        vim.keymap.set("i", "<C-k>", 'copilot#Previous()', {
            expr = true,
            silent = true
        })

        -- Disable copilot for certain file types if needed
        -- vim.g.copilot_filetypes = {
        --     ["*"] = true,
        --     ["markdown"] = false,
        -- }
    end
}
