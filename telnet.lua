local cmds = {}

cmds["/bin/busybox"] = function (conn, args)
    conn:write_line(string.format([[%s: applet not found]], args[2]))
end

cmds["wget"] = function(conn, args)
  if not args[2] then
    conn:write_line([[
      wget: missing URL
      Usage: wget [OPTION]... [URL]...

      Try `wget --help' for more options.]])
    return
  end

  print("WGET")
  conn:log_event({ action="download", url=args[2] })
end

cmds["enable"] = function(conn, args)
    conn:write_line([[
enable .
enable :
enable [
enable alias
enable bg
enable bind
enable break
enable builtin
enable caller
enable cd
enable command
enable compgen
enable complete
enable compopt
enable continue
enable declare
enable dirs
enable disown
enable echo
enable enable
enable eval
enable exec
enable exit
enable export
enable false
enable fc
enable fg
enable getopts
enable hash
enable help
enable history
enable jobs
enable kill
enable let
enable local
enable logout
enable mapfile
enable popd
enable printf
enable pushd
enable pwd
enable read
enable readarray
enable readonly
enable return
enable set
enable shift
enable shopt
enable source
enable suspend
enable test
enable times
enable trap
enable true
enable type
enable typeset
enable ulimit
enable umask
enable unalias
enable unset
enable wait]])
end

cmds["sh"] = function (conn, args)
    -- conn:set_prompt("$")
end

cmds["cd"] = function (conn, args)
end

cmds["cp"] = function (conn, args)
end

cmds["cat"] = function (conn, args)
  if args[2] == "/proc/mounts" then
            conn:write_line(string.format([[
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,nosuid,relatime,size=1014800k,nr_inodes=253700,mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,noexec,relatime,size=204820k,mode=755 0 0
/dev/vda1 / ext4 rw,relatime,data=ordered 0 0
securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev 0 0
tmpfs /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
tmpfs /sys/fs/cgroup tmpfs ro,nosuid,nodev,noexec,mode=755 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=29,pgrp=1,timeout=0,minproto=5,maxproto=5,direct 0 0
debugfs /sys/kernel/debug debugfs rw,relatime 0 0
hugetlbfs /dev/hugepages hugetlbfs rw,relatime 0 0
mqueue /dev/mqueue mqueue rw,relatime 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
lxcfs /var/lib/lxcfs fuse.lxcfs rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other 0 0
tmpfs /run/user/1001 tmpfs rw,nosuid,nodev,relatime,size=204820k,mode=700,uid=1001,gid=1001 0 0
binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc rw,relatime 0 0]]))
  else
    conn:write_line(string.format([[cat: %s: No such file or directory]], args[2]))
  end
end

function split(s, expr)
  start = 0
  index = s:find(expr)

  args = {}

  while(true) do
    if not index then
      table.insert(args, s:sub(start))
    else
      table.insert(args, s:sub(start, index-1))
    end

    if not index then
      return args
    end

    start = index + 1
    index = s:find(expr, start)
  end
end

function handle(conn)
    while( true )
    do
        line = conn:read_line()
        if not line then
            return
        end

        if line ~= "" then
          for _, s in ipairs(split(line, ";")) do
            -- trim spaces
            s = s:match( "^%s*(.-)%s*$" )

            print("cmd", s)

            args = split(s, "%s")

            fn = cmds[args[1]]
            if fn then
              fn(conn, args)
            else
              conn:write_line(string.format("%s: command not found", args[1]))
            end
          end
        end
    end
end
