class Kf5Kimageformats < Formula
  desc "Image format plugins for Qt5"
  homepage "https://www.kde.org"
  url "https://download.kde.org/stable/frameworks/5.70/kimageformats-5.70.0.tar.xz"
  revision 1
  sha256 "7a84fe4ae40ad99861de258a912f730e7d43196ecdd41a766fff2a5ec459645e"
  head "git://anongit.kde.org/kimageformats.git"

  depends_on "cmake" => [:build, :test]
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "jasper"
  depends_on "openexr"
  depends_on "qt"

  depends_on "KDE-mac/kde/kf5-karchive" => :optional

  def install
    args = std_cmake_args
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
    assert_predicate lib/"qt5/plugins/imageformats/kimg_eps.so", :exist?
    assert_predicate share/"kservices5/qimageioplugins/eps.desktop", :exist?
  end
end
