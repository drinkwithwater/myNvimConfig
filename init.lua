
require("packer").startup(function(use, use_rocks)
	use "wbthomason/packer.nvim"
	use "yegappan/mru"
	use_rocks "lpeg"
	-- tree
	use {
		'kyazdani42/nvim-tree.lua',
		requires = 'kyazdani42/nvim-web-devicons'
	}
	use { 'nvim-treesitter/nvim-treesitter' }
	-- lsp
	use {
		'neovim/nvim-lspconfig',
		'williamboman/nvim-lsp-installer'
	}
	use "~/.config/nvim/vim"
	use "~/.config/nvim/nerdtree"
end)

local function on_attach(client, bufnr)
 vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
		-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
 -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
 vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
 vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
 vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)

	-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	-- vim.keymap.set('n', '<space>wl', function()
		-- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	-- end, bufopts)
	-- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	-- vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	-- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	-- vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end



vim.lsp.set_log_level("INFO")
--require ('lspconfig').lua_lsp.setup {}
require ('lspconfig').thlua_lsp.setup {on_attach=on_attach}
--require ('lspconfig').sumneko_lua.setup {on_attach=on_attach}

require ('nerdtree-diagnostics').setup()

vim.keymap.set('n', '<C-j>', function()
	vim.diagnostic.goto_next()
end, bufopts)
vim.keymap.set('n', '<C-k>', function()
	vim.diagnostic.goto_prev()
end, bufopts)

vim.api.nvim_set_keymap('n', '<C-h>', ':tabp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':tabn<CR>', { noremap = true, silent = true })


vim.api.nvim_exec([[
"set expandtab smartindent
au BufNewFile,BufRead *.zig set expandtab smartindent
set shiftwidth=4 tabstop=4 softtabstop=4 smarttab
au BufNewFile,BufRead *.thlua setlocal syntax=thlua
au BufNewFile,BufRead *.thlua set filetype=thlua
au BufNewFile,BufRead *.thlua set shiftwidth=2 tabstop=2 softtabstop=2 smarttab
au BufNewFile,BufRead *.lua set shiftwidth=2 tabstop=2 softtabstop=2 smarttab
set number
set showtabline=2
set signcolumn=yes
colorscheme slate
nnoremap ; :

hi MatchParen ctermfg=11 ctermbg=20 cterm=NONE

" mru & undo config
set undofile
set undodir=~/.nvimtmp/undo
let g:MRU_File=expand("~")."/.nvimtmp/MRU_FILES"

" set cursor in last open position
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif


" delete trailing whitespace
func DeleteTrailingWhiteSpace()
    normal mZ
    %s/\s\+$//e
    normal `Z
endfunc
au BufWrite * if &ft != 'mkd' | call DeleteTrailingWhiteSpace() | endif

map <c-d> :NERDTreeToggle<CR>


" NERDTree
map <c-d> :NERDTreeToggle<CR>
command Nerd NERDTreeToggle
autocmd VimEnter * NERDTree
autocmd BufWinEnter * call AutoNERDTreeMirror()
autocmd VimEnter * wincmd w
autocmd TabLeave * call AutoWinW()
autocmd TabNewEntered * call AutoWinW()
let g:NERDTreeWinSize = 20
autocmd BufEnter * call AutoCloseNERDTree1()
autocmd QuitPre * call AutoCloseNERDTree1more()
function! AutoCloseNERDTree1()
	if @% == "NERD_tree_1" && tabpagenr("$") == 1 && winnr("$") == 1
		exec ":q"
	endif
endfunction
function! AutoCloseNERDTree1more()
	if @% == "NERD_tree_1"
		if tabpagenr("$") > 1
			tabclose
		endif
		"echo tabpagewinnr(tabpagenr(), '$')
	elseif len(tabpagebuflist(tabpagenr())) == 2
		for bufNum in tabpagebuflist(tabpagenr())
			if bufname(bufNum) == "NERD_tree_1"
				if tabpagenr("$") > 1
					tabclose
				endif
			endif
		endfor
	endif
endfunction
function! AutoWinW()
	if @% == "NERD_tree_1"
		wincmd w
	endif
endfunction
function! AutoNERDTreeMirror()
	if &modifiable
		NERDTreeMirror
	endif
endfunction

nnoremap zz zR

set scrolloff=10
set cursorline
set cursorcolumn


]] , true)


