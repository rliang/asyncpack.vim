# asyncpack.vim
Improves vim startup times by deferring sourcing files with timers.

## What
Vim runtime files, plugins and `start` packages are usually loaded all at once
during startup. So if you have many plugins, you typically have to wait some
time until the UI is presented.

What we want is to source vim files asynchronously, which is not possible by
design, but we can fake it through the vim 8's `timers` feature. With this
plugin, runtime files, plugins and `start` packages are loaded *after* vim's
startup, in a pseudo-asynchronous way.

## How
What this plugin does is override the sourcing of files with the `SourceCmd`
autocmd and add them to a queue, then fire a timer and source one file per
callback.

The `timer_start` function specifies that `The callback is only invoked when
Vim is waiting for input`, so by sourcing one file per callback, as long as the
file isn't too big, we can allow the UI to refresh afterwards, thus, improving
responsiveness.

If some file is large enough, it can take more time to load than the time until
the next UI refresh, causing flicker.

## Installation

For best results, asyncpack.vim should be loaded first-hand after `.vimrc` or
`init.vim`.

#### Using `packpath`

Put the repo under an `opt` directory in `packpath`:

```sh
git clone --depth=1 https://github.com/rliang/asyncpack.vim ~/.config/nvim/pack/foo/opt/asyncpack.vim`
```

Then add to `.vimrc` or `init.vim`:
```vim
packadd asyncpack.vim
```

#### Using `runtimepath`

Add to `.vimrc` or `init.vim`:

```vim
set rtp^=/path/to/asyncpack.vim
runtime! plugin/asyncpack.vim
```

## Events

* `User` `asyncpack`: When all deferred files have been loaded.
