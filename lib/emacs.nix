{
  lib,
}:
rec {
  toAList =
    value:
    if builtins.isString value then
      "\"${lib.escape [ "\"" "\\" ] value}\""
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isBool value then
      if value then "t" else "nil"
    else if builtins.isList value then
      "(${lib.concatMapStringsSep " " toAList value})"
    else if builtins.isAttrs value then
      let
        pairs = lib.mapAttrsToList (name: val: "(${name} . ${toAList val})") value;
      in
      "(${lib.concatStringsSep "\n " pairs})"
    else if value == null then
      "nil"
    else
      throw "Unsupported type for Emacs Lisp conversion";
}
