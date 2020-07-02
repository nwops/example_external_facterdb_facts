#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

# connects to puppetdb and creates file for all the systems it finds
# This can be run on any machine that has access to puppetdb

require 'bundler/inline'

gemfile do
  gem 'puppetdb-ruby', '~> 1.2'
end

require 'puppetdb'
require 'fileutils'
require 'json'
require 'socket'

def default_conf
  {
    "puppetdb": {
      "server_urls": "https://#{Socket.gethostname}:8081",
      "cacert": '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      "cert": "/etc/puppetlabs/puppet/ssl/certs/#{Socket.gethostname}.pem",
      "key": "/etc/puppetlabs/puppet/ssl/private_keys/#{Socket.gethostname}.pem"
    }
  }
end

def puppetdb_conf
  @puppetdb_conf ||= File.expand_path File.join(ENV['HOME'], '.puppetlabs', 'client-tools', 'puppetdb.conf')
end

def conn
  @conn ||= JSON.parse(File.read(puppetdb_conf))['puppetdb']
end

def client
  @client ||= begin
    PuppetDB::Client.new(
      server: conn['server_urls'],
      pem: { 'key' => conn['key'], 'cert' => conn['cert'], 'ca_file' => conn['cacert'] }
    )
  end
end

response = client.request('', 'factsets[] { }', limit: 100).data.map do |set|
  facts = set['facts']['data']
  facts_hash = {}
  facts.each { |item| facts_hash[item['name']] = item['value'] }
  dir = File.join('facts', facts_hash['facterversion'], facts_hash['kernel'], facts_hash.dig('os', 'family'), facts_hash.dig('os', 'release', 'major'))
  FileUtils.mkdir_p(dir)
  File.write(File.join(dir, "#{facts_hash['fqdn']}.facts"), JSON.pretty_generate(facts_hash))
  facts_hash
end
