#!/usr/bin/env ruby
################################################################################
# $Id: srvctl.rb 2209 2010-11-23 16:00:18Z ccaroon $
################################################################################
SERVICE_DIR = File.expand_path("~/codebase/mi/services");

PORT_MAP = {
    :sitemgr                => 8701,
    :ad_metadata_extraction => 8705,
    :class_ads              => 8710,
    :search                 => 8715,
};
NUM_SERVERS = 2;

# NOTE: a set cannot have the same name as an individual service.
SERVICE_SETS = {
    :all      => PORT_MAP.keys,
    :default  => [:sitemgr, :search],
    :classads => [:sitemgr, :class_ads, :search, :ad_metadata_extraction],
};

@misc_port_base = 9000;
################################################################################
def pid_file(service_name)
    port = service_port(service_name);
    return (File.expand_path("#{SERVICE_DIR}/#{service_name}/tmp/pids/thin.#{port}.pid"));
end
################################################################################
def start_service(service_name)
    port = service_port(service_name);
    pid = fork do
        exec "cd #{SERVICE_DIR}/#{service_name};RAILS_RELATIVE_URL_ROOT=/mi_services/#{service_name} thin start -p #{port} -s#{NUM_SERVERS}";
    end
    Process.detach(pid);
    puts "#{service_name} started. (#{pid})";
end
################################################################################
def stop_service(service_name)
    port = service_port(service_name);
    pid_file = pid_file(service_name);
    if (File.exists?(pid_file))
        pid = fork do
            exec "cd #{SERVICE_DIR}/#{service_name};thin stop -p #{port} -s#{NUM_SERVERS}";
        end
        Process.waitpid(pid);
        puts "---> #{service_name} stopped.";
    else
        puts "#{service_name} not running.";
    end
end
################################################################################
def service_status(service_name, skip_not_running = false)
    pid_file = pid_file(service_name);
    if (File.exists?(pid_file))
        puts "===>  #{service_name}:#{PORT_MAP[service_name.to_sym]} <===";
        pid = fork do
            exec "ps -fp `cat #{pid_file}`";
        end
        Process.waitpid(pid);
        puts;
    else
        puts "#{service_name}:#{PORT_MAP[service_name.to_sym]} is not running." unless skip_not_running;
    end
end
################################################################################
def service_port(service_name)
    port = PORT_MAP[service_name.to_sym];
    if port.nil?
        port = @misc_port_base;
        @misc_port_base+=1;
    end
    
    return (port);
end
################################################################################
def service_running?(service_name)
    running = false;
    pid_file = pid_file(service_name);
    if (File.exists?(pid_file))
        running = true;
    end
    
    return (running);
end
################################################################################
def verify_expand_service_list(list)

    good_list = list.dup;

    # Expand set names
    list.each do |s|
        if (SERVICE_SETS.has_key?(s.to_sym))
            good_list.delete(s);
            good_list.concat(SERVICE_SETS[s.to_sym]);
        end
    end

    # Remove unknown service names
    bad_items = [];
    good_list.each do |s|
        unless (PORT_MAP.has_key?(s.to_sym))
            puts "[#{s}]: Unknown service. Removing from list";
            bad_items.push(s);
        end
    end
    good_list = good_list - bad_items;

    # Remove service names whose code is not present
    bad_items = [];
    good_list.each do |s|
        unless (File.exist?("#{SERVICE_DIR}/#{s}"))
            puts "[#{s}]: Directory [#{SERVICE_DIR}/#{s}] does not exist for service. Removing from list.";
            bad_items.push(s);
        end 
    end
    good_list = good_list - bad_items;
    
    return (good_list);
end
################################################################################
cmd = ARGV.shift.to_sym;
services = verify_expand_service_list(ARGV);

case cmd
    when :start
        services.each do |sn|
            start_service(sn);
        end
    when :stop
        services.each do |sn|
            stop_service(sn);
        end
    when :restart
        services.each do |sn|
            if (service_running?(sn))
                stop_service(sn);
                start_service(sn);
            else
                puts "#{sn} not running.";
            end
        end
    when :status
        services.each do |sn|
            service_status(sn, true);
        end
    when :port
        services.each do |sn|
            port = service_port(sn);
            puts "#{sn}: #{port}";
        end
    else
        puts "Unknown command: [#{cmd}]"
end
