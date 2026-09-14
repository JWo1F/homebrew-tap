class Serv < Formula
  desc "Small, fast development server for static sites and single-page apps"
  homepage "https://github.com/JWo1F/serv"
  version "0.3.0"
  license "MIT"

  # Prebuilt binaries from serv's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.3.0/serv-0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "6fcf6a0419b9451d1370c6d478495f134a78b90dd75f56da1dd1fb2a964ed6a4"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.3.0/serv-0.3.0-x86_64-apple-darwin.tar.gz"
      sha256 "4730181766ae221c446c47cd7a8b629e0dc5b4a12f1fea4c1465ccece22d975b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.3.0/serv-0.3.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "433493d2c9c9240cfcecbf97fea440ef6f58d3a5ec181b904775cee0ce922d2c"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.3.0/serv-0.3.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c281959cf22652a350defacd90061402d35d82ba4574120f286648ec2fb7682f"
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
