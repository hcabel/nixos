lib:

let
  inherit (lib.generators) mkLuaInline;
in
{
  env = name: value: {
    _args = [
      name
      value
    ];
  };

  bind = keys: dispatcher: {
    _args = [
      keys
      (mkLuaInline dispatcher)
    ];
  };

  bindOpts = keys: dispatcher: opts: {
    _args = [
      keys
      (mkLuaInline dispatcher)
      opts
    ];
  };

  curve = name: x1: y1: x2: y2: {
    _args = [
      name
      {
        type = "bezier";
        points = [
          [
            x1
            y1
          ]
          [
            x2
            y2
          ]
        ];
      }
    ];
  };

  on = event: body: {
    _args = [
      event
      (mkLuaInline "function() ${body} end")
    ];
  };
}
