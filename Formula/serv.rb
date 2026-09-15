class Serv < Formula
  desc "Small, fast development server for static sites and single-page apps"
  homepage "https://github.com/JWo1F/serv"
  version "0.4.0"
  license "MIT"

  # Prebuilt binaries from serv's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.4.0/serv-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "40ad1ebaaacc637a7e91c33ffae71645d41bb711fb58503116e09f9537c7e38c"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.4.0/serv-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "75796aa656ebcaa2f8410fb852b93db33f0e405b0455960a37b33c098ad07222"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.4.0/serv-0.4.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4251e73b1d9dcc8b697ace69d4ff88005442d65b9042d99bded27a80d8f76d83"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.4.0/serv-0.4.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7a7ce99f3697499937564049eabb273d8a9fafc63d1358e28dca5d29420b8cf5"
    end
  end

  def install
    bin.install "serv"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/serv --version")

    (testpath/"site").mkpath
    (testpath/"site/index.html").write "<h1>it serves</h1>"
    (testpath/"site/about.html").write "<h1>the about page</h1>"

    port = free_port
    pid = spawn bin/"serv", testpath/"site", "-p", port.to_s, "-q"

    begin
      base = "http://127.0.0.1:#{port}"
      curl = "curl -fsS --retry 5 --retry-connrefused --retry-delay 1"

      # A folder with an index.html serves it.
      assert_match "it serves", shell_output("#{curl} #{base}/")
      # Clean URLs: /about resolves to about.html without the extension.
      assert_match "the about page", shell_output("#{curl} #{base}/about")
      # A miss is a 404, not a redirect or a 200 with the wrong body.
      assert_match "404", shell_output("#{curl} -o /dev/null -w '%{http_code}' #{base}/nope || true")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
