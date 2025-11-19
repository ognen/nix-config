{
  lib,
}:
rec {
  # Convert a Nix value to an Emacs Lisp representation (for alists)
  toEmacsLisp =
    value:
    if builtins.isString value then
      "\"${lib.escape [ "\"" "\\" ] value}\""
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isBool value then
      if value then "t" else "nil"
    else if builtins.isList value then
      "[${lib.concatMapStringsSep " " toEmacsLisp value}]"
    else if builtins.isAttrs value then
      toEmacsAlist value
    else if value == null then
      "nil"
    else
      throw "Unsupported type for Emacs Lisp conversion";

  # Convert a Nix value to an Emacs Lisp representation (for plists)
  toEmacsLispPlist =
    value:
    if builtins.isString value then
      "\"${lib.escape [ "\"" "\\" ] value}\""
    else if builtins.isInt value || builtins.isFloat value then
      toString value
    else if builtins.isBool value then
      if value then "t" else "nil"
    else if builtins.isList value then
      "[${lib.concatMapStringsSep " " toEmacsLispPlist value}]"
    else if builtins.isAttrs value then
      toEmacsPlist value # Use plist for nested attrsets too
    else if value == null then
      "nil"
    else
      throw "Unsupported type for Emacs Lisp conversion";

  # Convert a Nix attrset to an Emacs alist string
  toEmacsAlist =
    attrs:
    let
      pairs = lib.mapAttrsToList (name: value: "(${name} . ${toEmacsLisp value})") attrs;
    in
    "(${lib.concatStringsSep "\n " pairs})";

  # Convert a Nix attrset to an Emacs plist string
  toEmacsPlist =
    attrs:
    let
      pairs = lib.mapAttrsToList (name: value: ":${name} ${toEmacsLispPlist value}") attrs;
    in
    "(${lib.concatStringsSep "\n " pairs})";
}
