" Vim global plugin for autoloading cscope databases.
" Last Change: Mon Nov 20 03:41:35 CST 2017
" Original Author: Michael Conrad Tadpol Tilsra <tadpol@tadpol.org>
" Modifier: HsuehMin Chen <elsdrium@gmail.com>

if exists("loaded_autoload_cscope")
  finish
endif
let loaded_autoload_cscope = 1

" requirements, you must have these enabled or this is useless.
if(  !has('cscope') || !has('modify_fname') )
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" If you set this to anything other than 1, the menu and macros will not be
" loaded.  Useful if you have your own that you like.  Or don't want my stuff
" clashing with any macros you've made.
if !exists("g:autocscope_menus")
  let g:autocscope_menus = 1
endif

"==
" windowdir
"  Gets the directory for the file in the current window
"  Or the current working dir if there isn't one for the window.
"  Use tr to allow that other OS paths, too
function s:windowdir()
  if winbufnr(0) == -1
    let unislash = getcwd()
  else 
    let unislash = fnamemodify(bufname(winbufnr(0)), ':p:h')
  endif
  return tr(unislash, '\', '/')
endfunc
"
"==
" Find_in_parent
" find the file argument and returns the path to it.
" Starting with the current working dir, it walks up the parent folders
" until it finds the file, or it hits the stop dir.
" If it doesn't find it, it returns "Nothing"
function s:Find_in_parent(fln,flsrt,flstp)
  let here = a:flsrt
  while ( strlen( here) > 0 )
    if filereadable( here . "/" . a:fln )
      return here
    endif
    let fr = match(here, "/[^/]*$")
    if fr == -1
      break
    endif
    let here = strpart(here, 0, fr)
    if here == a:flstp
      break
    endif
  endwhile
  return "Nothing"
endfunc
"
"==
" Unload_csdb
"  drop cscope connections.
function s:Unload_csdb()
  if exists("b:csdbpath")
    if cscope_connection(3, "out", b:csdbpath)
      let save_csvb = &csverb
      set nocsverb
      exe "cs kill " . b:csdbpath
      set csverb
      let &csverb = save_csvb
    endif
  endif
endfunc
"
"==
" Cycle_csdb
"  cycle the loaded cscope db.
function s:Cycle_csdb()
  if exists("b:csdbpath")
    if cscope_connection(3, "out", b:csdbpath)
      return
      "it is already loaded. don't try to reload it.
    endif
  endif
  let newcsdbpath = s:Find_in_parent("cscope.out",s:windowdir(),$HOME)
  "    echo "Found cscope.out at: " . newcsdbpath
  "    echo "Windowdir: " . s:windowdir()
  if newcsdbpath != "Nothing"
    let b:csdbpath = newcsdbpath
    if !cscope_connection(3, "out", b:csdbpath)
      let save_csvb = &csverb
      set nocsverb
      exe "cs add " . b:csdbpath . "/cscope.out " . b:csdbpath
      set csverb
      let &csverb = save_csvb
    endif
    "
  else " No cscope database, undo things. (someone rm-ed it or somesuch)
    call s:Unload_csdb()
  endif
endfunc

" auto toggle the menu
augroup autoload_cscope
  au!
  au BufEnter * call <SID>Cycle_csdb()
  au BufUnload * call <SID>Unload_csdb()
augroup END

let &cpo = s:save_cpo

