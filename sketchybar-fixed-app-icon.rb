# typed: false

# frozen_string_literal: true

# sketchybar-fixed-app-icon.rb
class SketchybarFixedAppIcon < Formula
  env :std
  desc "Forked version of SketchyBar with modified base app icon resolution. Originaly forked from FelixKratz/SketchyBar"
  homepage "https://github.com/iWirk/SketchyBar"
  url "https://github.com/iWirk/SketchyBar/archive/refs/tags/v2.22.0-fixed_app_icon.tar.gz"
  sha256 "713728a4c782ab27f042e429cd4161db2e4f78db5e24e7b8d845c0a5b1086c31"
  license "GPL-3.0-only"
  head "https://github.com/iWirk/SketchyBar.git"

  def clear_env
    ENV.delete("CFLAGS")
    ENV.delete("LDFLAGS")
    ENV.delete("CXXFLAGS")
  end

  def install
    clear_env
    (var/"log/sketchybar").mkpath
    if MacOS.version < 11
      system "make", "x86"
    else
      system "make"
    end

    system "codesign", "--force", "-s", "-", "#{buildpath}/bin/sketchybar"
    bin.install "#{buildpath}/bin/sketchybar"
    (pkgshare/"examples").install "#{buildpath}/sketchybarrc"
    (pkgshare/"examples").install "#{buildpath}/plugins/"

    # Install documentation files
    man.mkpath
    system "curl", "https://felixkratz.github.io/SketchyBar/documentation.tar.gz", "-o", "#{buildpath}/documentation.tar.gz"
    system "tar", "-xzvf", "#{buildpath}/documentation.tar.gz", "-C", "#{buildpath}/"
    man1.install "#{buildpath}/sketchybar.1"
    man5.install "#{buildpath}/sketchybar.5"
    man5.install "#{buildpath}/sketchybar-animate.5"
    man5.install "#{buildpath}/sketchybar-components.5"
    man5.install "#{buildpath}/sketchybar-events.5"
    man5.install "#{buildpath}/sketchybar-items.5"
    man5.install "#{buildpath}/sketchybar-popup.5"
    man5.install "#{buildpath}/sketchybar-query.5"
    man5.install "#{buildpath}/sketchybar-tips.5"
    man5.install "#{buildpath}/sketchybar-types.5"
  end

  def caveats
    <<~EOS
      Copy the example configuration into your home directory and make the scripts executable:
        mkdir -p ~/.config/sketchybar/plugins
        cp #{opt_pkgshare}/examples/sketchybarrc ~/.config/sketchybar/sketchybarrc
        cp -r #{opt_pkgshare}/examples/plugins/ ~/.config/sketchybar/plugins/
        chmod +x ~/.config/sketchybar/plugins/*
    EOS
  end

  service do
    run "#{opt_bin}/sketchybar"
    environment_variables PATH: std_service_path_env, LANG: "en_US.UTF-8"
    keep_alive true
    process_type :interactive
    log_path "#{var}/log/sketchybar/sketchybar.out.log"
    error_log_path "#{var}/log/sketchybar/sketchybar.err.log"
  end

  test do
    echo "To test your installation run: sketchybar -v \n"
  end
end
