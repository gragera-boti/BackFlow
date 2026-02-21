#!/usr/bin/env ruby

# Generate UUIDs in Xcode's format
def generate_uuid
  `uuidgen`.strip.gsub('-', '')[0..23].upcase
end

# Files to add
new_files = {
  'GoalAndScheduleViewModel.swift' => 'BackFlow/Views/Onboarding/GoalAndScheduleViewModel.swift',
  'BaselineAssessmentViewModel.swift' => 'BackFlow/Views/Onboarding/BaselineAssessmentViewModel.swift',
  'GoalToggle.swift' => 'BackFlow/Views/Onboarding/Components/GoalToggle.swift',
  'EquipmentToggle.swift' => 'BackFlow/Views/Onboarding/Components/EquipmentToggle.swift',
  'RedFlagQuestion.swift' => 'BackFlow/Views/Onboarding/Components/RedFlagQuestion.swift',
  'ReminderSettings.swift' => 'BackFlow/Views/Onboarding/Components/ReminderSettings.swift',
  'SessionsPerWeekPicker.swift' => 'BackFlow/Views/Onboarding/Components/SessionsPerWeekPicker.swift',
  'PainSlider.swift' => 'BackFlow/Views/Onboarding/Components/PainSlider.swift',
  'FunctionTaskRow.swift' => 'BackFlow/Views/Onboarding/Components/FunctionTaskRow.swift',
  'WalkingBaselinePicker.swift' => 'BackFlow/Views/Onboarding/Components/WalkingBaselinePicker.swift'
}

puts "Files to add:"
new_files.each do |name, path|
  file_ref_id = generate_uuid
  build_file_id = generate_uuid
  puts "  #{name}: FileRef=#{file_ref_id}, BuildFile=#{build_file_id}"
  puts "    Path: #{path}"
end

puts "\nGenerate these entries and add them to project.pbxproj"
