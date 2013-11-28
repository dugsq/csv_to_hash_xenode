csv-to-hash-xenode
==================

**CSV-to-Hash Xenode** expects from its input message data a string containing comma separated values with row and column delimiters, parses the string and converts the string into a hash. The Xenode then passes an array of hashes to its children. The row and column delimiters can be pre-defined by the user in the Configuration File.

###Configuration File Options:###
* loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
* enabled: determines if the Xenode process is allowed to run. Expects true/false.
* debug: enables extra debug messages in the log file. Expects true/false.
* row_delim: specifies the row delimiter for parsing of the CSV file. Expects a string.
* col_delim: specifies the column delimiter for parsing of the CSV file. Expects a string.

###Example Configuration File:###
* enabled: false
* loop_delay: 30
* debug: false
* row_delim: "\n"
* col_delim: ","

###Example Input:###
* msg.data: "From_User,Tweet_Content\ncmscrawler,http://t.co/8RxECaPlvD: Change from WordPress to Drupal. The site is hosted in The United States http://t.co/8RxECaPlvD #cms"

###Example Output:###
* msg.data:  [{"From_User"=>"cmscrawler", "Tweet_Content"=>"http://t.co/8RxECaPlvD: Change from WordPress to Drupal. The site is hosted in The United States http://t.co/8RxECaPlvD #cms"}]
