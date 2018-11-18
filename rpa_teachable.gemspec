Gem::Specification.new do |s|
  s.name = 'rpa_teachable'
  s.version = '1.0.0'

  s.summary = 'Take home test example gem for Teachable'
  s.author = 'Rhoen Pruesse-Adams'
  s.email = "rhoen.pa@gmail.com"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.license = 'MIT'
  s.add_runtime_dependency 'httparty', '~> 0.16'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'byebug', '~> 10.0'
  s.add_development_dependency 'bundler', '~> 1.16'
end
