class Elisa < Formula
  desc "KDE Music Player"
  homepage "https://community.kde.org/Elisa"
  url "https://download.kde.org/stable/release-service/20.04.0/src/elisa-20.04.0.tar.xz"
  revision 1
  sha256 "dacb49adeb0bcae6abc4a0748731de924d2291b8ac82876590018fa947181b3b"
  head "https://anongit.kde.org/elisa.git"

  depends_on "cmake" => [:build, :test]
  depends_on "gettext" => :build
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "hicolor-icon-theme"
  depends_on "KDE-mac/kde/kf5-kcmutils"

  def install
    args = std_cmake_args
    args << "-DCMAKE_INSTALL_BUNDLEDIR=#{bin}"
    args << "-DBUILD_TESTING=OFF"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DKDE_INSTALL_QTPLUGINDIR=lib/qt5/plugins"

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
    # Extract Qt plugin and QML2 path
    mkdir "getqmlpath" do
      (Pathname.pwd/"main.cpp").write <<~EOS
        #include <QTextStream>
        #include <QLibraryInfo>
        int main() {
          QTextStream out(stdout);
          out << QLibraryInfo::location(QLibraryInfo::Qml2ImportsPath) << endl;
        }
      EOS

      (Pathname.pwd/"qmlpath.pro").write <<~EOS
        QT += core
        TEMPLATE = app
        TARGET = qmlpath
        CONFIG += cmdline
        CONFIG += silent
        SOURCES += main.cpp
      EOS

      system "#{Formula["qt"].bin}/qmake"
      system "make"
    end
    qtpp = Utils.popen_read("#{Formula["qt"].bin}/qtpaths --plugin-dir").chomp
    qml2pp = Utils.popen_read("./getqmlpath/qmlpath").chomp
    system "/usr/libexec/PlistBuddy",
      "-c", "Add :LSEnvironment:QT_PLUGIN_PATH string \"#{qtpp}\:#{HOMEBREW_PREFIX}/lib/qt5/plugins\"",
      "-c", "Add :LSEnvironment:QML2_IMPORT_PATH string \"#{qml2pp}\:#{HOMEBREW_PREFIX}/lib/qt5/qml\"",
      "#{bin}/elisa.app/Contents/Info.plist"
  end

  def post_install
    mkdir_p HOMEBREW_PREFIX/"share/elisa"
    ln_sf HOMEBREW_PREFIX/"share/icons/breeze/breeze-icons.rcc", HOMEBREW_PREFIX/"share/elisa/icontheme.rcc"
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
    assert `"#{bin}/elisa.app/Contents/MacOS/elisa" --help | grep -- --help` =~ /--help/
  end
end
