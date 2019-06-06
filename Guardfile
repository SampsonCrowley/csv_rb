# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2 do
  watch(%r{spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')                  { "spec" }
  watch(%r{spec/support/.+\.rb$})               { "spec" }

  watch(%r{spec/dummy/app/(.+)\.rb$})           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{spec/dummy/app/(.*)(\.erb|\.haml)$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{spec/dummy/app/controllers/.+\.rb$}) { ["spec/csvrb_renderer_spec.rb", "spec/csvrb_builder_spec.rb", "csvrb_request_spec.rb"] }
  watch('lib/csv_rb/action_controller.rb') { ["spec/csvrb_renderer_spec.rb", "spec/csvrb_request_spec.rb"] }
  watch('lib/csv_rb/template_handler.rb')  { "spec/csvrb_builder_spec.rb" }
  watch(%r{spec/dummy/app/mailers/.+\.rb$}) { "spec/csvrb_mailer_spec.rb" }
  watch(%r{spec/dummy/app/views/.+\.erb})       { "spec/csvrb_request_spec.rb" }
end
