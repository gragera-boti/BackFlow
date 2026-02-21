#!/usr/bin/env ruby
require 'xcodeproj'

# Open the project
project = Xcodeproj::Project.open('BackFlow.xcodeproj')
target = project.targets.first

# Define files to add
files_to_add = [
  'BackFlow/Views/Sheets/WalkingLogSheet.swift',
  'BackFlow/Views/Detail/ExerciseDetailContainer.swift',
  'BackFlow/Views/Detail/EducationDetailContainer.swift',
  'BackFlow/Views/Session/SessionPlayerContainer.swift',
  'BackFlow/Views/Detail/ExerciseDetailViewModel.swift',
  'BackFlow/Views/Detail/EducationDetailViewModel.swift',
  'BackFlow/Views/Session/SessionPlayerViewModel.swift'
]

# Get the main group
main_group = project.main_group

# Add each file
files_to_add.each do |file_path|
  # Check if file already exists in project
  existing_ref = project.files.find { |f| f.path == file_path }
  
  if existing_ref.nil?
    # Create appropriate group structure
    path_components = file_path.split('/')
    filename = path_components.pop
    
    # Navigate/create group structure
    current_group = main_group
    path_components.each do |component|
      existing_group = current_group.children.find { |child| 
        child.is_a?(Xcodeproj::Project::Object::PBXGroup) && child.path == component
      }
      
      if existing_group
        current_group = existing_group
      else
        current_group = current_group.new_group(component, component)
      end
    end
    
    # Add file reference
    file_ref = current_group.new_reference(file_path)
    
    # Add to target's build phase
    target.source_build_phase.add_file_reference(file_ref)
    
    puts "Added: #{file_path}"
  else
    # Check if it's in the build phase
    build_file = target.source_build_phase.files.find { |bf| 
      bf.file_ref && bf.file_ref.path == file_path
    }
    
    if build_file.nil?
      target.source_build_phase.add_file_reference(existing_ref)
      puts "Added to build phase: #{file_path}"
    else
      puts "Already in project: #{file_path}"
    end
  end
end

# Save the project
project.save
puts "\nProject updated successfully!"