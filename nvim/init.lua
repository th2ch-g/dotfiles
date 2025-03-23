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


require("lazy").setup({
    { 'tomasiser/vim-code-dark' },
    { 'cohama/lexima.vim' },
    { 'tomtom/tcomment_vim' },
    { 'th2ch-g/my-vim-sonictemplate' },
    { 'machakann/vim-sandwich' },
    { 'airblade/vim-gitgutter' },
    { 'Exafunction/codeium.vim',
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
    },
})

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
