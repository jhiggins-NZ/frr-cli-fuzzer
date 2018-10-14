require "ffi"

module FrrCliFuzzer
  # Bindings for a few libc"s functions.
  module LibC
    class Bindings
      extend FFI::Library
      ffi_lib "c"

      attach_function :unshare, [:int], :int
      attach_function :mount, [:string, :string, :string, :ulong, :pointer], :int
      attach_function :prctl, [:int, :long, :long, :long, :long], :int
    end

    # Wrapper for mount(2).
    def self.mount(source, target, fs_type, flags, data)
      if Bindings.mount(source, target, fs_type, flags, data) < 0
        raise SystemCallError.new("mount failed", FFI::LastError.error)
      end
    end

    # Wrapper for unshare(2).
    def self.unshare(flags)
      if Bindings.unshare(flags) < 0
        raise SystemCallError.new("unshare failed", FFI::LastError.error)
      end
    end

    # Wrapper for prctl(2).
    def self.prctl(option, arg2, arg3, arg4, arg5)
      if Bindings.prctl(option, arg2, arg3, arg4, arg5) == -1
        raise SystemCallError.new("prctl failed", FFI::LastError.error)
      end
    end

    # include/uapi/linux/sched.h
    CLONE_NEWNS  = 0x00020000
    CLONE_NEWPID = 0x20000000
    CLONE_NEWNET = 0x40000000

    # include/uapi/linux/fs.h
    MS_NOSUID    = (1 << 1)
    MS_NODEV     = (1 << 2)
    MS_NOEXEC    = (1 << 3)
    MS_REC       = (1 << 14)
    MS_PRIVATE   = (1 << 18)

    # include/uapi/linux/prctl.h
    PR_SET_PDEATHSIG       = 1
    PR_SET_CHILD_SUBREAPER = 36
  end
end
