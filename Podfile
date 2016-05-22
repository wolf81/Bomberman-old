#install! 'cocoapods', :deterministic_uuids => false

# for the Charts pod we force use frameworks, as it's writting in Swift
use_frameworks! 

# disable all the warnings for all pods
inhibit_all_warnings! 

def import_pods
	pod 'Zip'
end

target 'Bomberman-tvOS' do
    platform :tvos, '9.0'
    import_pods
end

target 'Bomberman-OSX' do
    platform :osx, '10.11'
    import_pods
end