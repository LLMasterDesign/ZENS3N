#!/usr/bin/env ruby

vec3_root = File.expand_path('../..', __dir__)
rc = File.join(vec3_root, 'rc', '3ox.rc')

exec('ruby', rc, 'list')
