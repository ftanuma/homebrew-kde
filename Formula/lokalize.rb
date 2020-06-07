class Lokalize < Formula
  desc "Computer-aided translation system"
  homepage "https://www.kde.org/applications/development/lokalize/"
  url "https://download.kde.org/stable/release-service/20.04.0/src/lokalize-20.04.0.tar.xz"
  sha256 "746620117294e2e6b7eb22a470789d2c1b3196f12cf15e3b186256d587658361"
  head "git://anongit.kde.org/lokalize.git"

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "gettext"
  depends_on "hicolor-icon-theme"
  depends_on "hunspell"
  depends_on "KDE-mac/kde/kf5-kross"
  depends_on "poxml"
  depends_on "qt"
  depends_on "translate-toolkit"
  depends_on "subversion" => :optional

  def install
    args = std_cmake_args
    args << "-DBUILD_TESTING=OFF"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DCMAKE_INSTALL_BUNDLEDIR=#{bin}"

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
    # Extract Qt plugin path
    qtpp = `#{Formula["qt"].bin}/qtpaths --plugin-dir`.chomp
    system "/usr/libexec/PlistBuddy",
      "-c", "Add :LSEnvironment:QT_PLUGIN_PATH string \"#{qtpp}\:#{HOMEBREW_PREFIX}/lib/qt5/plugins\"",
      "#{bin}/lokalize.app/Contents/Info.plist"
  end

  def post_install
    mkdir_p HOMEBREW_PREFIX/"share/lokalize"
    ln_sf HOMEBREW_PREFIX/"share/icons/breeze/breeze-icons.rcc", HOMEBREW_PREFIX/"share/lokalize/icontheme.rcc"
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
    assert `"#{bin}/lokalize.app/Contents/MacOS/lokalize" --help | grep -- --help` =~ /--help/
  end
end
