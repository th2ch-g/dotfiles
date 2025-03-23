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

vim.cmd("set autoread")
vim.cmd("set hidden")
vim.cmd("set noswapfile")
vim.cmd("set nobackup")
vim.cmd("syntax enable")
vim.cmd("set tabstop=4 shiftwidth=4 softtabstop=0")
vim.cmd("set autoindent")
vim.cmd("set smartindent")
vim.cmd("set cindent")
vim.cmd("set noexpandtab")
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set formatoptions=lmoq")
vim.cmd("set whichwrap=b,s,h,s,<,>,[,]")
vim.cmd("set wildmenu")
vim.cmd("set wildmode=list:full")
vim.cmd("set wrapscan")
vim.cmd("set ignorecase")
vim.cmd("set smartcase")
vim.cmd("set incsearch")
vim.cmd("set hlsearch")
vim.cmd("set showmatch")
vim.cmd("set showcmd")
vim.cmd("set showmode")
vim.cmd("set number")
vim.cmd("set nowrap")
vim.cmd("set list")
vim.cmd("set notitle")
vim.cmd("set scrolloff=5")
vim.cmd("set display=uhex")
vim.cmd("set listchars=tab:>\\")
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = '%s/\\s\\+$//ge',
})
vim.cmd("set cursorline")
vim.cmd("set laststatus=2")
vim.cmd("set tw=0")
vim.cmd("set number")
vim.cmd("set title")
vim.cmd("set showmatch")
vim.cmd("set matchtime=1")
vim.cmd("set matchpairs& matchpairs+=<:>")
vim.cmd("set list")
vim.cmd("set visualbell")
vim.cmd("set laststatus=2")
vim.cmd("set ruler")
vim.cmd("set clipboard=unnamed")
vim.cmd("syntax on")
vim.cmd("set fenc=utf-8")
vim.cmd("set virtualedit=onemore")
vim.cmd("set autoindent")
vim.cmd("set smartindent")
vim.cmd("set expandtab")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set whichwrap=b,s,h,l,<,>,[,],~")
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set ignorecase")
vim.cmd("set smartcase")
vim.cmd("set wrapscan")
vim.cmd("set hlsearch")
vim.cmd("set incsearch")
vim.cmd("nmap <Esc><Esc> :nohlsearch<CR><Esc>")
vim.cmd("set mouse=a")
vim.cmd("set foldmethod=indent")
vim.cmd("set foldlevel=10")
vim.cmd("set foldcolumn=3")
vim.cmd("set shortmess-=S")
vim.cmd("let g:netrw_dirhistmax = 0")
vim.cmd("set laststatus=2")
vim.cmd("set statusline=%<%f\\ #%n%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%y%=%l,%c%V%8P")
vim.cmd("set termencoding=utf-8")
vim.cmd("set encoding=utf-8")
vim.cmd("set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp")
vim.cmd("set ffs=unix,dos,mac")

local plugins = {
    { 'tomasiser/vim-code-dark' },
    { 'cohama/lexima.vim' },
    { 'tomtom/tcomment_vim' },
    { 'th2ch-g/my-vim-sonictemplate' },
    { 'machakann/vim-sandwich' },
    { 'airblade/vim-gitgutter' },
}

local use_ai = vim.fn.getenv("VIM_AI") == "1"

if use_ai then
    table.insert(plugins, {
        'Exafunction/codeium.vim',
        event = 'BufEnter',
        config = function()
            vim.g.codeium_disable_bindings = 1
            vim.keymap.set('i', '<C-f>', function() return vim.fn['codeium#Accept']() end, { silent = true, nowait = true, expr = true })
            vim.keymap.set('i', '<C-k>', function() return vim.fn['codeium#AcceptNextWord']() end, { silent = true, nowait = true, expr = true })
            vim.keymap.set('i', '<C-l>', function() return vim.fn['codeium#AcceptNextLine']() end, { silent = true, nowait = true, expr = true })
            vim.keymap.set('i', '<C-]>', '<Cmd>call codeium#CycleCompletions(1)<CR>', { silent = true, nowait = true })
            vim.keymap.set('i', '<C-[>', '<Cmd>call codeium#CycleCompletions(-1)<CR>', { silent = true, nowait = true })
            vim.keymap.set('i', '<C-d>', '<Cmd>call codeium#Clear()<CR>', { silent = true, nowait = true })
            vim.opt.statusline = vim.opt.statusline:get() .. " %3{codeium#GetStatusString()}"
        end
    })
    table.insert(plugins, {
      "yetone/avante.nvim",
      event = "VeryLazy",
      version = false, -- Never set this value to "*"! Never!
      opts = {
        -- add any opts here
        -- for example
        provider = "gemini",
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
          timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
          temperature = 0,
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        },
        gemini = {
            model = "gemini-2.0-flash",
            -- model = "gemini-2.0-pro-exp-02-05",
            temperature = 0,
            max_tokens = 4096,
        }
      },
      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      build = "make",
      -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        -- --- The below dependencies are optional,
        -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
        -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
        -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        -- "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            -- recommended settings
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              -- required for Windows users
              use_absolute_path = true,
            },
          },
        },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    })
end

require("lazy").setup(plugins)

vim.cmd("colorscheme codedark")

vim.cmd("hi Normal        ctermbg=NONE guibg=NONE")
vim.cmd("hi SignColumn    ctermbg=NONE guibg=NONE")
vim.cmd("hi EndOfBuffer   ctermbg=NONE guibg=NONE")
vim.cmd("hi LineNr        ctermbg=NONE guibg=NONE")
vim.cmd("hi CursorLineNr  ctermbg=NONE guibg=NONE")
vim.cmd("hi NonText       ctermbg=NONE guibg=NONE")
vim.cmd("hi SpecialKey    ctermbg=NONE guibg=NONE")
vim.cmd("hi FoldColumn    ctermbg=NONE guibg=NONE")
vim.cmd("hi ColorColumn   ctermbg=NONE guibg=NONE")
