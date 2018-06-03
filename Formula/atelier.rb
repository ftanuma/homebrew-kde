class Atelier < Formula
  desc "3D printing host"
  homepage "https://atelier.kde.org"
  head "git://anongit.kde.org/atelier.git"

  depends_on "cmake" => :build
  depends_on "KDE-mac/kde/kf5-extra-cmake-modules" => :build
  depends_on "KDE-mac/kde/atcore"
  depends_on "KDE-mac/kde/kf5-kconfigwidgets"
  depends_on "KDE-mac/kde/kf5-ki18n"
  depends_on "KDE-mac/kde/kf5-knewstuff"
  depends_on "KDE-mac/kde/kf5-ktexteditor"
  depends_on "KDE-mac/kde/kf5-kxmlgui"

  def install
    args = std_cmake_args
    mkdir "build" do
      system "cmake", "-G", "Ninja", "..", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
  end
end
