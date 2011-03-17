#!/usr/bin/env ruby
################################################################################
# $Id: $
################################################################################
SERVICE_DIR = File.expand_path("~/codebase/mi/services");
CONFIG_DIR  = File.expand_path("~/codebase/devel/scratch/ccaroon/conf/prefork_rails");

# NOTE: a set cannot have the same name as an individual service.
SERVICE_SETS = {
    :all      => [:sitemgr, :media, :taxonomy, :relationship, :search, :class_ads,
                  :ad_metadata_extraction],
    :default => [:sitemgr, :class_ads, :search],
    :classads => [:sitemgr, :media, :relationship, :class_ads, :taxonomy,
                  :ad_metadata_extraction, :search],
};
################################################################################
def start_service(service_name)
    #port = service_port(service_name);
    pid = fork do
        exec "cd #{SERVICE_DIR}/#{service_name};prefork_rails --config #{CONFIG_DIR}/#{service_name}.yml start";
    end
    Process.detach(pid);
    puts "#{service_name} started. (#{pid})";
end
################################################################################
def stop_service(service_name)
    pid = fork do
        exec "cd #{SERVICE_DIR}/#{service_name};prefork_rails --config #{CONFIG_DIR}/#{service_name}.yml stop";
    end
    Process.waitpid(pid);
    puts "---> #{service_name} stopped.";

end
################################################################################
def service_status(service_name, skip_not_running = false)
    pid = fork do
        exec "cd #{SERVICE_DIR}/#{service_name};prefork_rails --config #{CONFIG_DIR}/#{service_name}.yml status";
    end
    Process.waitpid(pid);
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
            stop_service(sn);
            start_service(sn);
        end
    when :status
        services.each do |sn|
            service_status(sn, true);
        end
    else
        puts "Unknown command: [#{cmd}]"
end
