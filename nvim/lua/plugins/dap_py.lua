require('dap-python').setup('/usr/bin/python')

table.insert(require('dap').configurations.python, {
  type = 'python',
  request = 'launch',
  name = 'debug_libs',
  program = '${file}',
  justMyCode=false
})
