require 'fileutils'

class MoPubSDKPublisher
  def initialize
    @root = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
    @mp_constants = File.join(@root, 'MoPubSDK', 'MPConstants.h')
    @target = File.absolute_path(File.join(@root, '..', 'mopub-ios-public'))

    @directories = Dir.glob(Dir.pwd + "/*").map {|d| File.basename(d)}.reject {|d| ["build", "DerivedData"].include?(File.basename(d))}
  end

  def publish!
    update_version
    nuke_existing_repo
    copy_files_over
    remove_private_content

    current_version = get_current_version
    puts """

=======================================================================================

Sync is complete. Next steps:

1) Commit and push this repo (including the version change and tag it with the version):

  cd #{@root}
  git commit -am \"Bump version to #{current_version}\"
  git tag #{current_version}
  git push origin master --tags

2) Commit and push the public repo

  cd #{@target}
  git commit -am \"#{current_version}: YOUR MESSAGE HERE!\"
  git tag #{current_version}
  git push origin master --tags
    """
  end

  def nuke_existing_repo
    puts "\nNuking the existing repo"
    @directories.each do |dir|
      puts "    Deleting #{dir}"
      FileUtils.rm_rf(File.join(@target, dir))
    end
  end

  def copy_files_over
    puts "\nCopying files over"
    @directories.each do |dir|
      puts "    Copying #{dir}"
      FileUtils.cp_r(File.join(@root, dir), File.join(@target, dir))
    end
  end

  def remove_private_content
    puts "\nRemoving Private Content"
    FileUtils.rm_rf(File.join(@target, "Scripts", "private"))
    FileUtils.rm_rf(Dir.glob(File.join(@target, "AdNetworkSupport/**/SDK/*.h")))
    FileUtils.rm_rf(Dir.glob(File.join(@target, "AdNetworkSupport/**/SDK/*.a")))
  end

  def update_version
    current_version = get_current_version
    print "The current SDK version is #{current_version}.  What should the new version be?\n> "
    new_version = STDIN.gets.chomp

    if !/^\d\.\d+\.\d+\.\d+$/.match(new_version)
      puts "\"#{new_version}\" is not a valid version"
      exit(1)
    end

    if new_version == current_version
      puts "The version you entered is identical to the existing version.  You *must* change the version."
      exit(1)
    end

    print "Will set the version to: \"#{new_version}\" are you sure? (yes/no)\n> "
    confirm = STDIN.gets.chomp
    if confirm != 'yes'
      puts "OK, bye!"
      exit(1)
    end

    set_current_version(new_version)
  end

  def get_current_version
    mp_constants = File.open(@mp_constants).read
    version_matcher = /^\#define MP_SDK_VERSION\s+\@\"([\d\.]+)\"/
    match = version_matcher.match(mp_constants)
    if (match)
      return match[1]
    else
      puts "Couldn't find version number!"
      exit(1)
    end
  end

  def set_current_version(new_version)
    output = ""
    version_matcher = /^\#define MP_SDK_VERSION\s+\@\"([\d\.]+)\"/
    did_update_version = false
    mp_constants = File.open(@mp_constants).readlines.each do |line|
      if version_matcher.match(line)
        output << "#define MP_SDK_VERSION              @\"#{new_version}\"\n"
        did_update_version = true
      else
        output << line
      end
    end

    if did_update_version
      File.open(@mp_constants, 'w') do |f|
        f.write(output)
      end
      puts "Updated current version to #{get_current_version}"
    else
      puts "Couldn't update the version number!"
      exit(1)
    end
  end
end