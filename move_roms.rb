#!/usr/env/ruby
#
# Method that allows us to search and find the absolute path for a bash command
#
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

# Variables necessary to have the script function appropriately
# Do not make any changes to the code itself, change the variable values
#
rsync          = which('rsync')
consoles       = ['nes',
                  'snes',
                  'n64',
                  'sms',
                  'ps1']
username       = 'foo'
rasberrypi     = 'bar'
local_rom_dir  = '/Users/redmand/Desktop'
remote_rom_dir = '/retropi/roms'

# The code itself that does all the work
#
# This is a for loop iterating over each object in the consoles array
consoles.each do |console|
  # The system function shells out to native bash commands
  # Everything enclosed in '#{}' is interpolating variable values from above to build a valid rsync command
  # The rsync command is transferring the local roms to the remote target
  system("#{rsync} -a #{local_rom_dir}/#{console} #{username}@#{rasberrypi}:#{remote_rom_dir}/#{console}")
end
