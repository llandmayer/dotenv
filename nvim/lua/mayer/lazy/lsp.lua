return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                python = { "ruff_format", "ruff_fix" },
                php = { "phpcbf" },
                html = { "prettier" },
                css = { "prettier" },
                blade = { "blade-formatter" },
                typescript = { "prettier", "eslint_d" },
                javascript = { "prettier", "eslint_d" },
                javascriptreact = { "prettier", "eslint_d" },
                typescriptreact = { "prettier", "eslint_d" },
                json = { "prettier" },
                yaml = { "prettier" },
                dockerfile = { "hadolint" },
                markdown = { "prettier" },
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        -- LSP attach configuration
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                map('K', vim.lsp.buf.hover, 'Hover Documentation')

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end,
        })

        require("fidget").setup({})
        require("mason").setup()
        require("mason-registry").refresh(function()
            -- This will install typescript-language-server if it's not already installed
            local mr = require("mason-registry")
            if not mr.is_installed("typescript-language-server") then
                vim.notify("Installing typescript-language-server...", vim.log.levels.INFO)
                mr.get_package("typescript-language-server"):install()
            end
        end)
        require("mason-lspconfig").setup({
            ensure_installed = {
                "terraformls",
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "pyright",
                "ruff",         -- The Mason package name
                "intelephense",
                "html",
                "cssls",
                "ts_ls",
                "eslint",
                "tailwindcss",
                "dockerls",
                "jsonls",
                "yamlls",
            },
            handlers = {
                function(server_name) -- default handler
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["ruff"] = function()
                    require("lspconfig").ruff.setup({  -- Use ruff_lsp for lspconfig
                        capabilities = capabilities,
                        settings = {
                            -- Ruff configuration options
                        }
                    })
                end,
                ["intelephense"] = function()
                    require("lspconfig").intelephense.setup({
                        capabilities = capabilities,
                        filetypes = { "php" },
                        -- Fallback to current directory if no project markers found
                        root_dir = function(fname)
                            return require("lspconfig").util.root_pattern("composer.json", ".git", "artisan")(fname)
                                or vim.loop.cwd()
                        end,
                        settings = {
                            intelephense = {
                                environment = {
                                    phpVersion = "8.2", -- Adjust to your PHP version
                                },
                                files = {
                                    associations = { "*.php", "*.phtml" },
                                    maxSize = 5000000,
                                },
                                stubs = {
                                    "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype",
                                    "curl", "date", "dba", "dom", "enchant", "exif", "FFI", "fileinfo",
                                    "filter", "fpm", "ftp", "gd", "gettext", "gmp", "hash", "iconv",
                                    "imap", "intl", "json", "ldap", "libxml", "mbstring", "meta",
                                    "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO",
                                    "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql",
                                    "Phar", "posix", "pspell", "readline", "Reflection", "session",
                                    "shmop", "SimpleXML", "soap", "sockets", "sodium", "SPL",
                                    "sqlite3", "standard", "superglobals", "sysvmsg", "sysvsem",
                                    "sysvshm", "tidy", "tokenizer", "xml", "xmlreader", "xmlrpc",
                                    "xmlwriter", "xsl", "Zend OPcache", "zip", "zlib"
                                },
                            },
                        },
                    })
                end,
                ["html"] = function()
                    require("lspconfig").html.setup({
                        capabilities = capabilities,
                        filetypes = { "html", "blade" },
                    })
                end,
                ["cssls"] = function()
                    require("lspconfig").cssls.setup({
                        capabilities = capabilities,
                        filetypes = { "css", "scss", "less" },
                    })
                end,
                -- Changed to use ts_ls as the handler key to match lspconfig
                -- "javascript", "javascriptreact",
                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        filetypes = { "typescript",  "typescriptreact", "tsx" },
                        root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", ".git"),
                        settings = {
                            typescript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = "all",
                                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                    includeInlayFunctionParameterTypeHints = true,
                                    includeInlayVariableTypeHints = true,
                                    includeInlayPropertyDeclarationTypeHints = true,
                                    includeInlayFunctionLikeReturnTypeHints = true,
                                    includeInlayEnumMemberValueHints = true,
                                }
                            },
                            javascript = {
                                inlayHints = {
                                    includeInlayParameterNameHints = "all",
                                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                    includeInlayFunctionParameterTypeHints = true,
                                    includeInlayVariableTypeHints = true,
                                    includeInlayPropertyDeclarationTypeHints = true,
                                    includeInlayFunctionLikeReturnTypeHints = true,
                                    includeInlayEnumMemberValueHints = true,
                                }
                            }
                        }
                    })
                end,
                ["dockerls"] = function()
                    require("lspconfig").dockerls.setup({
                        capabilities = capabilities,
                        filetypes = { "dockerfile" },
                        root_dir = require("lspconfig").util.root_pattern("Dockerfile", ".git"),
                    })
                end,
                ["jsonls"] = function()
                    require("lspconfig").jsonls.setup({
                        capabilities = capabilities,
                        filetypes = { "json", "jsonc" },
                    })
                end,
                ["yamlls"] = function()
                    require("lspconfig").yamlls.setup({
                        capabilities = capabilities,
                        settings = {
                            yaml = {
                                schemas = {
                                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                                    ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*/action.y*ml",
                                    ["https://json.schemastore.org/docker-compose.json"] = "docker-compose.y*ml",
                                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.y*ml",
                                    ["https://json.schemastore.org/kustomization.json"] = "kustomization.y*ml",
                                    ["https://json.schemastore.org/helmfile.json"] = "helmfile.y*ml",
                                    ["https://json.schemastore.org/chart.json"] = "Chart.y*ml",
                                }
                            }
                        }
                    })
                end,
                ["zls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
                ["pyright"] = function()
                    require("lspconfig").pyright.setup({
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    typeCheckingMode = "basic",
                                    autoSearchPaths = true,
                                    useLibraryCodeForTypes = true,
                                }
                            }
                        }
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<C-e>'] = cmp.mapping.abort(),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        })
        vim.diagnostic.config({
            virtual_text = {
                enabled = true,
                source = "if_many",     -- Only show source if multiple sources
                spacing = 2,
                prefix = "■",
                format = function(diagnostic)
                    return string.format("%s (%s)", diagnostic.message, diagnostic.source)
                end,
            },
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
