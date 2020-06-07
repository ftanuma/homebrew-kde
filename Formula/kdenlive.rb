class Kdenlive < Formula
  desc "Video editor"
  homepage "https://www.kdenlive.org/"
  url "https://download.kde.org/stable/release-service/20.04.0/src/kdenlive-20.04.0.tar.xz"
  sha256 "3d56657af2c3946bd44ee821be48fb777457de3a9123485e7a3a3f51de0f9e52"
  head "git://anongit.kde.org/kdenlive.git"

  depends_on "cmake" => [:build, :test]
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "KDE-mac/kde/kf5-kdoctools" => :build
  depends_on "ninja" => :build
  depends_on "shared-mime-info" => :build

  depends_on "hicolor-icon-theme"
  depends_on "KDE-mac/kde/kf5-breeze-icons"
  depends_on "KDE-mac/kde/kf5-kdeclarative"
  depends_on "KDE-mac/kde/kf5-kfilemetadata"
  depends_on "KDE-mac/kde/kf5-knewstuff"
  depends_on "KDE-mac/kde/kf5-knotifyconfig"
  depends_on "mlt"
  depends_on "cdrtools" => :optional
  depends_on "dvdauthor" => :optional
  depends_on "ffmpeg" => :optional
  depends_on "KDE-mac/kde/qt-webkit" => :optional
  depends_on "libdv" => :optional

  patch :DATA

  def install
    args = std_cmake_args
    args << "-DKDE_INSTALL_BUNDLEDIR=#{bin}"
    args << "-DKDE_INSTALL_LIBDIR=lib"
    args << "-DKDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-DKDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-DBUILD_TESTING=OFF"
    args << "-DQt5WebKitWidgets_DIR=" + Formula["qt-webkit"].opt_prefix + "/lib/cmake/Qt5WebKitWidgets"
    args << "-DUPDATE_MIME_DATABASE_EXECUTABLE=OFF"

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
      "#{bin}/kdenlive.app/Contents/Info.plist"

    # Rename the .so files
    mv "#{lib}/qt5/plugins/mltpreview.so", "#{lib}/qt5/plugins/mltpreview.dylib"
  end

  def post_install
    mkdir_p HOMEBREW_PREFIX/"share/kdenlive"
    ln_sf HOMEBREW_PREFIX/"share/icons/breeze/breeze-icons.rcc", HOMEBREW_PREFIX/"share/kdenlive/icontheme.rcc"
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
    assert `"#{bin}/kdenlive.app/Contents/MacOS/kdenlive" --help | grep -- --help` =~ /--help/
  end
end

# Fix shared-mime-info for use with ECM instead of set as hard requeriment.

__END__
diff --git a/data/CMakeLists.txt b/data/CMakeLists.txt
index a69ba42..8bf8b1c 100644
--- a/data/CMakeLists.txt
+++ b/data/CMakeLists.txt
@@ -33,7 +33,13 @@ install(FILES profiles.xml DESTINATION ${DATA_INSTALL_DIR}/kdenlive/export)
 install(FILES org.kde.kdenlive.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
 install(FILES org.kde.kdenlive.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

-find_package(SharedMimeInfo REQUIRED)
+find_package(SharedMimeInfo 0.70)
+set_package_properties(SharedMimeInfo PROPERTIES
+                       TYPE OPTIONAL
+                       PURPOSE "Allows KDE applications to determine file types"
+                       )
 install(FILES org.kde.kdenlive.xml westley.xml DESTINATION ${XDG_MIME_INSTALL_DIR})
-update_xdg_mimetypes(${XDG_MIME_INSTALL_DIR})
+if(SharedMimeInfo_FOUND)
+    update_xdg_mimetypes(${KDE_INSTALL_MIMEDIR})
+endif()

