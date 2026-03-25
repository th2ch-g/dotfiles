-- Enable Lua bytecode cache for faster subsequent startups (Neovim 0.9+)
vim.loader.enable()

local use_plugins = 1

if use_plugins == 1 then
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)

    local plugins = {
        -- colorschemes
        -- {
        --     "tomasiser/vim-code-dark",
        --     config = function()
        --         vim.cmd("colorscheme codedark")
        --     end
        -- },
        -- {
        --     "folke/tokyonight.nvim",
        --     lazy = false,
        --     priority = 1000,
        --     opts = {
        --         transparent = true,
        --         styles = {
        --             sidebars = "transparent",
        --             floats = "transparent",
        --         },
        --     },
        --     config = function()
        --         vim.cmd("colorscheme tokyonight")
        --     end
        -- },
        -- everforest
        -- {
        --     "sainnhe/everforest",
        --     config = function()
        --         vim.cmd("colorscheme everforest")
        --     end,
        -- },
        -- everforest nvim
        {
            "neanias/everforest-nvim",
            lazy = false,
            priority = 1000, -- load colorscheme before other plugins
            config = function()
                vim.cmd("colorscheme everforest")
            end,
        },
        -- iceberg
        -- {
        --     "cocopon/iceberg.vim",
        --     config = function()
        --         vim.cmd("colorscheme iceberg")
        --     end,
        -- },

        -- utils
        { "cohama/lexima.vim", event = "InsertEnter" },
        { "tomtom/tcomment_vim", event = "VeryLazy" },
        { "th2ch-g/my-vim-sonictemplate", event = "VeryLazy" },
        { "machakann/vim-sandwich", event = "VeryLazy" },
        { "airblade/vim-gitgutter", event = "BufWinEnter" },

        -- markdown utils
        -- {
        --     "previm/previm",
        --     config = function()
        --         vim.g.previm_open_cmd = 'open -a "Google Chrome"'
        --     end,
        -- },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            -- build = function()
            --     vim.fn["mkdp#util#install"]()
            -- end,
            config = function()
                vim.fn["mkdp#util#install"]()
            end,
            -- or :call mkdp#util#install()
        },
        {
            "mzlogin/vim-markdown-toc",
            -- event = { "BufReadPre *.md", "BufNewFile *.md" },
            ft = { "markdown" },
            config = function()
                vim.g.vmt_auto_update_on_save = 1
                -- vim.g.vmt_dont_insert_fence = 1
                vim.g.vmt_fence_text = "TOC"
                vim.g.vmt_fence_closing_text = "/TOC"
            end,
        },

        -- term utils
        -- {
        --     "akinsho/toggleterm.nvim",
        --     version = "*",
        --     config = function()
        --         vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], { silent = true })
        --     end,
        --     opts = {},
        -- },

        -- bufferline
        -- {
        --     "akinsho/bufferline.nvim",
        --     version = "*",
        --     config = function()
        --         vim.opt.termguicolors = true
        --         require("bufferline").setup({
        --             options = {
        --                 -- https://github.com/akinsho/bufferline.nvim/blob/655133c3b4c3e5e05ec549b9f8cc2894ac6f51b3/doc/bufferline.txt
        --                 show_buffer_icons = false,
        --                 modified_icon = "[+]",
        --                 close_icon = "x",
        --                 buffer_close_icon = "x",
        --                 left_trunc_marker = "<",
        --                 right_trunc_marker = ">",
        --             },
        --         })
        --     end,
        -- },

        -- lean4
        {
            "Julian/lean.nvim",
            -- event = { "BufReadPre *.lean", "BufNewFile *.lean" },
            ft = { "lean" },

            dependencies = {
                "neovim/nvim-lspconfig",
                "nvim-lua/plenary.nvim",

                -- optional dependencies:

                -- a completion engine
                --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices

                -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
                -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
                -- 'andrewradev/switch.vim',        -- for switch support
                -- 'tomtom/tcomment_vim',           -- for commenting
            },

            ---@type lean.Config
            opts = { -- see below for full configuration options
                mappings = true,
            },
        },

        -- terraform
        -- {
        --     "hashivim/vim-terraform",
        --     -- event = { "BufReadPre *.tf", "BufNewFile *.tf" },
        --     ft = { "terraform" },
        -- },

        -- rust
        {
            "rust-lang/rust.vim",
            -- event = { "BufReadPre *.rs", "BufNewFile *.rs" },
            ft = { "rust" },
        },

        -- quick jump
        -- { 'easymotion/vim-easymotion' }

        -- highlight
        {
            "levouh/tint.nvim",
            event = "BufWinEnter",
            config = function()
                require("tint").setup()
            end,
        },

        -- {
        --     "sphamba/smear-cursor.nvim",
        --     event = "VeryLazy",
        --     cond = vim.g.neovide == nil,
        --     opts = {
        --         hide_target_hack = true,
        --         cursor_color = "none",
        --     },
        --     specs = {
        --         -- disable mini.animate cursor
        --         {
        --             "nvim-mini/mini.animate",
        --             optional = true,
        --             opts = {
        --                 cursor = { enable = false },
        --             },
        --         },
        --     },
        -- },
    }

    local use_ai = vim.fn.getenv("VIM_AI") == "1"

    if use_ai then
        -- table.insert(plugins, {
        --     "ravitemer/mcphub.nvim",
        --     dependencies = {
        --         "nvim-lua/plenary.nvim",
        --     },
        --     build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
        --     config = function()
        --         require("mcphub").setup({
        --             use_bundled_binary = true, -- Use local `mcp-hub` binary
        --         })
        --     end,
        -- })
        table.insert(plugins, {
            "Exafunction/codeium.vim",
            event = "BufEnter",
            config = function()
                vim.g.codeium_disable_bindings = 1
                vim.keymap.set("i", "<C-f>", function()
                    return vim.fn["codeium#Accept"]()
                end, { silent = true, nowait = true, expr = true })
                vim.keymap.set("i", "<C-k>", function()
                    return vim.fn["codeium#AcceptNextWord"]()
                end, { silent = true, nowait = true, expr = true })
                vim.keymap.set("i", "<C-l>", function()
                    return vim.fn["codeium#AcceptNextLine"]()
                end, { silent = true, nowait = true, expr = true })
                vim.keymap.set(
                    "i",
                    "<C-]>",
                    "<Cmd>call codeium#CycleCompletions(1)<CR>",
                    { silent = true, nowait = true }
                )
                vim.keymap.set(
                    "i",
                    "<C-[>",
                    "<Cmd>call codeium#CycleCompletions(-1)<CR>",
                    { silent = true, nowait = true }
                )
                vim.keymap.set("i", "<C-d>", "<Cmd>call codeium#Clear()<CR>", { silent = true, nowait = true })
                vim.opt.statusline = vim.opt.statusline:get() .. " %3{codeium#GetStatusString()}"
            end,
        })
        -- table.insert(plugins, {
        --     "yetone/avante.nvim",
        --     event = "VeryLazy",
        --     version = false, -- Never set this value to "*"! Never!
        --     opts = {
        --         -- add any opts here
        --         -- for example
        --         -- provider = "gemini",
        --         -- provider = "ollama",
        --         provider = os.getenv("OLLAMA_HOST") and "ollama" or "gemini",
        --         mode = "agentic",
        --         providers = {
        --             openai = {
        --                 endpoint = "https://api.openai.com/v1",
        --                 model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        --                 extra_request_body = {
        --                     timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        --                     temperature = 0,
        --                     max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --                     --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        --                 },
        --             },
        --             gemini = {
        --                 -- https://ai.google.dev/gemini-api/docs/models?hl=ja#preview
        --                 -- model = "gemini-2.5-pro-preview-06-05",
        --                 -- model = "gemini-2.5-flash-preview-04-17",
        --                 -- model = "gemini-2.5-flash-preview-05-20",
        --                 -- model = "gemini-2.5-flash-lite-preview-06-17",
        --                 model = "gemini-2.5-pro",
        --                 temperature = 0,
        --                 max_tokens = 4096,
        --             },
        --             ollama = {
        --                 model = "gemma3:27b-it-qat",
        --                 -- mode = "phi4-reasoning:plus"
        --                 endpoint = vim.fn.getenv("OLLAMA_HOST"),
        --                 extra_request_body = {
        --                     options = {
        --                         temperature = 0,
        --                         -- num_ctx = 20480,
        --                     },
        --                 },
        --             },
        --         },
        --         -- cursor_applying_provider = "gemini",
        --         cursor_applying_provider = nil,
        --         behaviour = {
        --             enable_cursor_planning_mode = true,
        --             auto_set_highlight_group = true,
        --             auto_set_keymaps = true,
        --             auto_apply_diff_after_generation = false,
        --             support_paste_from_clipboard = false,
        --             minimize_diff = true,
        --             enable_token_counting = true,
        --         },
        --         hints = { enabled = true },
        --         windows = {
        --             ---@type "right" | "left" | "top" | "bottom"
        --             position = "right", -- the position of the sidebar
        --             wrap = true, -- similar to vim.o.wrap
        --             width = 30, -- default % based on available width
        --             sidebar_header = {
        --                 enabled = true, -- true, false to enable/disable the header
        --                 align = "center", -- left, center, right for title
        --                 rounded = true,
        --             },
        --             input = {
        --                 prefix = "> ",
        --                 height = 8, -- Height of the input window in vertical layout
        --             },
        --             edit = {
        --                 border = "rounded",
        --                 start_insert = true, -- Start insert mode when opening the edit window
        --             },
        --             ask = {
        --                 floating = false, -- Open the 'AvanteAsk' prompt in a floating window
        --                 start_insert = true, -- Start insert mode when opening the ask window
        --                 border = "rounded",
        --                 ---@type "ours" | "theirs"
        --                 focus_on_apply = "ours", -- which diff to focus after applying
        --             },
        --         },
        --         highlights = {
        --             ---@type AvanteConflictHighlights
        --             diff = {
        --                 current = "DiffText",
        --                 incoming = "DiffAdd",
        --             },
        --         },
        --         --- @class AvanteConflictUserConfig
        --         diff = {
        --             autojump = true,
        --             ---@type string | fun(): any
        --             list_opener = "copen",
        --             --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --             --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --             --- Disable by setting to -1.
        --             override_timeoutlen = 500,
        --         },
        --         suggestion = {
        --             debounce = 600,
        --             throttle = 600,
        --         },
        --     },
        --     -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        --     build = "make",
        --     -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        --     dependencies = {
        --         "nvim-treesitter/nvim-treesitter",
        --         "stevearc/dressing.nvim",
        --         "nvim-lua/plenary.nvim",
        --         "MunifTanjim/nui.nvim",
        --         -- --- The below dependencies are optional,
        --         -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
        --         -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        --         -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        --         -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
        --         -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        --         -- "zbirenbaum/copilot.lua", -- for providers='copilot'
        --         {
        --             -- support for image pasting
        --             "HakonHarnes/img-clip.nvim",
        --             event = "VeryLazy",
        --             opts = {
        --                 -- recommended settings
        --                 default = {
        --                     embed_image_as_base64 = false,
        --                     prompt_for_file_name = false,
        --                     drag_and_drop = {
        --                         insert_mode = true,
        --                     },
        --                     -- required for Windows users
        --                     use_absolute_path = true,
        --                 },
        --             },
        --         },
        --         {
        --             -- Make sure to set this up properly if you have lazy=true
        --             "MeanderingProgrammer/render-markdown.nvim",
        --             opts = {
        --                 file_types = { "markdown", "Avante" },
        --                 -- file_types = { "Avante" },
        --             },
        --             ft = { "Avante" },
        --         },
        --     },
        -- })
    end

    require("lazy").setup(plugins, {
        performance = {
            rtp = {
                -- Disable unused built-in plugins to reduce RTP scan overhead
                disabled_plugins = {
                    "gzip",
                    "matchit",
                    "tarPlugin",
                    "tohtml",
                    "tutor",
                    "zipPlugin",
                },
            },
        },
    })
else
    vim.cmd("colorscheme habamax")
end

-- Options via vim.opt API (faster than vim.cmd("set ...") as it bypasses Vimscript parser)
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.backspace = "indent,eol,start"
vim.opt.cindent = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamed"
vim.opt.display = "uhex"
vim.opt.encoding = "utf-8"
vim.opt.expandtab = true
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.fileencodings = { "utf-8", "cp932", "euc-jp", "iso-2022-jp" }
vim.opt.foldcolumn = "3"
vim.opt.foldlevel = 10
vim.opt.foldmethod = "manual"
vim.opt.formatoptions = "lmoq"
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.laststatus = 2
vim.opt.list = true
vim.opt.listchars = { tab = ">\\" }
vim.opt.matchpairs:append("<:>")
vim.opt.matchtime = 1
vim.opt.mouse = "a"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.title = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.ruler = true
vim.opt.scrolloff = 5
vim.opt.shiftwidth = 4
vim.opt.shortmess:remove("S")
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.showmode = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.statusline = "%<%f #%n%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%y%=%l,%c%V%8P"
vim.opt.tabstop = 4
vim.opt.textwidth = 0
vim.opt.virtualedit = "onemore"
vim.opt.visualbell = true
vim.opt.whichwrap = "b,s,h,s,<,>,[,]"
vim.opt.wildmenu = true
vim.opt.wildmode = "list:full"
vim.opt.wrapscan = true

vim.cmd("syntax on")

vim.g.netrw_dirhistmax = 0

vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>")
vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], { silent = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//ge",
})

vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Auto jump to last position",
    group = vim.api.nvim_create_augroup("auto-last-position", { clear = true }),
    callback = function(args)
        local position = vim.api.nvim_buf_get_mark(args.buf, [["]])
        local winid = vim.fn.bufwinid(args.buf)
        pcall(vim.api.nvim_win_set_cursor, winid, position)
    end,
})

vim.cmd("hi Normal        ctermbg=NONE guibg=NONE")
vim.cmd("hi SignColumn    ctermbg=NONE guibg=NONE")
vim.cmd("hi EndOfBuffer   ctermbg=NONE guibg=NONE")
vim.cmd("hi LineNr        ctermbg=NONE guibg=NONE")
vim.cmd("hi CursorLineNr  ctermbg=NONE guibg=NONE")
vim.cmd("hi NonText       ctermbg=NONE guibg=NONE")
vim.cmd("hi SpecialKey    ctermbg=NONE guibg=NONE")
vim.cmd("hi FoldColumn    ctermbg=NONE guibg=NONE")
vim.cmd("hi ColorColumn   ctermbg=NONE guibg=NONE")
vim.cmd("hi NormalNC      ctermbg=NONE guibg=NONE")
vim.cmd("hi NormalFloat   ctermbg=NONE guibg=NONE")
vim.cmd("hi Pmenu         ctermbg=NONE guibg=NONE")
