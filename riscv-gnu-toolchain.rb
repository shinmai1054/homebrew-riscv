class RiscvGnuToolchain < Formula
  desc "RISC-V Compiler GNU Toolchain using newlib"
  homepage "http://riscv.org"
  url "https://github.com/riscv/riscv-gnu-toolchain.git"
  version "main"

  bottle do
    root_url "http://riscv.org.s3.amazonaws.com/bottles"
    rebuild 8
    sha256 monterey: "9fe9c2113a60e9e0ceac29e7c7992001959b20a09c44c1a2781c0c90939489b8"
  end

  # enabling multilib by default, must choose to build without
  option "with-NOmultilib", "Build WITHOUT multilib support"
  
  # RV32i
  option "RV32i", "RV32i"

  depends_on "gawk" => :build
  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "zstd"

  def install
    # disable crazy flag additions
    ENV.delete "CPATH"

    args = [
      "--prefix=#{prefix}",
      "--with-cmodel=medany",
    ]
    args << "--enable-multilib" unless build.with?("NOmultilib")
    args << "--with-arch=rv32g" unless build.with?("RV32i")
    args << "--with-abi=ilp32d" unless build.with?("RV32i")

    # Workaround for M1
    # See https://github.com/riscv/homebrew-riscv/issues/47
    system "sed", "-i", ".bak", "s/.*=host-darwin.o$//", "riscv-gcc/gcc/config.host"
    system "sed", "-i", ".bak", "s/.* x-darwin.$//", "riscv-gcc/gcc/config.host"

    system "./configure", *args
    system "make"

    # don't install Python bindings if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/share/gcc-11.1.0")
      opoo "Not overwriting share/gcc-11.1.0"
      rm_rf "#{share}/gcc-11.1.0"
    end

    # don't install gdb bindings if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/share/gdb")
      opoo "Not overwriting share/gdb"
      rm_rf "#{share}/gdb"
      rm "#{share}/info/annotate.info"
      rm "#{share}/info/gdb.info"
      rm "#{share}/info/stabs.info"
    end

    # don't install gdb includes if system already has them
    if File.exist?("#{HOMEBREW_PREFIX}/include/gdb")
      opoo "Not overwriting include/gdb"
      rm_rf "#{include}/gdb"
    end
  end

  test do
    system "false"
  end
end
