" Run, vim -c "PlugInstall" -c "qa"
set autoread
set hidden
set noswapfile
set nobackup
autocmd BufWritePre * :%s/\s\+$//ge
syntax enable
set tabstop=4 shiftwidth=4 softtabstop=0
set autoindent
set smartindent
set cindent
set noexpandtab
set backspace=indent,eol,start
set formatoptions=lmoq
set whichwrap=b,s,h,s,<,>,[,]
set wildmenu
set wildmode=list:full
set wrapscan
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch
set showcmd
set showmode
set number
set nowrap
set list
set listchars=tab:>\
set notitle
set scrolloff=5
set display=uhex
colorscheme elflord

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

set cursorline
augroup cch
        autocmd! cch
        autocmd WinLeave * set nocursorline
        autocmd WinEnter,BufRead * set cursorline
augroup END
hi clear CursorLine
hi CursorLine gui=underline
hi CursorLine ctermbg=black guibg=black

set laststatus=2
set statusline=%<%f\ #%n%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%y%=%l,%c%V%8P

set termencoding=utf-8
set encoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp
set ffs=unix,dos,mac
if exists('&ambiwidth')
        set ambiwidth=double
endif


set tw=0
set number
set title
set showmatch
set matchtime=1
set matchpairs& matchpairs+=<:>
set list
set visualbell
set laststatus=2
set ruler
set clipboard=unnamed
syntax on
set fenc=utf-8
set virtualedit=onemore
set autoindent
set smartindent
set expandtab
set softtabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,[,],~
set backspace=indent,eol,start
set ignorecase
set smartcase
set wrapscan
set hlsearch
set incsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
set mouse=a
set ttymouse=xterm2
set foldmethod=indent
set foldlevel=10
set foldcolumn=3
set shortmess-=S
let g:netrw_dirhistmax = 0


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

" # tab
" :set expandtab
" :set noexpandtab
" # paste
" :set paste
" :set nopaste

call plug#begin()
Plug 'tomasiser/vim-code-dark'
Plug 'cohama/lexima.vim'
Plug 'tomtom/tcomment_vim'
Plug 'th2ch-g/my-vim-sonictemplate'
Plug 'machakann/vim-sandwich'
Plug 'airblade/vim-gitgutter'
" Plug 'github/copilot.vim'
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
call plug#end()

" see https://github.com/Exafunction/codeium.vim
let g:codeium_disable_bindings = 1
imap <script><silent><nowait><expr> <C-f> codeium#Accept()
imap <script><silent><nowait><expr> <C-k> codeium#AcceptNextWord()
imap <script><silent><nowait><expr> <C-l> codeium#AcceptNextLine()
imap <C-]>   <Cmd>call codeium#CycleCompletions(1)<CR>
imap <C-[>   <Cmd>call codeium#CycleCompletions(-1)<CR>
imap <C-d>   <Cmd>call codeium#Clear()<CR>

set statusline+=%3{codeium#GetStatusString()}

colorscheme codedark
