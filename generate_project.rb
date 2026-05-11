require 'xcodeproj'

project_name = 'MyVoiceRecording'
project_path = "#{project_name}.xcodeproj"
project = Xcodeproj::Project.new(project_path)

# Add App Target
app_target = project.new_target(:application, project_name, :ios, '16.0')
app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.example.#{project_name}"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['INFOPLIST_KEY_NSMicrophoneUsageDescription'] = 'We need access to the microphone to record audio.'
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'My Voice Records'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
end

# Add Test Target
test_target = project.new_target(:unit_test_bundle, "#{project_name}Tests", :ios, '16.0')
test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.example.#{project_name}Tests"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/#{project_name}.app/#{project_name}"
  config.build_settings['BUNDLE_LOADER'] = "$(TEST_HOST)"
end

# Create Groups
group = project.main_group.new_group(project_name, project_name)
tests_group = project.main_group.new_group("#{project_name}Tests", "#{project_name}Tests")

# Function to add files to a target
def add_files_to_target(project, target, current_group, current_dir)
  Dir.foreach(current_dir) do |item|
    next if item.start_with?('.')
    
    path = File.join(current_dir, item)
    if File.directory?(path)
      if item.end_with?('.xcassets')
        file_ref = current_group.new_reference(item)
        target.add_file_references([file_ref])
      else
        new_group = current_group.groups.find { |g| g.name == item } || current_group.new_group(item, item)
        add_files_to_target(project, target, new_group, path)
      end
    elsif File.file?(path) && item.end_with?('.swift')
      file_ref = current_group.new_reference(item)
      target.add_file_references([file_ref])
    end
  end
end

add_files_to_target(project, app_target, group, project_name)

project.save
