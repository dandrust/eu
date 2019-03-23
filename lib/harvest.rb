# frozen_string_literal: true

require 'json'

module EU
  class Harvest
    PATH_PREFIX = '/v2'
    attr_reader :client

    def initialize
      unless EU.config.harvest_account_id && EU.config.harvest_bearer_token
        raise "Harvest credentials not found in cofig" 
      end

      @client = HTTPService.new('https://api.harvestapp.com', {
        'Harvest-Account-ID': EU.config.harvest_account_id,
        'Authorization': "Bearer #{EU.config.harvest_bearer_token}",
        'User-Agent': 'ruby/2.5.1'
      })
    end

    def project_assignments
      response = client.get(path_for"/users/#{EU.config.harvest_user_id}/project_assignments")
      project_assignments = JSON.parse(response.body)['project_assignments']
      projects_map = {}
      clients_map = {}
      tasks_map = {}

      project_assignments.each do |project_assignment|
        # unless projects_map[project_assignment['client']['id']]
        #   clients_map[project_assignment['client']['id']] = project_assignment['client']
        # end
        unless projects_map[project_assignment['project']['id']]
          projects_map[project_assignment['project']['id']] = project_assignment['project']
        end
        # project_assignment['task_assignments'].each do |task_assignment|
        #   unless tasks_map[task_assignment['task']['id']]
        #     tasks_map[task_assignment['task']['id']] = task_assignment['task']
        #   end
        # end
      end
      
      projects_map
      #projects_map.inject([]) { |projects, project| projects << ::Harvest::Project.new(**project.last) }
      # {
      #   projects: projects_map.inject([]) { |projects, project| projects << ::Harvest::Project.new(**project.last) },
      #   clients: clients_map.inject([]) { |clients, client| clients << ::Harvest::Client.new(**client.last) },
      #   tasks: tasks_map.inject([]) { |tasks, task| tasks << ::Harvest::Task.new(**task.last) }
      # }
    end

    def get(path)
      response = client.get(path_for "/#path")
      JSON.parse(response.body)
    end

    private

    def path_for(path)
      PATH_PREFIX + path
    end
  end
end

# Have a sober second though about how this is organized -
# Think about app architecture!
module Harvest
  class Resource
    # define belongs_to and has_many dsl here
    # define all and finders by relation here

    def self.has_many

      # Sober second thought - do you want to have magical dsl?
    end
  end
  class Project < Resource
    attr_reader :id, :name
    # belongs_to Client
    # has_many Task

    def initialize(id:, name:)
      @id = id
      @name = name
    end
  end

  class Client < Resource
    attr_reader :id, :name
    # has_many Project

    def initialize(id:, name:)
      @id = id
      @name = name
    end
  end

  class Task < Resource
    attr_reader :id, :name, :project
    # belongs_to Client

    def initialize(id:, name:)
      @id = id
      @name = name
    end
  end

end
