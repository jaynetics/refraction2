require_relative 'lib/refraction/version'

Gem::Specification.new do |spec|
  spec.name = 'refraction2'
  spec.version = Refraction::VERSION
  spec.authors = ['Pivotal Labs', 'Josh Susser', 'Sam Pierson', 'Wai Lun Mang', 'Janosch Müller']
  spec.email = ['janosch84@gmail.com']

  spec.summary = 'Rack middleware replacement for joshsusser/refraction'
  spec.homepage = 'https://github.com/jaynetics/refraction2'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack', '>= 2.2'
end

