if exists('g:loaded_asyncpack') | finish | en
let g:loaded_asyncpack=1

" execution queue
let s:queue = []

" optimization level
let s:optlv = get(g:, 'asyncpack#optimize', 2)

" adds to the queue commands to source vim runtime files
fu! s:do_runtime()
  let &rtp = s:rtp
  let srcs = globpath(&rtp, '{filetype,ftplugin,indent,syntax/syntax}.vim', 0, 1)
  " sourcing commands
  let cmds = map(srcs, {k,v -> 'source '.v})
  " finish
  let cmds += ['silent do User asyncpack:runtime']
  " enqueue
  let s:queue = cmds + s:queue
endf
" defer loading runtime
if s:optlv >= 2
  let s:rtp = &rtp
  let &rtp = ''
  let s:queue += ['cal s:do_runtime()']
en

" adds to the queue commands to source plugin files and start packages
fu! s:do_plugins()
  let srcs = globpath(&rtp, 'plugin/**/*.vim', 0, 1)
  " sourcing commands
  let cmds = map(srcs, {k,v -> 'source '.v})
  " start packages
  let cmds += ['packloadall']
  " finish
  let cmds += ['silent do User asyncpack:plugins']
  " enqueue
  let s:queue = cmds + s:queue
endf
" defer loading plugins
if s:optlv >= 1
  set noloadplugins
  let s:queue += ['cal s:do_plugins()']
en

" adds to the queue commands to source opt packages
fu! s:do_opt_packages()
  let Maptail = {list -> map(list, {k,v -> fnamemodify(v, ':t')})}
  let incl = get(g:, 'asyncpack#include', Maptail(globpath(&pp, 'pack/*/opt/*', 0, 1)))
  let excl = get(g:, 'asyncpack#exclude', Maptail(globpath($VIM, 'runtime/pack/*/opt/*', 0, 1)))
  let srcs = filter(incl, {k,v -> index(excl, v) < 0})
  " sourcing commands
  let cmds = map(incl, {k,v -> 'packadd '.v.' | silent do User asyncpack:opts:'.v})
  " re-apply filetypes
  let cmds += ['silent doautoall BufRead']
  " finish
  let cmds += ['silent do User asyncpack:opts']
  " enqueue
  let s:queue = cmds + s:queue
endf
" defer loading opt packages
let s:queue += ['cal s:do_opt_packages()']

" timer-based scheduling
cal timer_start(1, {t -> len(s:queue) ? execute(remove(s:queue, 0)) : timer_stop(t)}, {'repeat': -1})
