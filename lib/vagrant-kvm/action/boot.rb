module VagrantPlugins
  module ProviderKvm
    module Action
      class Boot
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env

          # Start up the VM
          env[:ui].info I18n.t("vagrant.actions.vm.boot.booting")
          env[:machine].provider.driver.start
          raise Vagrant::Errors::VMFailedToBoot unless wait_for_boot

          @app.call(env)
        end

        def wait_for_boot
          @env[:ui].info I18n.t("vagrant.actions.vm.boot.waiting")

          @env[:machine].config.ssh.max_tries.to_i.times do |i|
            if @env[:machine].communicate.ready?
              @env[:ui].info I18n.t("vagrant.actions.vm.boot.ready")
              return true
            end

            # Return true so that the vm_failed_to_boot error doesn't
            # get shown
            return true if @env[:interrupted]

            sleep 2 if !@env["vagrant.test"]
          end

          @env[:ui].error I18n.t("vagrant.actions.vm.boot.failed")
          false
        end
      end
    end
  end
end
