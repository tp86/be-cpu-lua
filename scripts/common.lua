local git = io.popen("git rev-parse --show-toplevel")
local git_root = git:read()
git:close()

return {
  git_root = git_root
}
