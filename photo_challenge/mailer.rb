# This will read inputs from three yaml files (adjectives.yaml,
# challengers.yaml and .secrets.yaml) and manipulate that data
# to randomly select four adjectives and compose an email to be
# sent out to a list of participants. You will need to create a
# .secrets.yaml file as this is in the .gitignore file since it
# contains sensitive data.
#
# example:
# mail_data:
#   'username': 'foo'
#   'password': 'bar'
#
# Every randomy selected adjective is removed from the predetermined
# list after it has been used. This will ensure no duplicates are
# being sent.
#
require 'mail'
require 'yaml'
require 'fileutils'
require 'tempfile'

# Reading in values from YAML data files
adjective_list  = YAML::load_file('adjectives.yaml')
challengers     = YAML::load_file('challengers.yaml')
secrets         = YAML::load_file('.secrets.yaml')
mail_data       = secrets['mail_data']

# Finding the total number of adjectives in the array
adjective_total = adjective_list.count

# Randomizing an object selection from the array
randomize  = Random.new
object_num = []
4.times {
  object_num << randomize.rand(0...adjective_total)
}

challenge_words = []
object_num.each do |object|
  challenge_words << adjective_list[object]
end

# Defining the current month for the challenge
month = Date::MONTHNAMES[Date.today.month]

# Defining theoptions for the mailer
mail_options = {
  :address              => 'smtp.gmail.com',
  :port                 => 587,
  :user_name            => mail_data['username'],
  :password             => mail_data['password'],
  :authentication       => mail_data['authentication'],
}

Mail.defaults do
  delivery_method :smtp, mail_options
end

challengers.each do |challenger|
  Mail.deliver do
    to challenger
    from 'cpisano86@gmail.com'
    subject "Weekly Photo Challenge Words for #{month}"
    body "The photo challenge words for this month are:\n #{challenge_words.join("\n")}"
  end
end

# Removing used challenge adjectives from adjectives.yaml
challenge_words.each do |word|
  tmp = Tempfile.new('extract')
  open('adjectives.yaml', 'r').each { |l| tmp << l unless l.chomp == "- '#{word}'" }
  tmp.close
  FileUtils.mv(tmp.path, 'adjectives.yaml')
end
