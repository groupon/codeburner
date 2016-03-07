## What is Pipeline?
To quote the README for the <a href="https://githbu.com/OWASP/pipeline" target="_blank">OWASP pipeline</a> project... "Pipeline is a framework for running a series of tools. Generally, it is intended as a backbone for automating a security analysis pipeline of tools."

Codeburner uses pipeline to run the various scanning tools on your code and normalize the results to a common object format: the <a href="https://github.com/OWASP/pipeline/blob/master/lib/pipeline/finding.rb" target="_blank">pipeline finding</a>.

## Adding Scanners
If you want to add a new scanning tool to Codeburner, you can contribute to the pipeline project by adding a new <a href="https://github.com/OWASP/pipeline/tree/master/lib/pipeline/tasks" target="_blank">Task</a>.  You can see the existing tasks for examples, and it's generally straightforward as long as your scanning tool outputs structured data (JSON/XML/etc.).

Here's a stripped down, commented task for a generic scanner to help get you started:

```ruby
# Minimally require pipeline/tasks/base_task
require 'pipeline/tasks/base_task'
require 'pipeline/util'
require 'json'

# Give your task a useful name
class Pipeline::TaskName < Pipeline::BaseTask

  Pipeline::Tasks.add self
  include Pipeline::Util

  # Do any setup
  def initialize(trigger, tracker)
    super(trigger, tracker)
    @name = "TaskName"
    @description = "This is a description of the TaskName scanner for ruby/rails"
    @stage = :code
    @labels << "code" << "ruby" << "rails"
  end

  # Run the scanning command and create @result
  def run
    @result = JSON.parse `/some/scanner -that returns -t json`
  end

  # analyze() gets called after run().  the report() call actually creates the finding object
  def analyze
    begin
      @result["warnings"].each do |warning|
        name = warning["type"]
        detail = warning["description"]
        source = {
          :scanner => @name,
          :file => warning["file"],
          :line => warning["line"],
          :code => warning["snippet"]
        }
        sev = severity(warning["confidence"])
        fprint = fingerprint("#{name}#{detail}#{source}#{sev}")

        report name, detail, source, sev, fprint
      end
    rescue Exception => e
      Pipeline.warn e.message
      Pipeline.warn e.backtrace
    end
  end

  # Whatever test is appropriate to determine if your tool is installed
  def supported?
    unless File.exist?('/path/to/command')
      Pipeline.notify "Run: /some/command/to/install/me"
      return false
    else
      return true
    end
  end
end
```

***
