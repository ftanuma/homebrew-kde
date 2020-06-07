class Atcore < Formula
  desc "API to manage the connection to 3D Printers"
  homepage "https://www.kde.org"
  url "https://download.kde.org/stable/atcore/1.0.0/atcore-1.0.0.tar.xz"
  sha256 "ffd12455c9b8db853e455a437d6c6b601e0003c6732bbc6c2828032e004530e2"
  revision 2
  head "git://anongit.kde.org/atcore.git"

  option "with-gui", "Build atcore-gui (HEAD ONLY)"
  depends_on "cmake" => [:build, :test]
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "qt"

  def install
    args = std_cmake_args
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DKDE_INSTALL_QTPLUGINDIR=lib/qt5/plugins"
    args << "-DCMAKE_INSTALL_BUNDLEDIR=#{bin}"
    args << "-DBUILD_GUI=ON" if build.with?("gui")

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"

      # move the plugins to real path
      mv "#{bin}/plugins", "#{bin}/AtCoreTest.app/Contents/MacOS/plugins"
    end
    # Extract Qt plugin path
    qtpp = `#{Formula["qt"].bin}/qtpaths --plugin-dir`.chomp
    system "/usr/libexec/PlistBuddy",
      "-c", "Add :LSEnvironment:QT_PLUGIN_PATH string \"#{qtpp}\:#{HOMEBREW_PREFIX}/lib/qt5/plugins\"",
      "#{bin}/AtCoreTest.app/Contents/Info.plist"
  end

  def caveats
    <<~EOS
      kde-mac/kde tap is now moved to KDE Invent. Old repo will not receive updates. 
      Please run the following commands in order to receive updates:
        brew untap kde-mac/kde
        brew tap kde-mac/kde https://invent.kde.org/packaging/homebrew-kde.git --force-auto-update
    EOS
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(AtCore REQUIRED)")
    system "cmake", ".", "-Wno-dev"
  end
end
