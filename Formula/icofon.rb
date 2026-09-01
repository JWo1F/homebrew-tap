class Icofon < Formula
  desc "Build an icon font (TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "d9e45493f17746950a279762e0633235a5b59fef3e7f3713ed43762fd56c12ff"
  license "MIT"
  head "https://github.com/JWo1F/icofon.git", branch: "master"

  bottle do
    root_url "https://github.com/JWo1F/icofon/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8983a4e8eda33bfe6d20adb2cc2550b65cdc29f9f86e735cfc9645c055aeebf8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f400e6378ff04f096c654538fe551412c52fb8cc94fa85419ceb2ff17334da02"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e17dfc0d922b7da8bf59f611b82b84d2c47a07215849d4ec9824411c93014609"
    sha256 cellar: :any_skip_relocation, sequoia:       "adf26498f5760d2cd6ed7b471a7cd41eb14ad0b2b50d4751e0554fa1feff1a65"
  end

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
