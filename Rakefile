require 'tmpdir'

CONFIGURATION = "Debug"
SDK_VERSION = "6.1"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")

def xcode_developer_dir
  `xcode-select -print-path`.strip
end

def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, env_overrides = {}, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout

  old_env = {}
  env_overrides.each do |key, value|
    old_env[key] = ENV[key]
    ENV[key] = value
  end

  system(cmd) or begin
    puts "******** Build failed ********"
    if stdout
      puts "To review:"
      puts "mate #{stdout}"
    end
    exit(1)
  end

  env_overrides.each do |key, value|
    ENV[key] = old_env[key]
  end
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    build_dir = File.join(File.dirname(__FILE__), "build")
    Dir.mkdir(build_dir) unless File.exists?(build_dir)
    build_dir
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

def head(text)
  puts "\n########### #{text} ###########"
end

def build(options)
  target = options[:target]
  project = options[:project]
  configuration = options[:configuration] || CONFIGURATION
  if options[:sdk]
    sdk = options[:sdk]
  elsif options[:sdk_version]
    sdk = "iphonesimulator#{options[:sdk_version]}"
  else
    sdk = "iphonesimulator"
  end
  out_file = output_file("mopub_#{options[:target].downcase}_#{sdk}")
  system_or_exit(%Q[xcodebuild -project #{project}.xcodeproj -target #{target} -configuration #{configuration} ARCHS=i386 -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], {}, out_file)
end

def available_sdk_versions
  available = []
  `xcodebuild -showsdks | grep simulator`.split("\n").each do |line|
    match = line.match(/simulator([\d\.]+)/)
    available << match[1] if match
  end
  available
end

desc "Build MoPubSDK on all SDKs
 then run tests"
task :default => [:trim_whitespace, :mopubsdk, :mopubsample]
task :mopubsdk => ["mopubsdk:build", "mopubsdk:spec"]
task :mopubsample => ["mopubsample:build", "mopubsample:spec"]
task :cruise => ["all:clean", "all:spec"]

task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[mh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

namespace :mopubsdk do
  desc "Build MoPub SDK against all available SDK versions"
  task :build do
    available_sdk_versions.each do |sdk_version|
      head "Building MoPubSDK for #{sdk_version}"
      build project: "MoPubSDK", target: "MoPubSDK", sdk_version: sdk_version
    end
  end

  desc "Run MoPubSDK Cedar Specs"
  task :spec do
    head "Building Specs"
    build project: "MoPubSDK", target: "Specs"

    head "Running Specs"
    env_vars = {
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1"
    }
    system_or_exit(%Q[./Scripts/waxsim #{File.join(build_dir("-iphonesimulator"), "Specs.app")} -f iphone -e CEDAR_REPORTER_CLASS=CDRColorizedReporter -e CFFIXED_USER_HOME=#{Dir.tmpdir} -e CEDAR_HEADLESS_SPECS=1 -s #{SDK_VERSION}], env_vars)
  end

  task :clean do
    system_or_exit(%Q[xcodebuild -project MoPubSDK.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("mopub_clean"))
  end
end

namespace :mopubsample do
  desc "Build MoPub Sample App"
  task :build do
    head "Building MoPub Sample App"
    build project: "MoPubSampleApp", target: "MoPubSampleApp"
  end

  desc "Run MoPub Sample App Cedar Specs"
  task :spec do
    head "Building Specs"
    build project: "MoPubSampleApp", target: "SampleAppSpecs"

    head "Running Specs"
    env_vars = {
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1"
    }
    system_or_exit(%Q[./Scripts/waxsim #{File.join(build_dir("-iphonesimulator"), "SampleAppSpecs.app")} -f iphone -e CEDAR_REPORTER_CLASS=CDRColorizedReporter -e CFFIXED_USER_HOME=#{Dir.tmpdir} -e CEDAR_HEADLESS_SPECS=1 -s #{SDK_VERSION}], env_vars)
  end

  task :clean do
    system_or_exit(%Q[xcodebuild -project MoPubSampleApp.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("mopub_clean"))
  end
end


namespace :all do
  desc "Run all Specs"
  task :spec => ["mopub:spec"]

  desc "Clean all Temporary Files"
  task :clean => ["mopub:clean"]
end

