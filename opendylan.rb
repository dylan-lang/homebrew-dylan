require "formula"

class Opendylan < Formula
  homepage "http://opendylan.org/"

  stable do
    url "http://opendylan.org/downloads/opendylan/2013.2/opendylan-2013.2-x86-darwin.tar.bz2"
    sha1 "78faaec910c67356cd4b5ce7101153b6acf01cbe"

    depends_on "bdw-gc" => :universal
  end

  head do
    url "https://github.com/dylan-lang/opendylan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bdw-gc" => :build
  end

  depends_on :macos => :lion
  depends_on :arch => :intel

  def install

    ENV.deparallelize

    if build.head?
      ohai "Compilation takes a long time; use `brew install -v opendylan` to see progress" unless ARGV.verbose?
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make 3-stage-bootstrap"
      system "make install"
    else
      libexec.install Dir["*"]
      bin.install_symlink "#{libexec}/bin/dylan-compiler"
      bin.install_symlink "#{libexec}/bin/make-dylan-app"
      bin.install_symlink "#{libexec}/bin/dswank"
    end
  end

  def test
    app_name = "hello-world"
    system bin/"make-dylan-app", app_name
    cd app_name do
      system bin/"dylan-compiler", "-build", app_name
      assert_equal 0, $?.exitstatus
    end
    assert_equal "Hello, world!\n",
                 `#{ app_name }/_build/bin/#{ app_name }`
    assert_equal 0, $?.exitstatus
  end
end
