" Vim global plugin for very minimal directory browsing
" Licence:     The MIT License (MIT)
" Commit:      $Format:%H$
" {{{ Copyright (c) 2015 Aristotle Pagaltzis <pagaltzis@gmx.de>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

if v:version < 700
    echoerr printf(
                \ 'Vim 7 is required for readdir (this is only %d.%d)',
                \ v:version / 100,
                \ v:version % 100,
                \ )
    finish
endif

if exists('b:readdir') || !isdirectory(expand('%')) | finish | endif

let t:id = range(1,bufnr('$'))
let t:taken = map(copy(t:id),'getbufvar(v:val, ''readdir_id'')')
let b:readdir = {
            \ 'id': filter(t:id,'index(t:taken, v:val) < 0')[0],
            \ 'hidden': get(g:, 'readdir_hidden', 0)
            \ }

setlocal buftype=nofile noswapfile undolevels=-1 nomodifiable nowrap
call readdir#Show(simplify(expand('%:p') . '.'), '')

nnoremap <buffer> <silent> <CR> :call readdir#Open(readdir#Selected())<CR>
nnoremap <buffer> <silent> <Space> :call readdir#Expand()<CR>
nnoremap <buffer> <silent> c    :call readdir#SetCWD(b:readdir.cwd)<CR>
nnoremap <buffer> <silent> -    :call readdir#Open(b:readdir.content[0])<CR>
nnoremap <buffer> <silent> a    :call readdir#CycleHidden()<CR>

" vim:foldmethod=marker
