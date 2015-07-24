upstart_configuration = YAML.load_file('config/capistrano-upstart-service.yml')['upstart_services']

def upstart_description(command, service)
  "#{command.capitalize} the #{service['name']} service via upstart on #{service['roles']} servers."
end

upstart_configuration.each do |service|
  %w(start stop restart).each do |command|
    desc upstart_description(command, service)
    Rake::Task.define_task("#{service['name']}:#{command}") do |t|
      on roles (service['roles'] || :all) do
        execute :sudo, command, service['name']
      end
    end
  end

  %w(reload status).each do |command|
    desc upstart_description(command, service)
    Rake::Task.define_task("#{service['name']}:#{command}") do |t|
      on roles (service['roles'] || :all) do
        info capture("sudo #{command} #{service['name']}")
      end
    end
  end
end
