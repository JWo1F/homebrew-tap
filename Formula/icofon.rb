class Icofon < Formula
  desc "Build an icon font (WOFF2/WOFF/TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  version "0.5.1"
  license "MIT"

  # Prebuilt binaries from icofon's own release, so there is no bottle to build
  # and no Rust toolchain to pull in. The Linux builds are statically linked
  # against musl and run on any distribution.
  on_macos do
    on_arm do
      url "https://github.com/JWo1F/icofon/releases/download/v0.5.1/icofon-0.5.1-aarch64-apple-darwin.tar.gz"
      sha256 "bef52e51efdc112a6c0374bb727219d74765178d2a231ddba1bb7c370fd218f4"
    end
    on_intel do
      url "https://github.com/JWo1F/icofon/releases/download/v0.5.1/icofon-0.5.1-x86_64-apple-darwin.tar.gz"
      sha256 "d373479360013c66f91d09de18ab6d66699fa69f8eaba52302ba67bd2c44daef"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/JWo1F/icofon/releases/download/v0.5.1/icofon-0.5.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "70eaea41f0f0a08e502aebc75eeed4b2431774ec0f3ffb0a4b35bbc22cf035c6"
    end
    on_intel do
      url "https://github.com/JWo1F/icofon/releases/download/v0.5.1/icofon-0.5.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7ca0d00f7f2f9d7ee33134ac5434f3eae2c8c4606d8091ae17147270700f02d3"
    end
  end

  def install
    bin.install "icofon"
  end

  test do
    (testpath/"icons").mkpath
    # A stroke-drawn icon: a font can only fill, so the stroke has to be
    # converted to an outline. That is the conversion most likely to break.
    (testpath/"icons/check.svg").write <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M4 12l5 5L20 6" fill="none" stroke="currentColor" stroke-width="2"/>
      </svg>
    SVG

    system bin/"icofon", "build", testpath/"icons", "-o", testpath/"dist", "--name", "icons"

    assert_path_exists testpath/"dist/icons.woff2"
    assert_path_exists testpath/"dist/icons.woff"
    assert_path_exists testpath/"dist/icons.ttf"
    assert_match "icon-check", (testpath/"dist/icons.css").read
    # The browser must be offered the smallest container first.
    assert_match "url('icons.woff2') format('woff2')", (testpath/"dist/icons.css").read

    system bin/"icofon", "check", testpath/"icons"
  end
end
