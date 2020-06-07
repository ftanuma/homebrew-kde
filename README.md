# Moved

**This repo is now deprecated, we had moved to KDE Invent: [invent.kde.org/packaging/homebrew-kde](https://invent.kde.org/packaging/homebrew-kde)**

In order to migrate to the new repo please run the following in terminal:

```sh
brew untap kde-mac/kde 2> /dev/null
brew tap kde-mac/kde https://invent.kde.org/packaging/homebrew-kde.git --force-auto-update
"$(brew --repo kde-mac/kde)/tools/do-caveats.sh"
```