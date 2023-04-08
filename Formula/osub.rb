class Osub < Formula
  desc "OpenSubtitles in your terminal. Download subtitles like a ninja."
  homepage "https://github.com/vanyauhalin/osub/"
  url "https://github.com/vanyauhalin/osub/releases/download/v0.1.0/osub.tar.zst"
  sha256 "bdc2b3d9b44622ef69babe4ec5e11be21d186d9d77516516aa3e7c85f3031f5a"
  license "MIT"
  head "https://github.com/vanyauhalin/osub/", branch: "main"

  depends_on :macos => :catalina

  def install
    bin.install "osub"
  end

  test do
    system bin/"osub", "--help"
    system bin/"osub", "version", "0.1.0"
  end
end
