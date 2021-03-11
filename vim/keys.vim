let mapleader=','
nnoremap <C-p> :ProjectFiles<CR>
tnoremap <Esc> <C-\><C-n>
nnoremap <leader>f :Rg<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
noremap j gj
noremap k gk
inoremap jk <esc>
nnoremap <leader><space> :nohlsearch<CR>
noremap <left> <nop>
noremap <right> <nop>
noremap <up> <nop>
noremap <down> <nop>
vnoremap < <gv
vnoremap > >gv
nnoremap Q <nop>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gvdiff<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gc :GCheckout<cr>
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>
nnoremap <leader>rr :so %<cr>

nnoremap <leader>p "+p<cr>
vnoremap <leader>p "+p<cr>
vnoremap <leader>y "+y<cr>
nnoremap <leader>pi :e $HOME/code/personal/dotfiles/init.vim<cr> :so %<cr>:PlugInstall<cr>
