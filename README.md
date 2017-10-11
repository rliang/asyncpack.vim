# asyncpack.vim
Loads opt vim8/neovim plugins in a way that minimizes UI blocking.

It's not a plugin manager, instead it relies on vim8/neovim's `packpath`
management. It might not be so useful if you already use another plugin
manager.

## How it works
Currently, there is no built-in way to load plugins in the background, so here
`timer_start` is used to schedule `packadd` calls to the next tick in the event
loop in order to improve responsiveness. This is similar to using
`requestAnimationFrame` in Javascript to perform asynchronous operations.

Since `packadd` is blocking by design, it is still possible for a single plugin
to take enough time to load as to block the next tick in the event loop.
Nevertheless, we can drastically improve the time to the first screen update:

* eager loading: `301.981`ms
* autocmd-based lazy loading: `271.143`ms (python remote host startup takes up
  most time)
* asyncpack.vim: `060.798`ms

## Installation
Clone the repo as an opt plugin:
```sh
git clone --depth=1 https://github.com/rliang/asyncpack.vim ~/.config/nvim/pack/foo/opt/asyncpack.vim`
```

Add to `.vimrc` or `init.vim`:
```vim
packadd! asyncpack.vim
```
to ensure it is loaded before other plugins.

## Variables
* `g:asyncpack#include` (List): When defined, load asynchronously only these
  plugins. Default undefined.
* `g:asyncpack#exclude` (List): Do not load asynchronously these plugins. Use
  if you want to call `packadd` yourself. Default empty list.
* `g:asyncpack#rplugin` (Boolean): Whether to asynchronously load
  `runtime/plugin/rplugin.vim`, to further reduce startup time. Default 1.

## Events
You can bind autocmds to after a plugin has loaded, like so:
```vim
autocmd User asyncpack:vim-colors-solarized colorscheme solarized
```
