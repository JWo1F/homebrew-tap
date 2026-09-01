class Icofon < Formula
  desc "Build an icon font (TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "d9e45493f17746950a279762e0633235a5b59fef3e7f3713ed43762fd56c12ff"
  license "MIT"
  head "https://github.com/JWo1F/icofon.git", branch: "master"

  bottle do
    root_url "https://github.com/JWo1F/homebrew-tap/releases/download/icofon-0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0ae733ce680f5739f8c12ecc4d99dfe24d9ae664546da363240de1b605edc833"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "98d244b4d2e85da67b86cee30b6e423e7b574154613bd39815d89090c679ca66"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c3c6e50c46a6b5de3c147c14c9095edeaa7e10b385946d613195ac8c3e29a1e5"
    sha256 cellar: :any_skip_relocation, sequoia:       "efc8b745cfd9974ea7eef1f26a8fd0ead360152e617be69dc53c394ba60dfacd"
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
