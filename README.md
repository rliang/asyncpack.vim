# asyncpack.vim
Improves vim8/neovim startup times by deferring sourcing files.

## What
Vim runtime files, plugins and `start` packages are usually loaded all at once
during startup. So if you have many plugins, you typically have to wait some
time until the UI is presented.

What we want is to source vim files asynchronously, which is not possible by
design, but we can fake it through the vim8 `timers` feature, which specifies
that `The callback is only invoked when Vim is waiting for input`.

What this plugin does is fire a timer and source one file per callback,
allowing the UI to refresh in the meanwhile. Thus, improving startup time and
responsiveness, as seen by some `--startuptime` measurements:

* 23 `start` packages: `480.212  006.737: first screen update`
* 23 `opt` packages: `374.875  008.685: first screen update`
* 23 `opt` packages + `asyncpack#optimize=0`: `388.835  006.843: first screen update`
* 23 `opt` packages + `asyncpack#optimize=1`: `063.102  007.178: first screen update`
* 23 `opt` packages + `asyncpack#optimize=2`: `033.373  001.068: first screen update`

Note that if some file is large enough, it can take more time to load than the
time until the next UI refresh, causing flicker.

## Installation
Clone the repo as an `opt` package:
```sh
git clone --depth=1 https://github.com/rliang/asyncpack.vim ~/.config/nvim/pack/foo/opt/asyncpack.vim`
```

To ensure it is loaded before anything else, add to `.vimrc` or `init.vim`:
```vim
packadd asyncpack.vim
```

For best results, all external plugins should be `opt` packages.

## Variables
* `g:asyncpack#include` (List): `opt` packages to load asynchronously.
  Defaults to all `opt` packages in `&packpath`.
* `g:asyncpack#exclude` (List): `opt` packages to not load asynchronously.
  Use if you want to load some packages through e.g. autocommands.
  Defaults to all `opt` packages in `$VIM/runtime/pack`.
* `g:asyncpack#optimize` (Integer): 0 to only load `opt` packages asynchronously,
  1 to also defer loading plugins and `start` packages (at once),
  2 to also defer loading vim runtime files.
  Default 2.

## Events

```vim
autocmd User asyncpack:runtime echo "loaded runtime files"
autocmd User asyncpack:plugins echo "loaded plugins and start packages"
autocmd User asyncpack:opts:vim-colors-solarized colorscheme solarized
autocmd User asyncpack:opts echo "loaded opt packages"
```
