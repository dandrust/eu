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
      tasks_map = []
      projects_map = [] 
      clients_map = []

      project_assignments.each do |project_assignment|
        data = project_assignment

        clients_map << ::Harvest::Client.new(data.dig('client'))
        projects_map << ::Harvest::Project.new(data.dig('project'))

        data.dig('task_assignments').each do |task_assignment|
          task_data = task_assignment
          tasks_map << ::Harvest::Task.new(task_data.dig('task'))
        end
      end
      {
        projects: projects_map,
        clients: clients_map,
        tasks: tasks_map
      }     
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
  class Project < Resource
    attr_reader :id, :name, :data, :client, :tasks

    # prototype for class knowing about an index, etc
    # Need to test
    self << class
      private
      attr_accessor :index
    end

    def self.all
      @index
    end

    def self.find(id)
      @index.dig(id)
    end
    
    def initialize(attributes)
      @data = attributes
      @id = @data.dig('id')
      @name = @data.dig('name')
    end
  end

  class Client < Resource
    attr_reader :id, :name, :data
    # has_many Project

    def initialize(attributes)
      @data = attributes
      @id = @data.dig('id')
      @name = @data.dig('name')
    end
  end

  class Task < Resource
    attr_reader :id, :name, :project, :data
    # belongs_to Client

    def initialize(attributes)
      @data = attributes
      @id = @data.dig('id')
      @name = @data.dig('name')
    end
  end

end
