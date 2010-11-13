#TODO: review when multi zombie hooks are available
module BeEF
module Modules
module Commands

class Raw_javascript < BeEF::Command
  
  def initialize
    super({
      'Name' => 'Raw Javascript',
      'Description' => %Q{ 
        This module will send the code entered in the 'JavaScript Code' section to the selected 
        zombie browsers where it will be executed. Code is run inside an anonymous function and the return 
        value is passed to the framework. Multiline scripts are allowed, no special encoding is required.
        },
      'Category' => 'Misc',
      'Author' => ['wade','vo'],
      'Data' =>
        [
          ['name' => 'cmd', 'ui_label' => 'Javascript Code', 
           'value' => "alert(\'BeEF Raw Javascript\');\nreturn \'It worked!\';", 
           'type' => 'textarea', 'width' => '400px', 'height' => '100px'],
        ],
      'File' => __FILE__  ,
        'Target' => {
          'browser_name' =>     BeEF::Constants::Browsers::ALL
        }
    })
    
    use_template!
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def callback
    
    save({'result' => @datastore['result']})
  end
  
end


end
end
end