class Serv < Formula
  desc "Small, fast development server for static sites and single-page apps"
  homepage "https://github.com/JWo1F/serv"
  version "0.1.1"
  license "MIT"

  # Prebuilt binaries from serv's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.1/serv-0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "0186042b84005a61ea5fbf5b794f70033d4bb3d20939c0cde35e9a7a6ade039c"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.1/serv-0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "c602b2030cfa4c7c8ed9ac6f13b1bd68739a464d9a41f7b8fc697b68b6962f2e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.1/serv-0.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "17af10f4ce075a99213e5b127c8d13470260a7c1d839102c046578e9e6d81405"
    end
    on_intel do
      url "https://github.com/JWo1F/serv/releases/download/v0.1.1/serv-0.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9297f08d71c912d1d6f75bd6e8efe1296eb7f1c0ee807af5805d43b5a1559127"
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
