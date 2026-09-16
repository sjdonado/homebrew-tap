class BrowserRouter < Formula
  desc "Smallest possible default browser for macOS: regex-routes links, then exits"
  homepage "https://github.com/sjdonado/browser-router"
  url "https://github.com/sjdonado/browser-router/archive/refs/tags/v1.0.tar.gz"
  sha256 "f0abb7edf72fbb71e016b685849496e822e3a5640efc5e835db0ebd6e95c9c37"
  license "MIT"
  depends_on macos: :ventura

  def install
    (prefix/"BrowserRouter.app/Contents/MacOS").mkpath
    system "xcrun", "swiftc", "-O", "-framework", "AppKit",
           "-o", prefix/"BrowserRouter.app/Contents/MacOS/BrowserRouter",
           "BrowserRouter/main.swift"
    cp "BrowserRouter/Info.plist", prefix/"BrowserRouter.app/Contents/Info.plist"
    # Editing Info.plist invalidates a signature, so sign the assembled bundle.
    system "codesign", "--force", "--sign", "-", prefix/"BrowserRouter.app"
    pkgshare.install "config.example.json"
  end

  def caveats
    <<~EOS
      The bundle is built but not yet the default browser. Finish with:
        cp -R "#{opt_prefix}/BrowserRouter.app" ~/Applications/
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ~/Applications/BrowserRouter.app
        mkdir -p ~/.config/browser-router
        cp -n "#{opt_pkgshare}/config.example.json" ~/.config/browser-router/config.json
        open ~/Applications/BrowserRouter.app
      The last step asks macOS to make BrowserRouter the default browser.
    EOS
  end

  test do
    assert_path_exists prefix/"BrowserRouter.app/Contents/MacOS/BrowserRouter"
    assert_path_exists prefix/"BrowserRouter.app/Contents/Info.plist"
  end
end
