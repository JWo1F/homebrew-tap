class Serv < Formula
  desc "Small, fast development server for static sites and single-page apps"
  homepage "https://github.com/JWo1F/serv"
  version "0.2.0"
  license "MIT"

  # Prebuilt binaries from serv's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.2.0/serv-0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "47ceac70aa4e852fa3acc7b9aabeb4adf4ac6b9fd6c374fd26ccb58c30155116"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.2.0/serv-0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "1fcd371fd21e908128bfd8ce4ab5aa5be80d6781c76ebafed6e73e739cd4dd76"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.2.0/serv-0.2.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "db925d7387470a8c8d1c00d7ce1f4df6ff5cf1c53167200d64fc27c6d5c358e5"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.2.0/serv-0.2.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "50ffefcea65bb34f05737bf17fd8580b85323fc0ba456f5d54da358a9e624152"
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
