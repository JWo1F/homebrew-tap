class Icofon < Formula
  desc "Build an icon font (WOFF2/WOFF/TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "ab4fac67fb5900d7c1b3062d36f62a567eb365c5cbe2c5420080c8e099e7155b"
  license "MIT"
  head "https://github.com/JWo1F/icofon.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
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
