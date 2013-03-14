#!/bin/env ruby
################################################################################
# $Id: service_tester.rb 2312 2011-03-17 13:49:04Z ccaroon $
################################################################################
require 'net/http';
require 'yaml';
require 'logger';
################################################################################
if ARGV.empty?
    puts "Usage: #{$0} <test_file.yml> [options]";
    exit 1;
end
################################################################################
def log(message, level = 'info')
    puts message;
    @logger.send(level, message);
end
################################################################################
def body_instance(text)

    return nil if text.nil?

    body = text.dup;
    now = Time.now;
    tomorrow = Time.now + 86400;

    body.gsub!(/DATETIME_TOMORROW/, tomorrow.strftime("%Y-%m-%d %H:%M:%S"));
    body.gsub!(/DATETIME/, now.strftime("%Y-%m-%d %H:%M:%S"));
    body.gsub!(/DATE/, now.strftime("%Y-%m-%d"));
    body.gsub!(/TIME/, now.strftime("%H:%M:%S"));
    body.gsub!(/RAND/, rand(100000000).to_s);
    body.gsub!(/TEXT/, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec magna tellus, lobortis vel, bibendum a, iaculis non, felis. Etiam adipiscing congue erat. Maecenas imperdiet. Sed molestie. Donec vehicula. Suspendisse convallis elementum arcu. Nulla bibendum fringilla velit. Vestibulum eu lectus eu quam porta dignissim. Donec mattis feugiat mauris. Duis in urna. Sed egestas turpis in turpis. Quisque in metus. Duis leo sapien, semper at, aliquam eget, sagittis non, felis.");
    
    @subs.each do |name,value|
        body.gsub!(/#{name}/, value);
    end
    
    if (body =~ /SUB_/)
        puts body;
        raise "Some required substitutions are missing.";
    end

    return (body);
end
################################################################################
def get(url, options={})
    uri = URI.parse(url);
    req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}");
    req.basic_auth options['admin_user'], options['admin_pass'];

    response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req);
    end

    return (response);
end
################################################################################
def delete(url, options={})
    uri = URI.parse(url);
    req = Net::HTTP::Delete.new("#{uri.path}?#{uri.query}");
    req.basic_auth options['admin_user'], options['admin_pass'];

    response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req);
    end

    return (response);
end
################################################################################
def post(url, options={})
    uri = URI.parse(url);
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}");
    req.basic_auth options['admin_user'], options['admin_pass'];
    
    body = body_instance(options['body']);
#     req.set_form_data({'comment'=>body}, ';');
    req['Content-type'] = 'text/xml';
    response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req, body);
    end

    response['Location'] =~ /(?:.*)\/(\d+)$/;
    @default_id = $1.to_i if $1.to_i > 0;

    return (response);
end
################################################################################
def put(url, options={})
    uri = URI.parse(url);
    req = Net::HTTP::Put.new("#{uri.path}?#{uri.query}");
    req.basic_auth options['admin_user'], options['admin_pass'];
    
    body = body_instance(options['body']);
    req['Content-type'] = 'text/xml';
    response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req, body);
    end

    return (response);
end
################################################################################
def perform(verb,url,options={})
    response = nil;
    case verb.downcase.to_sym
        when :get
            response = get(url,options);
        when :put
            response = put(url,options);
        when :post
            response = post(url,options);
        when :delete
            response = delete(url,options);
        else
    end

    return (response);
end
################################################################################
# MAIN
################################################################################
#File.delete("#{ARGV[0]}.log") if File.exists?("#{ARGV[0]}.log");
@logger = Logger.new("#{ARGV[0]}.log", 5, 50*1024*1024);
@logger.datetime_format = "%m-%d-%Y %H:%M:%S";

@default_id = 1;
@default_format = 'xml';

test_script = YAML::load_file(ARGV[0]);
test_script.delete('default');

test_script['test_suite'] = []; # if test_script['test_default'].nil?

all_test_cases = test_script.keys;

@subs = {};
@host = nil;
@port = nil;

# Add commandline setting to tests hash
ARGV.shift; # shift of .yml filename
# user_test_list = [];
ARGV.each do |setting|
    if (setting =~ /^test:(.*)/)
#         cases = all_test_cases.grep(/#{$1}/);
#         test_script['test_suite'].concat(cases);
        test_script['test_suite'] << $1;
    elsif (setting =~ /^id:(.*)/)
        @default_id = $1;
    elsif (setting =~ /^format:(.*)/)
        @default_format = $1;
    elsif (setting =~ /^subs:(.*)/)
        v = $1.split(':');
        @subs["SUB_#{v[0].upcase}"] = v[1];
    elsif (setting =~ /suite:(.*)/)
        suite_name = "suite_#{$1}";
        if (!test_script[suite_name].nil?)
            test_script['test_suite'].concat(test_script[suite_name]);
        else
            puts "No test suite named '#{suite_name}'";
            exit;
        end
    elsif (setting =~ /^host:(.*)/)
        @host= $1;
    elsif (setting =~ /^port:(.*)/)
        @port = $1.to_i;
    else
        v = setting.split(':');
        test_script[v[0]][v[1]] = v[2];
    end
end

# Use the default suite if not tests defined yet.
test_script['test_suite'] = test_script['suite_default'] if 
    test_script['test_suite'].empty?;

test_list = test_script.delete('test_suite');

# Delete the test suite lists
test_script.delete_if do |k,v|
    k =~ /^suite_/;
end

# Delete the 'base' test config
test_script.delete('base');

# If still no tests to run, then run them all
test_list = test_script.keys if (test_list.nil? || test_list.empty?)

# puts test_list.inspect;exit;

puts "Running these test cases: " + test_list.join(',');
passed_tests = [];
failed_tests = [];
test_list.each do |name|

    test_passed = true;
    test_id = test_script[name]['id'] || @default_id;
    
    log "===> begin #{name.upcase} <===";
    
    begin

        url = test_script[name]['url'];
        url += ".#{@default_format}" unless test_script[name]['no_format'];
        url += "?site_id=#{test_script[name]['site_id']}";
        
        unless (test_script[name]['query_string'].nil? ||
                test_script[name]['query_string'].empty?)
            url += "&#{test_script[name]['query_string']}";
        end

        host = @host|| test_script[name]['host'];
        url.sub!(/HOST/, host);

        port = @port || test_script[name]['port'];
        if (url =~ /PORT/)
            if (port.to_s.empty?)
                url.sub!(/:PORT/, '');
            else
                url.sub!(/PORT/, port.to_s);
            end
        end

        if (url.sub!(/ID/, test_id.to_s))
            log "ID: #{test_id}";
        end
    
        log "URL: #{test_script[name]['verb'].upcase} #{url}";
        
        response = perform(test_script[name]['verb'], url, test_script[name]);
        
        raise "Response is NIL" if response.nil?
        
        code = response.code.to_i;
        if (code == test_script[name]['expected_code'])
            log "Response: #{code}";
        else
            log "Expected #{test_script[name]['expected_code']} got #{code}", 'error';
            log "Error:\n" + response.body;
            test_passed = false;
        end

        if (!response.body.nil? && !response.body.empty? && response.body != ' ')
            log "Body:\n" + response.body;
        end
    rescue Exception => e
        log "ERROR: #{e}";
        test_passed = false;
    end
    
    if (test_passed)
        passed_tests << name;
    else
        failed_tests << name;
    end

    log "===> end #{name.upcase} <===";
end

log "\n---------------------------";
log "-----> Passed Tests: #{passed_tests.length}/#{test_list.length}";# unless passed_tests.length == 0;
log "---------------------------";
passed_tests.each do |name|
    log name;
end

log "\n---------------------------";
log "-----> Failed Tests: #{failed_tests.length}/#{test_list.length}";# unless failed_tests.length == 0;
log "---------------------------";
failed_tests.each do |name|
    log name;
end

