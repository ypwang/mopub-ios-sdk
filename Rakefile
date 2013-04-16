require 'tmpdir'
require 'pp'
require 'fileutils'
require './Scripts/screen_recorder'
require './Scripts/network_testing'

CONFIGURATION = "Debug"
SDK_VERSION = "6.1"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")

def head(text)
  puts "\n########### #{text} ###########"
end

def reset_simulator
  `osascript ./Scripts/reset_simulator.as`
end

def clean!
  `rm -rf #{BUILD_DIR}`
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def output_file(target)
  output_dir = File.join(File.dirname(__FILE__), "build")
  FileUtils.mkdir_p(output_dir)
  File.join(output_dir, "#{target}.output")
end

def system_or_exit(cmd, outfile = nil)
  cmd += " > #{outfile}" if outfile
  puts "Executing #{cmd}"

  system(cmd) or begin
    puts "******** Build Failed ********"
    puts "To review:\ncat #{outfile}" if outfile
    exit(1)
  end
end

def build(options)
  clean!
  target = options[:target]
  project = options[:project]
  configuration = options[:configuration] || CONFIGURATION
  if options[:sdk]
    sdk = options[:sdk]
  elsif options[:sdk_version]
    sdk = "iphonesimulator#{options[:sdk_version]}"
  else
    sdk = "iphonesimulator#{SDK_VERSION}"
  end
  out_file = output_file("mopub_#{options[:target].downcase}_#{sdk}")
  system_or_exit(%Q[xcodebuild -project #{project}.xcodeproj -target #{target} -configuration #{configuration} ARCHS=i386 -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], out_file)
end

def run_in_simulator(options)
  reset_simulator

  app_name = "#{options[:target]}.app"
  app_location = "#{File.join(build_dir("-iphonesimulator"), app_name)}"
  platform = options[:platform] || 'iphone'
  sdk = options[:sdk] || SDK_VERSION
  out_file = output_file("#{options[:project]}_#{options[:target]}_#{platform}_#{sdk}")
  success_condition = options[:success_condition]
  record_video = options[:record_video]

  cmd = %Q[script -q #{out_file} ./Scripts/waxsim #{app_location} -f #{platform} -s #{sdk}]

  screen_recorder = ScreenRecorder.new(File.absolute_path("./Scripts"))
  screen_recorder.start_recording if record_video

  run_with_environment(options[:environment]) do
    puts "Executing #{cmd}"
    system(cmd)
  end

  system("grep -q \"#{success_condition}\" #{out_file}") or begin
    puts "******** Simulator Run Failed ********"

    if record_video
      video_path = screen_recorder.save_recording
      puts "Saved video. On Jenkins: http://192.168.1.33:8080/job/MoPubIOSSDKIntegrations/ws/Scripts/#{video_path}"
    end

    exit(1)
  end

  screen_recorder.stop_recording if record_video
  return out_file
end

def run_with_environment(env)
  env = env || {}
  old_env = {}
  env.each do |key, value|
    old_env[key] = ENV[key]
    ENV[key] = value
  end

  yield

  env.each do |key, value|
    ENV[key] = old_env[key]
  end
end

def available_sdk_versions
  available = []
  `xcodebuild -showsdks | grep simulator`.split("\n").each do |line|
    match = line.match(/simulator([\d\.]+)/)
    available << match[1] if match
  end
  available
end

def cedar_env
  {
    "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
    "CFFIXED_USER_HOME" => Dir.tmpdir,
    "CEDAR_HEADLESS_SPECS" => "1"
  }
end

desc "Build MoPubSDK on all SDKs
 then run tests"
task :default => [:fix_copyright, :trim_whitespace, "mopubsdk:build", "mopubsdk:spec", "mopubsample:build", "mopubsample:spec", "mopubsample:kif"]

desc "Build MoPubSDK on all SDKs and run all unit tests"
task :unit_specs => ["mopubsdk:build", "mopubsample:build", "mopubsdk:spec", "mopubsample:spec"]

desc "Run KIF integration tests (skip flaky tests)"
task :integration_specs => ["mopubsample:bump_server", "mopubsample:kif"]

desc "Run All KIF integration tests (including flaky tests)"
task :flaky_integration_specs do
  Rake.application.invoke_task("mopubsample:kif['flaky']")
end

desc "Trim Whitespace"
task :trim_whitespace do
  head "Trimming Whitespace"

  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") for (i=2; i<=NF; i++) printf("%s%s", $i, i<NF ? " " : ""); print ""}' | grep -e '.*.[mh]"*$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

desc "Fix Up Copyright"
task :fix_copyright do
  head "Fixing Copyright"

  `find . -name "*.[mh]" -print0 | xargs -0 grep -l "Created by pivotal" | xargs sed -i '' 's/\\/\\/  MoPubSampleApp/\\/\\/  MoPub/g'`
  `find . -name "*.[mh]" -print0 | xargs -0 grep -l "Created by pivotal" | xargs sed -i '' 's/\\/\\/  MoPubSDK/\\/\\/  MoPub/g'`
  `find . -name "*.[mh]" -print0 | xargs -0 grep -l "Created by pivotal" | xargs sed -i '' '/\\/\\/  Created by pivotal/d'`
end

desc "Upload Third Party Integrations to CI"
task :upload_third_party_integrations do
  `scp -r ./Externals/ThirdPartyNetworks pivotal@192.168.1.33:/Users/pivotal/workspace/ThirdPartyNetworks`
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
    run_in_simulator(project: "MoPubSDK", target: "Specs", environment: cedar_env, success_condition: ", 0 failures")
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
    head "Building Sample App Cedar Specs"
    build project: "MoPubSampleApp", target: "SampleAppSpecs"

    head "Running Sample App Cedar Specs"
    run_in_simulator(project: "MoPubSampleApp", target: "SampleAppSpecs", environment: cedar_env, success_condition: ", 0 failures")
  end

  desc "Run MoPub Sample App Integration Specs"
  task :kif, :flaky do |t, args|
    head "Building KIF Integration Suite"
    build project: "MoPubSampleApp", target: "SampleAppKIF"
    head "Running KIF Integration Suite"

    environment = { }
    environment["KIF_FLAKY_TESTS"] = '1' if args.flaky == 'flaky'

    network_testing = NetworkTesting.new

    kif_log_file = nil
    network_testing.run_with_proxy do
      kif_log_file = run_in_simulator(project: "MoPubSampleApp", target: "SampleAppKIF", environment:environment, success_condition: "TESTING FINISHED: 0 failures", record_video: ENV['IS_CI_BOX'])
    end

    network_testing.verify_kif_log_lines(File.readlines(kif_log_file))
  end

  desc "Bump Server Ad Units"
  task :bump_server do
    head "Bumping Server Ad Units"
    system("./Scripts/bump_server.rb")
  end
end

desc "Copy and Verify code into the mopub client repo"
task :mopub_client => ["mopub_client:copy", "mopub_client:verify"]

namespace :mopub_client do
  desc "Copy SDK to Public/Private repo"
  task :copy do
    head "Copying SDK to Public/Private repo"
    path_to_development_sdk = File.absolute_path(File.join(File.dirname(__FILE__), 'MoPubSDK'))
    path_to_repo_sdk = File.absolute_path(File.join(File.dirname(__FILE__), '../mopub-client/MoPubiOS/MoPubSDK'))
    `rm -rf #{path_to_repo_sdk}`
    `cp -r #{path_to_development_sdk} #{path_to_repo_sdk}`

    path_to_development_3rd = File.absolute_path(File.join(File.dirname(__FILE__), 'ThirdPartyIntegrations'))
    path_to_repo_3rd = File.absolute_path(File.join(File.dirname(__FILE__), '../mopub-client/MoPubiOS/extras'))
    `rm -rf #{path_to_repo_3rd}`
    `cp -r #{path_to_development_3rd} #{path_to_repo_3rd}`
  end

  desc "Verify that the SimpleAds demo compiles"
  task :verify do
    project = File.absolute_path(File.join(File.dirname(__FILE__),'..','mopub-client', 'MoPubiOS', 'SimpleAdsDemo', 'SimpleAds'))
    build(project: project, target: 'MoPub')
  end
end


at_exit do
  if ENV['IS_CI_BOX']
    `osascript -e "tell application \\"Safari\\" to activate"`
  end
end
