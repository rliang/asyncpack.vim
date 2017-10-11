if exists('g:loaded_asyncpack') | finish | en
let g:loaded_asyncpack=1

fu! s:load_opts_recursive(paths)
  if len(a:paths)
    cal timer_start(0, {-> s:load_opts_recursive(a:paths[1:])})
    exe 'pa' a:paths[0]
    exe 'doautoa' 'User' 'asyncpack:'.a:paths[0]
  en
endf

fu! asyncpack#load_opts()
  let pp=map(globpath(&packpath, 'pack/*/opt/*', 1, 1), {_,p -> fnamemodify(p, ':t')})
  let in=get(g:, 'asyncpack#include', pp)
  let ex=get(g:, 'asyncpack#exclude', [])
  cal s:load_opts_recursive(filter(in, {_,p -> index(ex, p) < 0}))
endf

fu! asyncpack#load_rplugin()
  unl g:loaded_remote_plugins
  so $VIM/runtime/plugin/rplugin.vim
endf

if get(g:, 'asyncpack#rplugin', 1)
  let g:loaded_remote_plugins=''
  cal timer_start(0, {-> asyncpack#load_rplugin()})
en
cal timer_start(0, {-> asyncpack#load_opts()})
