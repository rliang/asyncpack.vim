if exists('g:loaded_asyncpack') | finish | en
let g:loaded_asyncpack=1

let s:queue=[]

func! s:remove(timer)
  if len(s:queue)
    let src=remove(s:queue, 0)
    exe 'so' src
    sil exe 'do' 'User' 'asyncpack:'.src
  else
    cal timer_stop(a:timer)
    doautoall BufRead
    sil exe 'do' 'User' 'asyncpack'
  end
endf

aug asyncpack
  au!
  au SourceCmd * cal add(s:queue, expand('<afile>'))
  au VimEnter * cal timer_start(0, function('s:remove'), {'repeat': -1}) | au! asyncpack
aug END
