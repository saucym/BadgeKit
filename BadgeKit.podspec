# MARK: converted automatically by spec.py. @hgy

Pod::Spec.new do |s|
	s.name = 'BadgeKit'
	s.version = '1.0.0'
	s.description = 'BadgeKit'
	s.license = 'MIT'
	s.summary = 'BadgeKit'
	s.homepage = 'https://github.com/saucym/BadgeKit'
	s.authors = { 'saucym' => '413132340@qq.com' }
	s.source = { :git => 'http://git.code.oa.com/saucymqin/BadgeKit.git', :branch => 'master' }
	s.requires_arc = true
	s.ios.deployment_target = '9.0'
        s.swift_version = '4.2'
	s.source_files = 'BadgeKit/**/*.{h,m,swift}'
	s.resources = 'Resource/**/*.{xib,json,png,jpg,gif,js}','BadgeKit/**/*.{xib,json,png,jpg,gif,js}'
end
