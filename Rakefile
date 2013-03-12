require 'tmpdir'

CONFIGURATION = "Release"
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

task :default => [:trim_whitespace, "all:spec"]
task :cruise => ["all:clean", "all:spec"]

task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[mh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

namespace :mopub do
  desc "Run MoPub Cedar Specs"
  task :spec do
    system_or_exit(%Q[xcodebuild -project MoPubSDK.xcodeproj -target Specs -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("mopub_specs"))

    env_vars = {
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1"
    }
    system_or_exit(%Q[./Scripts/waxsim #{File.join(build_dir("-iphonesimulator"), "Specs.app")} -f iphone -e CEDAR_REPORTER_CLASS=CDRColorizedReporter -e CFFIXED_USER_HOME=#{Dir.tmpdir} -e CEDAR_HEADLESS_SPECS=1 -s #{SDK_VERSION}], env_vars)
  end

  task :clean do
    system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("mopub_clean"))
  end

end

namespace :all do
  desc "Run all Specs"
  task :spec => ["mopub:spec"]

  desc "Clean all Temporary Files"
  task :clean => ["mopub:clean"]
end

