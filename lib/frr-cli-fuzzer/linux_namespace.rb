module FrrCliFuzzer
  class LinuxNamespace
    # Create a child process running on a separate network and mount namespace.
    def fork_and_unshare
      io_in, io_out = IO.pipe

      LibC.prctl(FrrCliFuzzer::LibC::PR_SET_CHILD_SUBREAPER, 1, 0, 0, 0)

      pid = Kernel.fork do
        LibC.unshare(LibC::CLONE_NEWNS | LibC::CLONE_NEWPID | LibC::CLONE_NEWNET)

        # Fork again to use the new PID namespace.
        # Need to supress a warning that is irrelevant for us.
        warn_level = $VERBOSE
        $VERBOSE = nil
        pid = Kernel.fork do
          # HACK: kill when parent dies.
          trap(:SIGUSR1) do
            LibC.prctl(LibC::PR_SET_PDEATHSIG, 15, 0, 0, 0)
            trap(:SIGUSR1, :IGNORE)
          end
          LibC.prctl(LibC::PR_SET_PDEATHSIG, 10, 0, 0, 0)

          mount_propagation(LibC::MS_REC | LibC::MS_PRIVATE)
          mount_proc
          yield
        end
        $VERBOSE = warn_level
        io_out.puts(pid)
        exit(0)
      end

      @pid = io_in.gets.to_i
      Process.waitpid(pid)
    rescue SystemCallError => e
      warn "System call error:: #{e.message}"
      warn e.backtrace
      exit(1)
    end

    # Set the mount propagation of the process.
    def mount_propagation(flags)
      LibC.mount("none", "/", nil, flags, nil)
    end

    # Mount the proc filesystem (useful after creating a new PID namespace).
    def mount_proc
      LibC.mount("none", "/proc", nil, LibC::MS_REC | LibC::MS_PRIVATE, nil)
      LibC.mount("proc", "/proc", "proc",
                 LibC::MS_NOSUID | LibC::MS_NOEXEC | LibC::MS_NODEV, nil)
    end

    # nsenter(1) is a standard tool from the util-linux package. It can be used
    # to run a program with namespaces of other processes.
    def nsenter
      "nsenter -t #{@pid} --mount --pid --net"
    end
  end
end
