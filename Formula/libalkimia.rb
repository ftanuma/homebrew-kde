class Libalkimia < Formula
  desc "Library used by KDE Finance applications"
  homepage "https://kmymoney.org"
  url "https://download.kde.org/stable/alkimia/8.0.3/alkimia-8.0.3.tar.xz"
  sha256 "1e57ed9279557d8e3575e7556a81b08dff4e882e9f5ad8502da63bfc98c7b33e"
  head "git://anongit.kde.org/alkimia.git"

  depends_on "cmake" => [:build, :test]
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "gettext"
  depends_on "gmp"
  depends_on "KDE-mac/kde/kf5-kcoreaddons"
  depends_on "kde-mac/kde/kf5-kdelibs4support"
  depends_on "kde-mac/kde/kf5-knewstuff"
  depends_on "kde-mac/kde/kf5-plasma-framework"
  depends_on "KDE-mac/kde/qt-webkit"

  def install
    args = std_cmake_args
    args << "-DBUILD_TESTING=OFF"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DQt5WebKitWidgets_DIR=" + Formula["qt-webkit"].opt_prefix + "/lib/cmake/Qt5WebKitWidgets"
    args << "-DCMAKE_INSTALL_BUNDLEDIR=#{bin}"

    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
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
    (testpath/"CMakeLists.txt").write("find_package(LibAlkimia5 REQUIRED)")
    system "cmake", ".", "-Wno-dev"
  end
end
