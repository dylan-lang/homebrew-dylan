require "formula"

class Melange < Formula
  homepage "http://opendylan.org/documentation/melange"
  head "https://github.com/dylan-lang/melange.git"

  depends_on "opendylan" => :build

  def install
    system "make", "install", "DESTDIR=#{prefix}"
  end

  test do
    system "make", "check"
  end
end
