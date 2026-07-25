# homebrew-tap

The Homebrew tap for [Teton Code](https://github.com/atelier-fashion/teton-code).

```
brew install atelier-fashion/tap/teton
```

`Formula/teton.rb` **arrives with the first tagged release** of teton-code and
is **machine-written** by that repo's release workflow (`bump-formula` job) on
every release. Hand edits here will be overwritten by the next release — the
formula's source of truth is
[`packaging/homebrew/teton.rb.tmpl`](https://github.com/atelier-fashion/teton-code/blob/main/packaging/homebrew/teton.rb.tmpl)
in teton-code, which is where changes belong.

Until the first release lands there is nothing to install from this tap — that
is deliberate: a formula pointing at artifacts that do not exist yet would
half-install. See teton-code's `docs/homebrew-tap-setup.md` and
`docs/release-runbook.md` for how this tap is written to.

MIT, same as teton-code.
