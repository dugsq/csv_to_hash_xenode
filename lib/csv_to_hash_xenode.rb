# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# Version 0.1.0
#
# CSV-to-Hash Xenode expects from its input message data a string containing comma separated values with row 
# and column delimiters, parses the string and converts the string into a hash. The Xenode then passes an array of
# hashes to its children. The row and column delimiters can be pre-defined by the user in the Configuration File.
#
# Configuration File Options:
#   loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
#   enabled: determines if the Xenode process is allowed to run. Expects true/false.
#   debug: enables extra debug messages in the log file. Expects true/false.
#   row_delim: specifies the row delimiter for parsing of the CSV file. Expects a string.
#   col_delim: specifies the column delimiter for parsing of the CSV file. Expects a string.
#
# Example Configuration File:###
#   enabled: true
#   loop_delay: 30
#   debug: false
#   row_delim: "\n"
#   col_delim: ","
#
# Example Input:
#   msg.data: "From_User,Tweet_Content\ncmscrawler,http://t.co/8RxECaPlvD: Change from WordPress to Drupal. The site is hosted in The United States http://t.co/8RxECaPlvD #cms"
#
# Example Output:
#   msg.data:  [{"From_User"=>"cmscrawler", "Tweet_Content"=>"http://t.co/8RxECaPlvD: Change from WordPress to Drupal. The site is hosted in The United States http://t.co/8RxECaPlvD #cms"}]
#

class CsvToHashNode
  include XenoCore::XenodeBase
  
  def startup()
    # set defaults @has_header is always true
    # as message data is expected to be comma separated values with the first row
    
    # designating the headers
    @has_header = true
    
    # row delimeter defaults to newline "\n"
    @row_delim = @config.fetch(:row_delim, true)
    
    # field or column delimeter defaults to a comma
    @col_delim = @config.fetch(:col_delim, true)

  end
  
  # Processes incoming messages provided by the runtime.
  #
  # == Parameters: 
  # format::
  #   A XenoCore::Message object
  # msg.data is expected to be a set Comma Separated Values (CSV)
  # row delimited by @row_delim and column delimited by @col_delim
  # whos values are defaulted to newline ("\n") and comma (",") repectivley.
  # == Returns:
  # none.
  #
  def process_message(msg)
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    begin
      if msg
        do_debug("#{mctx} - got message: #{msg.inspect}", true)
        if msg.context 
          @row_delim = msg.context[:row_delim] if msg.context[:row_delim]
          @col_delim = msg.context[:col_delim] if msg.context[:col_delim]
        end
        data = parse_csv(msg.data)
        if data && data.length > 0
          msg.data = data
          do_debug("#{mctx} - write_to_children called with: #{msg.inspect}", true)
          write_to_children(msg)
        else
   #       do_debug("#{mctx} - writing failed message. @has_header: #{@has_header.inspect} msg: #{msg.inspect}", true)
        end
      end
    rescue Exception => e
      @log.error("#{mctx} - #{e.inspect} #{e.backtrace}")
    end
  end
  
  def parse_csv(data)
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    ret_val = []
    header = []
    if data
      
      # do_debug is implemented in xenode_base
      do_debug("#{mctx} - data: #{data.inspect}")
      
      data.force_encoding(Encoding::UTF_8).split(@row_delim).each do |line|
        line.chomp!
        do_debug("#{mctx} - line: #{line.inspect}", true)
        if @has_header
          header = line.split(@col_delim)
          @has_header = false
        else
          if header.is_a?(Array) && header.length > 0
            cols = line.split(@col_delim)
            tmp_hash = {}
            cols.each_index do |index|
              key = header[index].downcase.to_sym
              tmp_hash[key] = cols[index]
            end
            ret_val << tmp_hash
          end
        end
      end
    end
    ret_val
  end
  
end
