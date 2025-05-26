" Run: vim -e -c "PlugInstall" -c "qa"
set autoindent
set autoread
set backspace=indent,eol,start
set belloff=all
set cindent
set clipboard=unnamed
set cursorline
set display=uhex
set encoding=utf-8
set expandtab
set fenc=utf-8
set ffs=unix,dos,mac
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp
set foldcolumn=3
set foldlevel=10
set foldmethod=indent
set formatoptions=lmoq
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:>\
set matchpairs& matchpairs+=<:>
set matchtime=1
set mouse=a
set nobackup
set noerrorbells
set noswapfile
set notitle
set novisualbell
set nowrap
set number
set ruler
set scrolloff=5
set shiftwidth=4
set shortmess-=S
set showcmd
set showmatch
set showmode
set smartcase
set smartindent
set softtabstop=4
set statusline=%<%f\ #%n%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%y%=%l,%c%V%8P
set t_vb=
set tabstop=4
set termencoding=utf-8
set title
set ttymouse=sgr
set tw=0
set virtualedit=onemore
set visualbell
set whichwrap=b,s,h,s,<,>,[,]
set wildmenu
set wildmode=list:full
set wrapscan
" set ttymouse=xterm2

syntax enable
syntax on

nmap <Esc><Esc> :nohlsearch<CR><Esc>

let g:netrw_dirhistmax = 0

autocmd BufWritePre * :%s/\s\+$//ge

augroup vimrcEx
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line('$') |
    \   exe "normal! g`\"" |
    \ endif
augroup END

if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  unlet s:enc_euc
  unlet s:enc_jis
endif

if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif

function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif

augroup cch
    autocmd! cch
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
augroup END

if exists('&ambiwidth')
    set ambiwidth=double
endif


" # tab
" :set expandtab
" :set noexpandtab
" # paste
" :set paste
" :set nopaste

call plug#begin()
Plug 'tomasiser/vim-code-dark'
Plug 'sainnhe/everforest'
Plug 'cohama/lexima.vim'
Plug 'tomtom/tcomment_vim'
Plug 'th2ch-g/my-vim-sonictemplate'
Plug 'machakann/vim-sandwich'
Plug 'airblade/vim-gitgutter'
" if exists("$VIM_AI") && $VIM_AI == "1"
"     Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
" endif
call plug#end()

" see https://github.com/Exafunction/codeium.vim
" if exists("$VIM_AI") && $VIM_AI == "1"
"     let g:codeium_disable_bindings = 1
"     imap <script><silent><nowait><expr> <C-f> codeium#Accept()
"     imap <script><silent><nowait><expr> <C-k> codeium#AcceptNextWord()
"     imap <script><silent><nowait><expr> <C-l> codeium#AcceptNextLine()
"     imap <C-]>   <Cmd>call codeium#CycleCompletions(1)<CR>
"     imap <C-[>   <Cmd>call codeium#CycleCompletions(-1)<CR>
"     imap <C-d>   <Cmd>call codeium#Clear()<CR>
"     set statusline+=%3{codeium#GetStatusString()}
" endif

colorscheme codedark
" colorscheme everforest
" let g:everforest_transparent_background = 1

" TransParent settings
hi Normal        ctermbg=NONE guibg=NONE
hi SignColumn    ctermbg=NONE guibg=NONE
hi EndOfBuffer   ctermbg=NONE guibg=NONE
hi LineNr        ctermbg=NONE guibg=NONE
hi CursorLineNr  ctermbg=NONE guibg=NONE
hi NonText       ctermbg=NONE guibg=NONE
hi SpecialKey    ctermbg=NONE guibg=NONE
hi FoldColumn    ctermbg=NONE guibg=NONE
hi ColorColumn   ctermbg=NONE guibg=NONE
