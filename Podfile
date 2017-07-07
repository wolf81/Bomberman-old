#install! 'cocoapods', :deterministic_uuids => false

# for the Charts pod we force use frameworks, as it's writting in Swift
use_frameworks! 

# disable all the warnings for all pods
inhibit_all_warnings! 

def import_pods
	pod 'Zip'
	pod 'SKTiled', :git => 'https://github.com/wolf81/SKTiled', :commit => 'e73bf4efd48127aec8ff6ff1edcfb65ccebf8ff3'

end

target 'Bomberman-tvOS' do
    platform :tvos, '9.0'
    import_pods
end

target 'Bomberman-OSX' do
    platform :osx, '10.11'
    import_pods
end