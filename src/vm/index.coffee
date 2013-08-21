Transformer = require '../ast/transformer'
Realm = require '../runtime/realm'
ConstantFolder = require '../ast/constant_folder'
Emitter = require './emitter'
{Fiber} = require './thread'


class Vm
  constructor: (merge) ->
    @realm = new Realm(merge)

  eval: (string, filename) -> @run(@compile(string, filename))

  compile: (source, filename) -> compile(source, filename)

  run: (script) ->
    fiber = @createFiber(script)
    evalStack = fiber.callStack[0].evalStack
    fiber.run()
    if not fiber.paused
      return evalStack.rexp

  createFiber: (script) ->
    fiber = new Fiber(@realm)
    fiber.pushFrame(script, @realm.global)
    return fiber


compile = (code, filename = '<script>') ->
  emitter = new Emitter(null, filename)
  transformer = new Transformer(new ConstantFolder(), emitter)
  transformer.transform(esprima.parse(code, {loc: true}))
  return emitter.end()


module.exports = Vm
