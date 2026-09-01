class Icofon < Formula
  desc "Build an icon font (TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "141ee9b685d147309af52118ff319aaff5c7211b5deb5beae0ffe055fa3e663f"
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

    system bin/"icofon", testpath/"icons", testpath/"out/icofon.ttf", "--no-html"

    assert_path_exists testpath/"out/icofon.ttf"
    assert_match "icon-check", (testpath/"out/icofon.css").read
  end
end
