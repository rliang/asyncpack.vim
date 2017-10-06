if exists('g:loaded_asyncpack') | finish | en
let g:loaded_asyncpack=1

" execution queue
let s:queue=[]

" lazy-load filetypes if no initial files were given
if get(g:, 'asyncpack#filetypes', 1) && !argc()
  let g:did_load_filetypes=1
  cal add(s:queue, 'unl g:did_load_filetypes | ru filetype.vim')
en

" lazy-load remote plugin hosts
if get(g:, 'asyncpack#rplugin', 1)
  let g:loaded_remote_plugins=1
  cal add(s:queue, 'unl g:loaded_remote_plugins | ru plugin/rplugin.vim')
en

" lazy-load plugins
fu! s:do_plugins()
  let ins=get(g:, 'asyncpack#include', map(globpath(&packpath, 'pack/*/opt/*', 1, 1), {_,p -> fnamemodify(p, ':t')}))
  let exs=get(g:, 'asyncpack#exclude', ['asyncpack.vim', 'justify', 'shellmenu', 'swapmouse', 'vimball'])
  let all=filter(ins, {_,p -> index(exs, p) < 0})
  cal extend(s:queue, map(all, {_,p -> 'pa '.p.' | sil do User asyncpack:'.p}))
endf
cal add(s:queue, 'cal s:do_plugins()')

" timer-based scheduler
fu! s:do_tick(_)
  if len(s:queue)
    exe remove(s:queue, 0)
  else
    cal timer_stop(s:timer)
    do User asyncpack
  en
endf
let s:timer=timer_start(1, function('s:do_tick'), {'repeat': -1})
