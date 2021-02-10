call plug#begin()
Plug 'Yggdroot/indentLine'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mattn/emmet-vim'
Plug 'sunaku/vim-shortcut'
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
Plug 'arcticicestudio/nord-vim'
Plug 'neomake/neomake'
Plug 'rhysd/vim-grammarous'
Plug 'posva/vim-vue'
Plug 'powerman/vim-plugin-ruscmd'
Plug 'Shougo/neco-vim'
Plug 'neoclide/coc-neco'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

" TODO
set shell=/bin/sh

" Use deoplete.
" let g:deoplete#enable_at_startup = 1
" deoplete tab-complete
" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" ===========
" Look'n'feel
" ===========

" To show markers always.
set signcolumn=yes

" Colors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
colorscheme nord
let g:nord_uniform_diff_background = 1

" Show invisibles
set listchars=tab:→\ ,trail:·
set list

set hidden

" Hybrid line numbers in normal and visual modes
set number relativenumber

let mapleader=" "

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Wider statusbar
set cmdheight=2

" Always show signcolumns
set signcolumn=yes

" ==========
" Coc config
" ==========

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
" And make CursorHold trigger a bit faster
set updatetime=500

" ==============
" Airline config
" ==============
let g:airline_symbols = {}
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
" Tabline
let g:airline#extensions#tabline#enabled = 1

" Some stuff
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set number
set mouse=a
set clipboard=unnamedplus
au FocusLost * silent! wa


" =========
" Shortcuts
" =========

" Show shortcuts on partial entry
noremap <silent> <Leader> :Shortcuts<Return>

" File-related shortcuts
nnoremap <Leader>ff :FZF<CR>
nnoremap <Leader>fr :Rg<CR>
nnoremap <Leader>ft :NERDTreeToggle<CR>

" Escape terminal.
tnoremap <expr> <esc> &filetype == 'fzf' ? "\<esc>" : "\<c-\>\<c-n>"

" Buffer and window related shortcuts
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprevious<CR>
nnoremap <Leader>bb :Buffers<CR>
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>ba :bufdo bd!<CR>
nnoremap <Leader>bw :w<CR>
nnoremap <Leader>wd <C-w>q

"move to the split in the direction shown, or create a new split
nnoremap <silent> <C-h> :call WinMove('h')<cr>
nnoremap <silent> <C-j> :call WinMove('j')<cr>
nnoremap <silent> <C-k> :call WinMove('k')<cr>
nnoremap <silent> <C-l> :call WinMove('l')<cr>

function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr())
    if (match(a:key,'[jk]'))
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

" LSP shortcuts
vmap <leader>lf  <Plug>(coc-format-selected)
nmap <leader>lf  <Plug>(coc-format)
nmap <leader>lr  <Plug>(coc-rename)

nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gt <Plug>(coc-type-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)

nmap <leader>d[ <Plug>(coc-diagnostic-prev)
nmap <leader>d] <Plug>(coc-diagnostic-next)
nnoremap <silent><leader>dd  :<C-u>CocList diagnostics<cr>
nmap <leader>df  <Plug>(coc-fix-current)

nmap <leader>ac  <Plug>(coc-codeaction)

" FZF with .gitignore
let $FZF_DEFAULT_COMMAND = 'rg --files'

