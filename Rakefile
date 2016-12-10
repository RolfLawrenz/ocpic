# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc "Take a dump of Pi Card to PC"
task :dump_pi_card do
  system "sudo dd if=/dev/disk2 of=pi.img bs=1m"
end

desc "Restore image to Pi Card"
task :restore_pi_card do
  system "sudo dd bs=1M if=pi.img of=/dev/disk2"
end
