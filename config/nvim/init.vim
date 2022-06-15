call plug#begin('~/.local/share/nvim/plugged')    
Plug 'sainnhe/sonokai'
Plug 'gruvbox-community/gruvbox'
Plug 'kyazdani42/blue-moon'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'                    
Plug 'vim-python/python-syntax'
Plug 'neoclide/coc.nvim', {'branch': 'release'} "Completion
Plug 'HerringtonDarkholme/yats.vim' "Syntax for typescript
Plug 'scrooloose/nerdtree' "File nav              
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim' "Search with ctrlp      
Plug 'preservim/nerdcommenter'
Plug 'vim-syntastic/syntastic'                    
Plug 'pangloss/vim-javascript'
Plug 'bfrg/vim-cpp-modern'                        
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' } "Go support                                      
Plug 'frazrepo/vim-rainbow'
Plug 'github/copilot.vim'
Plug 'ryanoasis/vim-devicons'                     
Plug 'alvan/vim-closetag'
call plug#end()
" Theme
 colorscheme gruvbox
"colorscheme palenight
set background=dark
"set termguicolors
"colorscheme blue-moon

"remap for saving and quiting
let mapleader=" "                                 
nmap <Leader>x :x<CR>
nmap <Leader>w :w<CR>                             
nmap <Leader>q :q<CR>
nmap <Leader>qf :q!<CR>

" go before vim
nmap <Leader>b :b#<CR>

"Nerdtree key maps
nmap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>u :UndotreeShow<CR>
let NERDTreeShowHidden=1

"Nerd commenter
"nmap <C-_>   <Plug>NERDCommenterToggle
"vmap <C-_>   <Plug>NERDCommenterToggle<CR>gv
nmap <Leader>/ <Plug>NERDCommenterToggle
vmap <Leader>/ <Plug>NERDCommenterToggle<CR>gv

"Ctrlp ignore files
let g:ctrlp_user_command = ['.git/',  'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

"" Syntax highlighting
syntax on
let g:python_highlight_all = 1
" go syntax
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1


let g:rainbow_active = 1

" Position in code
nmap <Leader>nr :set rnu!<CR>
"nmap <Leader>rl :set relativenumber<CR>
"nmap <Leader>n :set nonumber<CR>
set number
set ruler

" Don't make noise
set visualbell

" default file encoding
set encoding=utf-8


set clipboard=unnamedplus

" Function to set tab width to n spaces
set tabstop=2 softtabstop=2
set shiftwidth=2
function! SetTab(n)
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
endfunction

command! -nargs=1 SetTab call SetTab(<f-args>)

set laststatus=2

" Highlight search results
set nohlsearch

" auto + smart indent for code
set autoindent
set smartindent

set t_Co=256

" Mouse support
set mouse=a

" disable backup files
set nobackup
set noswapfile
set nowritebackup

" no delays!
set updatetime=300

set cmdheight=1
set shortmess+=c

set scrolloff=10
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
"inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentatio in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)


" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" add cocstatus into lightline
let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component_function': {
        \   'cocstatus': 'coc#status'
        \ },
        \ }

"" enable copilot for all filetypes
let g:copilot_filetypes = {
          \ '*': v:true,
          \ }

autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

let NERDTreeShowHidden=1

" closetag
" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*jsx,*tsx,*js,*ts'

let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,xhtml,phtml,jsx,tsx,js,ts'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'

" Autoclose brackets
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
