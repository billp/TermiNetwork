Pod::Spec.new do |s|
  s.name             = 'TermiNetwork'
  s.version          = '2.0.0'
  s.summary          = 'A zero-dependency networking solution for building modern and secure iOS, watchOS, macOS and tvOS applications.'
  s.homepage         = 'https://github.com/billp/TermiNetwork.git'
  s.license          = 'MIT'
  s.authors          = { 'Bill Panagiotopoulos' => 'billp.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/billp/TermiNetwork.git', :tag => s.version }
  s.documentation_url = 'https://billp.github.io/TermiNetwork'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.watchos.deployment_target = '6.0'
  s.tvos.deployment_target = '13.0'

  s.source_files = 'Source/**/*.swift'

  s.swift_versions = ['5.3']
end
