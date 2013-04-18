require './Scripts/private/mopub_sdk_publisher.rb'

def head(text)
  puts "\n########### #{text} ###########"
end

task :default => [:fix_copyright, :trim_whitespace, "mopubsdk:build", "mopubsdk:spec", "mopubsample:build", "mopubsample:spec", :integration_specs]

task :integration_specs => ["mopubsample:bump_server", "mopubsample:kif"]

namespace :mopubsample do
  desc "Bump Server Ad Units"
  task :bump_server do
    head "Bumping Server Ad Units"
    system("./Scripts/private/bump_server.rb")
  end
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
  `scp -r ./Externals/NetworkSDKs pivotal@192.168.1.33:/Users/pivotal/workspace/NetworkSDKs`
end

desc "Publish the SDK to the public iOS repository"
task :publish do
  head "Publishing SDK"
  publisher = MoPubSDKPublisher.new
  publisher.publish!
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

    path_to_development_3rd = File.absolute_path(File.join(File.dirname(__FILE__), 'MoPubSDKNetworkSupport'))
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