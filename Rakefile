require 'tmpdir'
require 'pp'

CONFIGURATION = "Debug"
SDK_VERSION = "6.1"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")
SCRIPTS_DIR = File.join(File.dirname(__FILE__), "Scripts")

def xcode_developer_dir
  `xcode-select -print-path`.strip
end

def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def output_file(target)
  output_dir = File.join(File.dirname(__FILE__), "build")
  Dir.mkdir(output_dir) unless File.exists?(output_dir)
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
    sdk = "iphonesimulator#{SDK_VERSION}"
  end
  out_file = output_file("mopub_#{options[:target].downcase}_#{sdk}")
  system_or_exit(%Q[xcodebuild -project #{project}.xcodeproj -target #{target} -configuration #{configuration} ARCHS=i386 -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], {}, out_file)
end

def system_or_exit(cmd, env_overrides = {}, stdout = nil)
  cmd += " > #{stdout}" if stdout
  puts "Executing #{cmd}"

  with_environment(env_overrides) do
    system(cmd) or begin
      puts "******** Build failed ********"
      if stdout
        puts "To review:"
        puts "cat #{stdout}"
      end
      exit(1)
    end
  end
end

def run_in_simulator(options)
  `osascript -e 'tell application "iPhone Simulator" to quit'`

  app_name = "#{options[:target]}.app"
  app_location = "#{File.join(build_dir("-iphonesimulator"), app_name)}"
  platform = options[:platform] || 'iphone'
  sdk = options[:sdk] || SDK_VERSION
  out_file = output_file("#{options[:project]}_#{options[:target]}_#{platform}_#{sdk}")

  cmd = %Q[script -q #{out_file} ./Scripts/waxsim #{app_location} -f #{platform} -s #{sdk}]

  with_environment(options[:environment]) do
    system(cmd)
  end

  success_condition = options[:success_condition]
  system("grep -q \"#{success_condition}\" #{out_file}") or begin
      puts "******** Build failed ********"
      exit(1)
  end
  return out_file
end

def with_environment(env)
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
task :default => [:trim_whitespace, "mopubsdk:build", "mopubsdk:spec", "mopubsample:build", "mopubsample:spec", "mopubsample:kif"]

desc "Build MoPubSDK on all SDKs and run all unit tests"
task :unit_specs => ["mopubsdk:build", "mopubsample:build", "mopubsdk:spec", "mopubsample:spec"]

desc "Run KIF integration tests (skip flaky tests)"
task :integration_specs => ["mopubsample:kif"]

desc "Run All KIF integration tests (including flaky tests)"
task :flaky_integration_specs do
  Rake.application.invoke_task("mopubsample:kif['flaky']")
end

desc "Trim Whitespace"
task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") for (i=2; i<=NF; i++) printf("%s%s", $i, i<NF ? " " : ""); print ""}' | grep -e '.*.[mh]"*$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

desc "Fix Up Copyright"
task :fix_copyright do
  `find . -name "*.[mh]" -exec sed -i '' 's/\\/\\/  MoPubSampleApp/\\/\\/  MoPub/g' {} \\;`
  `find . -name "*.[mh]" -exec sed -i '' 's/\\/\\/  MoPubSDK/\\/\\/  MoPub/g' {} \\;`
  `find . -name "*.[mh]" -exec sed -i '' '/\\/\\/  Created by pivotal/d' {} \\;`
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

  task :clean do
    system_or_exit(%Q[xcodebuild -project MoPubSDK.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("mopub_clean"))
  end
end

def run_with_proxy
  pid = fork do
    exec "#{SCRIPTS_DIR}/proxy.rb Wi-Fi"
  end

  begin
    yield
  rescue SystemExit => e
    exit(1)
  ensure
    Process.kill 'INT', pid
    Process.wait pid
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
    environment["KIF_FLAKY_TESTS"] = '1' if args.flaky

    kif_log_file = nil
    run_with_proxy do
      kif_log_file = run_in_simulator(project: "MoPubSampleApp", target: "SampleAppKIF", environment:environment, success_condition: "TESTING FINISHED: 0 failures")
    end

    head "Verifying KIF Impressions"
    verify_impressions(File.readlines("#{SCRIPTS_DIR}/proxy.log"), File.readlines(kif_log_file))

    head "Verifying KIF Clicks"
    verify_clicks(File.readlines("#{SCRIPTS_DIR}/proxy.log"), File.readlines(kif_log_file))
  end

  task :clean do
    system_or_exit(%Q[xcodebuild -project MoPubSampleApp.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], {}, output_file("mopub_clean"))
  end

  task :bump_server do
    head "Bumping Server Ad Units"
    system("./Scripts/bump_server.rb")
  end
end

def ids_matching_matcher(lines, matcher)
  ids = []
  lines.each do |line|
    match = matcher.match(line)
    ids << match[1] if match
  end
  ids
end

def verify_match(kif_ad_ids, proxy_ad_ids, kind)
  if kif_ad_ids == proxy_ad_ids
    puts "******** KIF TEST #{kind} SUCCEEDED (#{proxy_ad_ids.length}/#{kif_ad_ids.length}) ********"
  else
    puts "******** KIF TEST #{kind} FAILED ********"
    puts "Expected                         Received"
    count = [proxy_ad_ids.length, kif_ad_ids.length].max
    (0...count).each do |i|
      puts "#{kif_ad_ids[i]} #{proxy_ad_ids[i]}"
    end

    exit(1)
  end
end

def verify_impressions(proxy_lines, kif_lines)
  kif_ad_ids = ids_matching_matcher(kif_lines, /~~~ EXPECT IMPRESSION FOR AD UNIT ID: ([A-Za-z0-9_\-]+)/)
  proxy_ad_ids = ids_matching_matcher(proxy_lines, /http:\/\/ads.mopub.com\/m\/imp\?.*&id=([A-Za-z0-9_\-]+)&/)
  verify_match(kif_ad_ids, proxy_ad_ids, "IMPRESSIONS")
end

def verify_clicks(proxy_lines, kif_lines)
  kif_ad_ids = ids_matching_matcher(kif_lines, /~~~ EXPECT CLICK FOR AD UNIT ID: ([A-Za-z0-9_\-]+)/)
  proxy_ad_ids = ids_matching_matcher(proxy_lines, /http:\/\/ads.mopub.com\/m\/aclk\?.*&id=([A-Za-z0-9_\-]+)&/)
  verify_match(kif_ad_ids, proxy_ad_ids, "CLICKS")
end

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

at_exit do
  if ENV['IS_CI_BOX']
    `osascript -e "tell application \\"Safari\\" to activate"`
  end
end
