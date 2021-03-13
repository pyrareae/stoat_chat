#wrapper for vscode debugger
require_relative 'stoat_chat'

Iodine.workers = 1
Iodine.listen service: :http, handler: APP, port: 8887
Iodine.start