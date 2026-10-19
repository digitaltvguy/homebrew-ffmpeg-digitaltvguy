class Ffmpeg < Formula
  desc "FFmpeg with stock Homebrew features plus additional codecs and libraries"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz"
  sha256 "8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e"
  license "GPL-2.0-or-later"

  depends_on "pkgconf" => :build

  # Stock Homebrew ffmpeg dependencies
  depends_on "dav1d"
  depends_on "lame"
  depends_on "libvpx"
  depends_on "openssl@3"
  depends_on "opus"
  depends_on "sdl2"
  depends_on "svt-av1"
  depends_on "x264"
  depends_on "x265"

  # Additional custom dependencies
  depends_on "aom"
  depends_on "fdk-aac"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "jpeg-xl"
  depends_on "libass"
  depends_on "libplacebo"
  depends_on "librist"
  depends_on "libsoxr"
  depends_on "libvmaf"
  depends_on "little-cms2"
  depends_on "open-color-io"
  depends_on "openjpeg"
  depends_on "srt"
  depends_on "two-lame"
  depends_on "zimg"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_intel do
    depends_on "nasm" => :build
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxcb"
    depends_on "xz"
    depends_on "zlib-ng-compat"
  end

  def install
    if OS.mac? && DevelopmentTools.ld64_version.between?("1015.7", "1022.1")
      ENV.append "LDFLAGS", "-Wl,-ld_classic"
    end

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --enable-gpl
      --enable-nonfree

      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}

      --enable-ffplay

      --enable-libsvtav1
      --enable-libopus
      --enable-libx264
      --enable-libmp3lame
      --enable-libdav1d
      --enable-libvpx
      --enable-libx265
      --enable-openssl

      --enable-libaom
      --enable-libfdk-aac
      --enable-libtwolame
      --enable-librist
      --enable-libsrt
      --enable-libass
      --enable-libfreetype
      --enable-libharfbuzz
      --enable-libsoxr
      --enable-libzimg
      --enable-libvmaf
      --enable-libopenjpeg

      --enable-libplacebo
      --enable-libjxl
      --enable-lcms2
      --enable-libxml2
      --enable-libopencolorio
    ]

    if system("pkg-config", "--exists", "fribidi")
      args << "--enable-libfribidi"
    end

    if OS.mac?
      args << "--enable-videotoolbox"
      args << "--enable-audiotoolbox"
    end

    args << "--enable-neon" if Hardware::CPU.arm?

    system "./configure", *args
    system "make"
    system "make", "install"
    system "make", "alltools"

    bin.install Dir["tools/*"].select { |f| File.file?(f) && File.executable?(f) }
    pkgshare.install "tools/python" if Dir.exist?("tools/python")
  end

  test do
    output = shell_output("#{bin}/ffmpeg -version")
    assert_match "ffmpeg version", output
  end
end
