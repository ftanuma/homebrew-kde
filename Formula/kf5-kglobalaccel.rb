class Kf5Kglobalaccel < Formula
  desc "Add support for global workspace shortcuts"
  homepage "https://www.kde.org"
  url "https://download.kde.org/stable/frameworks/5.70/kglobalaccel-5.70.0.tar.xz"
  revision 1
  sha256 "7fa44a87ddfb6e829687e9041561ae73346037a94c78530fe43cfa8ad88bb842"
  head "git://anongit.kde.org/kglobalaccel.git"

  depends_on "cmake" => [:build, :test]
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "KDE-mac/kde/kf5-kconfig"
  depends_on "KDE-mac/kde/kf5-kcrash"
  depends_on "KDE-mac/kde/kf5-kdbusaddons"

  def install
    args = std_cmake_args
    args << "-DBUILD_TESTING=OFF"
    args << "-DBUILD_QCH=ON"
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
    (testpath/"CMakeLists.txt").write("find_package(KF5GlobalAccel REQUIRED)")
    system "cmake", ".", "-Wno-dev"
  end
end
