module SWFHelper

  $LOAD_PATH << './../../../lib'
  require 'config_path'

  def set_up

    raise "\n\nPlese indicate an ARGV[0] for which environment.\n"+
    "For example, dev or prd\n\n".red unless ARGV[0]

    raise "\n\nPlese indicate an ARGV[1] for past X hours.\n"+
    "For example, 1 or 24\n\n".red unless ARGV[1]

    ConfigPath.config_path = File.dirname(__FILE__) + "/../config/odin.yml"
    config = ConfigPath.new.options

    access_key_id = config['id']
    secret_access_key = config['secret']

    AWS.config({
      :access_key_id => access_key_id,
      :secret_access_key => secret_access_key,
      :region => 'us-west-1'
    })

    @hours = ARGV[1].to_i
    @timeframe = Time.now.to_i - 60*60*@hours
    @domain = config['domain']
    @swf = AWS::SimpleWorkflow::Client.new

    workflow_types = @swf.list_workflow_types :domain => @domain, :registration_status => 'REGISTERED'
    if workflow_types.data['typeInfos'].count > 1 || workflow_types.data['typeInfos'][0]['workflowType']['name'] != 'article-ingestion'
      puts "\nWARNING: A new workflow type has been introduced. You may need to update this script:".red
      puts "#{workflow_types.data}".red
    end
  end

  def get_count_closed_workflows
    closed_workflow_counts = []
    response = @swf.count_closed_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}
    response.data['status'] = "Total"
    closed_workflow_counts << response.data

    %w(COMPLETED FAILED CANCELED TERMINATED CONTINUED_AS_NEW TIMED_OUT).each do |status|
      response = @swf.count_closed_workflow_executions({:domain => @domain, 
        :start_time_filter => {:oldest_date => @timeframe},
        :close_status_filter=>{:status=>status}})
      response.data['status'] = status.capitalize
      closed_workflow_counts << response.data
    end
    closed_workflow_counts
  end

  def get_count_open_workflow_executions
    response = @swf.count_open_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}
    response.data
  end

  def get_pending_workflow_executions
    tasks = []
    pending_tasks = {:activities => 0, :decisions => 0}
    activity_types = @swf.list_activity_types :domain => @domain, :registration_status => 'REGISTERED'
    activity_types.data['typeInfos'].each do |info|
      tasks << info['activityType']['name']
    end
    tasks.each do |task_list|

      opts = {:domain => @domain, :task_list => {:name => task_list}}

      response = @swf.count_pending_activity_tasks opts
      pending_tasks[:activities]+= response.data['count']

      response = @swf.count_pending_decision_tasks opts
      pending_tasks[:decisions]+= response.data['count']
    end
    pending_tasks
  end

  def debug_get_count_open_workflow_executions
    puts "\n"
    open = []
    response = @swf.list_open_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}
    response.data['executionInfos'].each do |i|
      open << i['workflowType']['name']
    end

    counts = Hash.new 0
    open.each do |i|
      counts[i] += 1
    end
    puts "Breakdown of Open Workflows".green
    puts counts

    tasks = []
    activity_types = @swf.list_activity_types :domain => @domain, :registration_status => 'REGISTERED'
    activity_types.data['typeInfos'].each do |info|
      tasks << info['activityType']['name']
    end
    tasks.each do |task_list|

      opts = {:domain => @domain, :task_list => {:name => task_list}}

      puts "Total Pending Activity Tasks for #{task_list}".green 
      response = @swf.count_pending_activity_tasks opts
      puts response.data['count']
      puts response.data['truncated'] if response.data['truncated'].to_s == 'true'

      puts "Total Pending Decision Tasks for #{task_list}".green
      response = @swf.count_pending_decision_tasks opts
      puts response.data['count']
      puts response.data['truncated'] if response.data['truncated'].to_s == 'true'
    end
  end

  def get_failure_breakdown_improved
    failed_workflows = get_failures

    failures = {}

    failed_workflows.each do |s|
      wid = s[:wid]
      rid = s[:rid]

      closed_workflow_options = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
      response = @swf.get_workflow_execution_history closed_workflow_options

      response.data['events'].each do |event|
        if event['eventType'] == 'WorkflowExecutionFailed'
          failed_details = Base64.decode64(event['workflowExecutionFailedEventAttributes']['details'])
          failed_details_cropped = failed_details.match(/errorMessage.{1,}/).to_s
          if failed_details_cropped.length > 0
            case failures[failed_details_cropped]
            when nil
              failures[failed_details_cropped] = 1
            else
              failures[failed_details_cropped]+= 1
            end
          else
            no_msg = "No 'errorMessage' string found in workflowExecutionFailedEventAttributes.details"
            case failures[no_msg]
            when nil
              failures[no_msg] = 1
            else
              failures[no_msg]+= 1
            end
          end
        end
      end
    end

    sorted = failures.sort_by {|_key, value| value}.reverse
    fail_data = ''
    sorted.each do |s|
      fail_data << s.to_s+"\n"
    end
    puts fail_data
    fail_data
  end

  def get_failure_breakdown
    failed_workflows = get_failures

    failures = []

    failed_workflows.each do |s|
      wid = s[:wid]
      rid = s[:rid]

      closed_workflow_options = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
      response = @swf.get_workflow_execution_history closed_workflow_options

      response.data['events'].each do |event|
        if event['eventType'] == 'WorkflowExecutionFailed'
          failed_details = Base64.decode64(event['workflowExecutionFailedEventAttributes']['details'])
          failed_details_cropped = failed_details.match(/errorMessage.{1,}/).to_s
          if failed_details_cropped.length > 0
            failures << failed_details_cropped
          else
            failures << "No 'errorMessage' string found in workflowExecutionFailedEventAttributes.details"
          end
        end
      end
    end

    counts = Hash.new 0
    failures.each do |i|
      counts[i] += 1
    end

    #f = '/home/wclaiborne/temp/r.txt'
    #File.open(f, 'w') { |file| file.write(counts) }
    fail_data = ''
    counts.each do |c|
      puts c
      fail_data << c.to_s+"\n"
    end
    fail_data
  end

  def get_uri_expand_failure_details
    failed_workflows = get_failures

    failed_workflows.each do |s|
      wid = s[:wid]
      rid = s[:rid]

      closed_workflow_options = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
      response = @swf.get_workflow_execution_history closed_workflow_options

      response.data['events'].each do |event|
        if event['eventType'] == 'WorkflowExecutionFailed' && Base64.decode64(event['workflowExecutionFailedEventAttributes']['details']).match(/expand to a 2xx statuscode/)
          uri_info = response.data['events'][0]['workflowExecutionStartedEventAttributes']['input']
          uri = (eval uri_info.gsub("\":\"","\"=>\""))['url']
          puts uri
        end
      end # end response.data['events'].each
    end # end failed_workflows.each do
  end # end method

  def get_encoded_stack_trace(fail_msg)
    next_page_token = nil
    failed_workflows = []
    response = @swf.list_closed_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}
    response.data['executionInfos'].each do |info|
      if info['closeStatus'] == 'FAILED'
        failed_workflow = (get_a_spcific_workflow(info['execution']['workflowId'], info['execution']['runId']))
        failed_workflow.data['events'].each do |event|
          if event['eventType'] == 'WorkflowExecutionFailed'
            if Base64.decode64(event['workflowExecutionFailedEventAttributes']['details']).match(fail_msg)
              puts Base64.decode64(event['workflowExecutionFailedEventAttributes']['details'])
              puts info['execution']['workflowId']
              puts "ENCODED: ".green
              puts event['workflowExecutionFailedEventAttributes']['details']
              return
            end
          end
        end
      end
    end
    response.data['nextPagetoken']
    next_page_token = response.data['nextPageToken']

    until next_page_token.nil? 
      response = @swf.list_closed_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}, :next_page_token => next_page_token
      response.data['executionInfos'].each do |info|
        if info['closeStatus'] == 'FAILED'
          failed_workflow = (get_a_spcific_workflow(info['execution']['workflowId'], info['execution']['runId']))
          failed_workflow.data['events'].each do |event|
            if event['eventType'] == 'WorkflowExecutionFailed'
              if Base64.decode64(event['workflowExecutionFailedEventAttributes']['details']).match(fail_msg)
                puts Base64.decode64(event['workflowExecutionFailedEventAttributes']['details']).match(/errorMessage.{1,}/).to_s
                puts info['execution']['workflowId']
                puts "ENCODED: ".green
                puts event['workflowExecutionFailedEventAttributes']['details']
                return
              end
            end
          end 
        end
      end
      next_page_token = response.data['nextPageToken']
    end # end until
  end # end method

  private

    def get_failures
      next_page_token = nil
      failed_workflows = []
      response = @swf.list_closed_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}
      response.data['executionInfos'].each do |info|
        failed_workflows << {:wid => info['execution']['workflowId'], :rid => info['execution']['runId']} if info['closeStatus'] == 'FAILED'
      end
      response.data['nextPagetoken']
      next_page_token = response.data['nextPageToken']

      until next_page_token.nil? 
        response = @swf.list_closed_workflow_executions :domain => @domain, :start_time_filter => {:oldest_date => @timeframe}, :next_page_token => next_page_token
        response.data['executionInfos'].each do |info|
          failed_workflows << {:wid => info['execution']['workflowId'], :rid => info['execution']['runId']} if info['closeStatus'] == 'FAILED'
        end
        next_page_token = response.data['nextPageToken']
      end
      failed_workflows
    end

    def get_a_spcific_workflow(wid, rid)
      opts = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
      response = @swf.get_workflow_execution_history opts
      #File.open('/Users/wclaiborne/Desktop/something.json', 'w') { |file| file.write(response.data.to_json) }
    end
  # end private methods
end
