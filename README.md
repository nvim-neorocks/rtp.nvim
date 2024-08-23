# rtp.nvim

Source `plugin` and `ftdetect` directories on the Neovim `:h runtimepath`.

If you install plugins to a different location than the `:h packpath`,
you can use this library to source their
`plugin`, `ftdetect` and `after-directory` scripts.

The main use cases are:

- As a dependency for plugin managers,
  such as [rocks-dev.nvim](https://github.com/nvim-neorocks/rocks-dev.nvim).
- For use with lazy-loading utilities,
  such as [rocks-lazy.nvim](https://github.com/nvim-neorocks/rocks-lazy.nvim)
  or [lz.n](https://github.com/nvim-neorocks/lz.n).

See the [API reference](./doc/rtp_nvim.txt) for documentation.
