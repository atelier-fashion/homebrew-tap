# teton 0.1.4 — GENERATED FILE, DO NOT EDIT IN THE TAP.
#
# Rendered from `packaging/homebrew/teton.rb.tmpl` in atelier-fashion/teton-code
# by `tools/release/render-formula.sh`, and pushed to
# atelier-fashion/homebrew-tap by that repo's release workflow (ADR-548-1).
# The tap is a publish target, never a source: any hand edit here is silently
# overwritten by the next release. Change the template instead, where the edit
# rides the repo's PR review.
#
# The three `sha256` values below were computed in the release run from the
# bytes GitHub actually serves at the URLs beside them (BR-5) — never typed,
# never carried over from a local build.
#
# There is deliberately no `version` stanza: Homebrew scans the version out of
# the release URL, and `brew audit` rejects a declaration that agrees with the
# scan as redundant — so the audit gate and an explicit version cannot both
# exist. The version is therefore pinned the same way the sha256s are, by the
# rendered URLs, and the release workflow asserts that the version Homebrew
# resolves equals the tag before it pushes (BR-3) rather than trusting the
# scanner's heuristic.
class Teton < Formula
  desc "Local-first AI coding agent — the teton CLI and its teton-code daemon"
  homepage "https://tetoncode.ai"
  license "MIT"

  # Prebuilt per-target tarballs, not a source build: reimposing the Rust +
  # cmake toolchain on every install is the burden this formula exists to
  # remove (REQ-548). Each tarball is flat — `teton`, `teton-code`, `LICENSE`,
  # `README.md` at its root — and was built with `--features tetond/llama`, so
  # an installed daemon can always load the model the CLI offers to fetch
  # (BR-2).
  # macOS: Developer ID signed, team 545BU9G9D6. Linux: unsigned in v1.
  on_macos do
    on_arm do
      url "https://github.com/atelier-fashion/teton-code/releases/download/v0.1.4/teton-v0.1.4-aarch64-apple-darwin.tar.gz"
      sha256 "9928fd096050ff4b0f0e74dd516f3551783492401616be8e012f10393040e175"
    end

    on_intel do
      url "https://github.com/atelier-fashion/teton-code/releases/download/v0.1.4/teton-v0.1.4-x86_64-apple-darwin.tar.gz"
      sha256 "ae779a5c5fe182a18b34b66b5132accc059923cef79bfae60659545b657da7fb"
    end
  end

  # x86_64 only, deliberately: there is no arm64 Linux build, and stubbing a
  # target we do not produce would make `brew install` fail with a 404 instead
  # of Homebrew's honest "does not provide a package for this platform"
  # (BR-10 — do not claim what the shipped binaries cannot do).
  on_linux do
    on_intel do
      url "https://github.com/atelier-fashion/teton-code/releases/download/v0.1.4/teton-v0.1.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "52580ed552c0ecbd73105d2dd6ff855923a6ba5559e35705cbe19bd3611132f2"
    end
  end

  def install
    # BR-1: both binaries, one command. `teton` without `teton-code` is a CLI with
    # nothing to talk to.
    bin.install "teton", "teton-code"

    # Created here rather than left to launchd: the service below redirects
    # stdout/stderr into this directory, and launchd does not create a missing
    # parent — it fails the spawn, which surfaces as a service that flaps
    # instead of a message about a missing directory (BR-6).
    (var/"log/teton").mkpath
  end

  service do
    # `teton-code` runs in the foreground and resolves its own socket, lock and
    # state under `~/Library/Application Support/teton`, so launchd needs to
    # pass it nothing. A second instance exits 0 with "already running", which
    # is exactly what keep_alive wants from a restart that raced a live daemon.
    run [opt_bin/"teton-code"]
    keep_alive true
    log_path var/"log/teton/teton-code.log"
    error_log_path var/"log/teton/teton-code.err.log"
  end

  test do
    # AC-5. `--version` is the whole assertion on purpose: `brew test` runs in a
    # sandbox with no daemon, and `teton doctor` exits 0 whether or not one is
    # reachable — a doctor assertion here would pass against nothing. The live
    # start → doctor → stop handshake is exercised by the release workflow's
    # `bump-formula` job (before it pushes the tap), where there is a real
    # launchd service to talk to.
    assert_match version.to_s, shell_output("#{bin}/teton --version")
    assert_match version.to_s, shell_output("#{bin}/teton-code --version")
  end
end
