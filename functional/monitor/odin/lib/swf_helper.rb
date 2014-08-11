module SWFHelper

  $LOAD_PATH << './../../../lib'
  require 'config_path'

  def set_up

    raise "\n\nPlese indicate an ARGV[0] for which environment.\n"+
    "For example, dev or prd\n\n" unless ARGV[0]

    raise "\n\nPlese indicate an ARGV[1] for past X hours.\n"+
    "For example, 1 or 24\n\n" unless ARGV[1]

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
    puts "DEBUG: Breakdown of Open Workflows".yellow
    puts counts

    # Call this if debug_get_count_open_workflow_executions returns a lot of stuff that you need to see a breakdown of
    tasks = []
    activity_types = @swf.list_activity_types :domain => @domain, :registration_status => 'REGISTERED'
    activity_types.data['typeInfos'].each do |info|
      tasks << info['activityType']['name']
    end
    tasks.each do |task_list|

      opts = {:domain => @domain, :task_list => {:name => task_list}}

      puts "DEBUG: Total Pending Activity Tasks for #{task_list}".yellow 
      response = @swf.count_pending_activity_tasks opts
      puts response.data

      puts "DEBUG: Total Pending Decision Tasks for #{task_list}".yellow
      response = @swf.count_pending_decision_tasks opts
      puts response.data
    end
  end

  def get_failure_breakdown
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

    failures = []

    failed_workflows.each do |s|
      wid = s[:wid]
      rid = s[:rid]

      closed_workflow_options = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
      response = @swf.get_workflow_execution_history closed_workflow_options

      response.data['events'].each do |event|
        if event['eventType'] == 'WorkflowExecutionFailed'
          failures << Base64.decode64(event['workflowExecutionFailedEventAttributes']['details']).match(/errorMessage.{1,}/).to_s
        end
      end
    end

    counts = Hash.new 0
    failures.each do |i|
      counts[i] += 1
    end

    #f = '/home/wclaiborne/temp/r.txt'
    #File.open(f, 'w') { |file| file.write(counts) }

    counts.each do |c|
      puts c
    end

  end

  def get_a_spcific_workflow(wid, rid)
    opts = {:domain => @domain, :execution => {:workflow_id => wid, :run_id => rid}}
    response = @swf.get_workflow_execution_history opts
    #File.open('/Users/wclaiborne/Desktop/something.json', 'w') { |file| file.write(response.data.to_json) }
  end
end
