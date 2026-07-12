# typed: strict
# frozen_string_literal: true

class Opendylan < Formula
  desc "Open Dylan implementation of the Dylan programming language"
  homepage "https://opendylan.org/"

  stable do
    if Hardware::CPU.arm?
      url "https://github.com/dylan-lang/opendylan/releases/download/v2026.2.0/opendylan-2026.2-aarch64-darwin.tar.bz2"
      sha256 "344028dfc0f14aaf8b59a9dc7a96fdf6d3f7697198a3c4c49ba5a792781402c5"
    else
      url "https://github.com/dylan-lang/opendylan/releases/download/v2026.2.0/opendylan-2026.2-x86_64-darwin.tar.bz2"
      sha256 "e52be1e907fbf2cdf6eb786446ffce7629031621b92a7ea4c37d44c7364ebac5"
    end

    depends_on "bdw-gc"
  end

  head do
    url "https://github.com/dylan-lang/opendylan.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bdw-gc" => :build
  end

  def install
    ENV.deparallelize

    if build.head?
      ohai "Compilation takes a long time; use `brew install -v opendylan` to see progress" unless ARGV.verbose?
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make", "3-stage-bootstrap"
      system "make", "install"
    else
      libexec.install Dir["*"]
      bin.install_symlink "#{libexec}/bin/deft"
      bin.install_symlink "#{libexec}/bin/dylan" # temp back compat
      bin.install_symlink "#{libexec}/bin/dylan-compiler"
      bin.install_symlink "#{libexec}/bin/dswank"
      bin.install_symlink "#{libexec}/bin/dylan-environment"
      bin.install_symlink "#{libexec}/bin/dylan-lsp-server"
      bin.install_symlink "#{libexec}/bin/dylan-lldb"

      # dylan-lldb locates its Python helper package by walking up from
      # wherever `dylan-compiler` resolves on the PATH, then down into
      # share/opendylan/lldb/dylan (see tools/scripts/dylan-lldb upstream).
      # That "bin/../share" sibling relationship only holds if share/opendylan
      # is also linked into the prefix, since the actual files live in libexec.
      share.install_symlink "#{libexec}/share/opendylan"
    end
  end

  test do
    assert_predicate bin/"dylan-lldb", :exist?
    assert_predicate share/"opendylan/lldb/dylan", :directory?

    app_name = "hello-world"
    system bin/"deft", "new", "application", "--simple", app_name
    cd app_name do
      system bin/"deft", "build", "--all"
      assert_equal 0, $CHILD_STATUS.exitstatus
    end
    assert_equal "Hello, world!\n",
                 `#{app_name}/_build/bin/#{app_name}`
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
