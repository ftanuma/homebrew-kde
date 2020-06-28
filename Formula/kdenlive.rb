class Kdenlive < Formula
  desc "We have moved our repo to KDE Invent"
  homepage "https://invent.kde.org/packaging/homebrew-kde"
  url "file:///dev/null"
  version "666"

  ohai "We have moved our repo to KDE Invent."

  opoo "GitHub repo is discontinued, archived and will no longer receive updates."

  odie "In order to continue using our packages, please run the following command:
    brew untap kde-mac/kde
    brew tap kde-mac/kde https://invent.kde.org/packaging/homebrew-kde.git --force-auto-update
    `$(brew --repo kde-mac/kde)/tools/do-caveats.sh`"
end
