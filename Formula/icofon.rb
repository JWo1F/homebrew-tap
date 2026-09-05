class Icofon < Formula
  desc "Build an icon font (WOFF2/WOFF/TTF + CSS) from a folder of SVG files"
  homepage "https://github.com/JWo1F/icofon"
  url "https://github.com/JWo1F/icofon/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "2f696131c0379ff1aaf5b2f59a8e1cab8f9f50c603ad5e979659cea032b9531c"
  license "MIT"
  head "https://github.com/JWo1F/icofon.git", branch: "master"

  bottle do
    root_url "https://github.com/JWo1F/homebrew-tap/releases/download/icofon-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "875154aaeec3564f4a3faa0266bd5a549b2052567ed5eedc395c4d6213f33f30"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9014d1dc95f908659ae6d45aed6b5065e59016c2b09c25030e97007b1891daa9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cce27acc95c92924c17f59f0ab8c363ad90dac8e938fa8930352f275177b4a25"
    sha256 cellar: :any_skip_relocation, sequoia:       "f31552194648b936338857bf6a933ab5dbe321f3dc8e4bc979f546d6332e924a"
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
