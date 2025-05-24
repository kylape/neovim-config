" Settings for vim-gh-line
let g:gh_open_command = 'fn() { echo "$@" | xclip -selection clipboard }; fn '
let g:gh_gitlab_domain = "gitlab.cee.redhat.com"
let g:gh_use_canonical = 1


" Indent options
set autoindent ts=4 sw=4 expandtab 
colorscheme dracula

" Search options
set hlsearch incsearch ignorecase smartcase 

" Display options
set ruler showcmd modeline 
set modelines=1
set laststatus=2
set mouse=nv

set nocompatible
set nu
syntax enable

" Make the unnamed register be interchangeable with the system clipboard 
set clipboard=unnamed

filetype plugin on
cabbr <expr> %% expand('%:p:h')

" I want to be able to use backspace to remove an auto-indent
set backspace=indent,start

" Set bash-style completion
set wildmode=longest,list

set diffopt+=vertical

" Edit and source my .vimrc quickly
nnoremap <leader>ev :split $MYVIMRC<cr><c-w>r
nnoremap <leader>sv :source $MYVIMRC<cr>

" Quickly enable textwidth
nnoremap <leader>tw :set tw=80<cr>

" Quickly format XML. Seems to be picky; can we improve?
vnoremap <leader>xf :!xmllint --format -<cr>
"We should make this mapping filetype-specific
nnoremap <leader>xf :silent %!xmllint --format --recover - 2>/dev/null<cr>

nnoremap <leader>% :let @f = bufname("%")<cr>

" Makes K do the opposite of J
nmap K i<cr><esc>k$

au FileType java nnoremap dm ddd%
au BufReadPost Jenkinsfile set filetype=groovy
au BufReadPost *.jenkinsfile set filetype=groovy
au FileType text set linebreak 
au FileType asciidoc set linebreak 

" Quickly insert blank lines and spaces
nnoremap <Backspace> O<Esc>
nnoremap <CR> o<Esc>

nnoremap <Leader>a :Ag <cword><cr>
nnoremap <c-j>     :cnext<cr> zz
nnoremap <c-k>     :cprev<cr> zz
nnoremap go        :.cc<cr>
nnoremap <c-h>     :bp<cr>
nnoremap <c-l>     :bn<cr>
vnoremap <leader>y :w !pc<cr><cr>

nnoremap <Leader>r :redraw!<cr>

nnoremap <c-p> :Telescope find_files<CR>

iabbrev steram stream
iabbrev shoudl should
iabbrev waht what
iabbrev tehn then
iabbrev teh the
iabbrev hadnler handler
iabbrev jbeap JBoss Enterprise Application Platform (EAP)

set signcolumn=yes

autocmd BufWritePre *.go lua vim.lsp.buf.format()
autocmd BufWritePre *.tfvars lua vim.lsp.buf.format()
autocmd BufWritePre *.tf lua vim.lsp.buf.format()

set completeopt+=longest,noselect,menuone,menu

" Create a new todo item
autocmd FileType text nnoremap <buffer> <leader>n o<esc>I  (D)            =strftime("%Y-%m-%d") 

" Make an item as complete
autocmd FileType text nnoremap <buffer> <leader>c 0rxEllR=strftime("%Y-%m-%d")

let g:vim_markdown_folding_disabled = 1
