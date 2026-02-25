# typed: strict
# frozen_string_literal: true

# Open Dylan formula
class Opendylan < Formula
  desc "Implementation of the Dylan programming language (Open Dylan)"
  homepage "https://opendylan.org/"
  url "https://github.com/dylan-lang/opendylan/releases/download/v2026.1.0/opendylan-2026.1-x86_64-darwin.tar.bz2"
  sha256 "305bcba52914713508fa1a97b5b6d7e042fba1b0d1415eab90c35417b2da15cd"

  depends_on "bdw-gc"

  head do
    url "https://github.com/dylan-lang/opendylan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bdw-gc" => :build
  end

  def install
    ENV.deparallelize

    if build.head?
      ohai "Compilation takes a long time; use `brew install -v opendylan` to see progress" unless verbose?
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make", "3-stage-bootstrap"
      system "make", "install"
    else
      libexec.install Dir["*"]
      bin.install_symlink "#{libexec}/bin/dylan"
      bin.install_symlink "#{libexec}/bin/dylan-compiler"
      bin.install_symlink "#{libexec}/bin/dswank"
    end
  end

  test do
    app_name = "hello-world"
    system bin/"dylan", "new", "application", "--simple", app_name
    cd app_name do
      system bin/"dylan", "build", "--all"
      assert_equal 0, $CHILD_STATUS.exitstatus
    end
    assert_equal "Hello, world!\n",
                 `#{app_name}/_build/bin/#{app_name}`
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
