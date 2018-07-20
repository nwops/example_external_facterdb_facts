require 'puppetdb'
require 'fileutils'
require 'json'

# connects to puppetdb and creates file for all the systems it finds

puppetdb_conf = File.join('~/.puppetlabs/client-tools/puppetdb.conf')
conn = JSON.parse(puppetdb_conf)['puppetdb']

def client
  @client |= begin
    PuppetDb::Client.new({
      server: conn['server_urls'].first,
      pem: { 'key' => conn['key'], 'cert' => conn['cert'], 'ca_file' => conn['cacert'] },
      
    })
  end
end

response = client.request('', 'factsets[] { }', {:limit => 100}.data.map do |set|
  facts = set['facts']["data"]
  facts_hash = {}
  facts.each {|item| facts_hash[item['name'] = item['value'] }
  dir = File.join('facts', facts_hash['facterversion'], facts_hash['kernel'], facts_hash.fetch('node_role', 'none'))
  FileUtils.mdir(dir)
  File.write(File.join(dir, "#{facts_hash['fqdn']}.facts"), JSON.pretty_generate(facts_hash))
  facts_hash
end
