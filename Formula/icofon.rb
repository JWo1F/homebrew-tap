class Icofon < Formula
  desc "Build an icon font (TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "d9e45493f17746950a279762e0633235a5b59fef3e7f3713ed43762fd56c12ff"
  license "MIT"
  head "https://github.com/JWo1F/icofon.git", branch: "master"

  bottle do
    root_url "https://github.com/JWo1F/icofon/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "dc20cd6cd1467042f4ad9af0e16c847417a9390ea2bc545b828275b53a99471b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "13d621d66742de152bac4a008616a15107dbc38e426ac0b8ec04a5ff1febecc0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "97baa844f82d6e90b9a1cc474d96d858ba18516ee05ff473d0c069bfba92aa3d"
    sha256 cellar: :any_skip_relocation, sequoia:       "8175c0f11c3c39a64a89f4cc3411b79f98561f18900137cba67768c7a4977e07"
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
