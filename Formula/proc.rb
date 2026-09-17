class Proc < Formula
  desc "Run the processes in a Procfile, each in its own PTY, from one terminal"
  homepage "https://github.com/JWo1F/proc"
  version "2.14.0"
  license "MIT"

  # Prebuilt binaries from proc's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/proc/releases/download/v2.14.0/proc-2.14.0-aarch64-apple-darwin.tar.gz"
      sha256 "0fb63617c91d179a2aedc4e5bd6ef6a5e1edf19757d0eb022566d2ddcf0fdabc"
    end
    on_intel do
      url "https://github.com/JWo1F/proc/releases/download/v2.14.0/proc-2.14.0-x86_64-apple-darwin.tar.gz"
      sha256 "e711dc22437704c9aa34671592224191f42e8ec27b8684c8a24b3b5500aa5425"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/proc/releases/download/v2.14.0/proc-2.14.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "620de3be724aed97e8dc0102cff605f13fe60b2354e2eaa9b4ccb1846cb72b19"
    end
    on_intel do
      url "https://github.com/JWo1F/proc/releases/download/v2.14.0/proc-2.14.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e3247df587752a63b01966d6f359f8f036e21a33396cb2d0f0b8f11e5159f5c2"
    end
  end

  def install
    bin.install "proc"
  end

  test do
    (testpath/"Procfile").write <<~PROCFILE
      greeter: echo marker-one
      seed(optional): echo marker-seed
    PROCFILE

    # Parsing, including the flag list, without running anything. `list`
    # reports on stdout; `check` reports on stderr, hence the redirect.
    assert_match "seed(optional)", shell_output("#{bin}/proc list -c Procfile")
    assert_match "2 processes OK", shell_output("#{bin}/proc check -c Procfile 2>&1")

    # Homebrew runs this with stdin redirected, which is precisely the case an
    # explicit -c has to win over: without it proc would read the empty stream
    # as piped input instead of running the file. Each process gets its own
    # PTY, so this also proves PTY allocation works on the installed binary.
    output = shell_output("#{bin}/proc -c Procfile --on-exit ignore")
    assert_match "marker-one", output
    # An optional process stays out of the run until it is asked for by name.
    refute_match "marker-seed", output

    enabled = shell_output("#{bin}/proc -c Procfile --on-exit ignore -e seed")
    assert_match "marker-seed", enabled

    assert_match version.to_s, shell_output("#{bin}/proc --version")
  end
end
