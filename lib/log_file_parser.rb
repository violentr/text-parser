#!/usr/bin/env ruby

require './lib/populate_db'

class LogFileParser
  attr_reader :file

  DEFAULT_FILE = Rails.root.join('lib', 'votes.txt')

  def initialize(file)
    file_path = ARGV.first || DEFAULT_FILE
    @file = File.open(file_path)
    @campaigns = {"Campaign" => {}}
    @errors = {errors: 0}
  end

  def parse
    file.readlines.each do |line|
      line = validate(line)
      next unless policy_matched(line)
      record = current_record_from(line)
      if @campaigns["Campaign"].has_key?(record.Campaign)
        allready_voted_for(record)
      else
        start_to_vote(record)
      end
    end
    @campaigns
  end

  def populate_db
    ::PopulateDb.start(@campaigns)
  end

  def policy_matched(string)
     if string.match(/^VOTE/) && string.match(/Validity:during/)
       return string
     else
       increase_error_count
       false
     end
  end

  def current_record_from(string)
    text = string.split(/ /)
    output = text.each_with_object([]) do |i, array|
      array << i.split(/:/) if i.match(/:/)
    end
    ::OpenStruct.new(output.to_h)
  end

  def allready_voted_for(record)
    choice = @campaigns.dig("Campaign", record.Campaign, "Choice")
    if choice.has_key?(record.Choice) && record.Choice
      @campaigns["Campaign"][record.Campaign]["Choice"][record.Choice] += 1
    else
      @campaigns["Campaign"][record.Campaign]["Choice"].merge!({record.Choice => 1 })
    end
  end

  def start_to_vote(record)
    if record.Choice
      @campaigns["Campaign"].merge!({record.Campaign => {"Choice" => {}} })
      @campaigns["Campaign"][record.Campaign]["Choice"][record.Choice] = 1
    else
      increase_error_count
      return {}
    end
  end

  def increase_error_count
    @errors[:errors] += 1
  end

  private

  def validate(string)
    if string.valid_encoding?
      return string
    else
      line = string.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      line.gsub(/dr/i,'med')
    end
    line
  end

end

logfile_parser = LogFileParser.new(ARGV.first)
logfile_parser.parse
logfile_parser.populate_db
