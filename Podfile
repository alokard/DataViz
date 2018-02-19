platform :ios, '10.0'

use_frameworks!
inhibit_all_warnings!

target 'DataViz' do
    pod 'RxDataSources'
end

target 'DataVizTests' do
    pod 'RxDataSources'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        # enable tracing resources `RxSwift.Resources.total`
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-D TRACE_RESOURCES']
                end
            end
        end
    end
end
