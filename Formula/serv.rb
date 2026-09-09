class Serv < Formula
  desc "Small, fast development server for static sites and single-page apps"
  homepage "https://github.com/JWo1F/serv"
  version "0.1.0"
  license "MIT"

  # Prebuilt binaries from serv's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.0/serv-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "9fd3e8b07724bbfa4205a23d2ac4d2056a9eab0845325960d1d31e61dbc1540e"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.0/serv-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "6b64895d6074ccb7f49e42e75eb4e1f79717f6737de06808759801a086e95558"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.0/serv-0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4ff64f6837f3fed296b1de1ec6629c24df749b1ecafe9fcf91459c0b93921249"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.0/serv-0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "523f8b76578bb3e2d51899f7ee2701f45cc8afbe66158d099248845cd322e23c"
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
