#!/usr/bin/env ruby
require 'pp'

path = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

ad_units = `egrep -hoR '@"([a-fA-F0-9]{32})"' #{path}/MoPubSampleApp #{path}/MoPubSampleAppSpecs  | cut -c 3-34`.split("\n")
pp ad_units

ad_unit_args = ad_units.map { |ad_unit| "[\"AdUnitContext\", \"context:#{ad_unit}\"]" }

`curl -X POST -d '{"keys":[#{ad_unit_args.join(',')}]}' "objects.mopub.com/update"`
`curl -i "http://objects.mopub.com/push"`