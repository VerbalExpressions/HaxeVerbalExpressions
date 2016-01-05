package expressions;

/**
  @author Mark Knol
 */
class VerbalExpression {
  private var _prefixes = "";
  private var _source = "";
  private var _suffixes = "";
  private var _modifiers = "gm"; // default to global multiline matching

  public function new() {
    
  }
  
  /**
    Sanitation function for adding anything safely to the expression.
   */
  public function sanitize(value:String):String {
    return ~/[-\\.,_*+?^$[\](){}!=|]/ig.replace(value,"\\$&");
  }

  /**
    Test if regular expression matches `toTest` value.
   */
  public inline function test(toTest:String):Bool {
    return isMatch(toTest);
  }

  /**
    Test if regular expression matches `toTest` value.
   */
  public inline function isMatch(toTest:String):Bool {
    return toRegex().match(toTest);
  }

  /**
    Gets instance of `EReg` with current regular expression.
   */
  public inline function toRegex():EReg {
    return new EReg(toString(), _modifiers);
  }

  /**
    Gets the source of the regular expression.
   */
  public inline function toString():String {
    return _prefixes + _source + _suffixes;
  }
  
  /**
    Append literal expression to the object. Also refreshes the source expression.
   */
  public function add(value:String, doSanitize:Bool = true):VerbalExpression {
    #if debug
    if (value == null || value == "") {
      throw "VerbalExpression: value cannot be null or empty";
    }
    #end
    if (doSanitize) {
      _source += sanitize(value);
    } else {
      _source += value;
    }
    return this;
  }

  /**
     Mark the expression to start at the first character of the line.
   */
  public function startOfLine(enable:Bool = true):VerbalExpression {
    _prefixes = enable ? "^" : "";
    return this;
  }

  /**
     Mark the expression to end at the last character of the line.
   */
  public function endOfLine(enable:Bool = true):VerbalExpression {
    _suffixes = enable ? "$" : "";
    return this;
  }

  /**
    Add a string to the expression.
   */
  public function then(value:String, doSanitize:Bool = true):VerbalExpression {
    var sanitizedValue = doSanitize ? sanitize(value) : value;
    return add('($sanitizedValue)', false);
  }

  /**
    Add a string to the expression.
   */
  public function find(value:String):VerbalExpression {
    return then(value);
  }

  /**
    Add a string to the expression that might appear once (or not).
   */
  public function maybe(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('($value)?', false);
  }

  /**
    Add expression that matches anything (includes empty string).
   */
  public function anything():VerbalExpression {
    return add("(.*)", false);
  }

  /**
    Add expression that matches anything, but not passed argument.
   */
  public function anythingBut(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('([^{$value}]*)', false);
  }

  /**
    Add expression that matches something that might appear once (or more).
   */
  public function something():VerbalExpression {
    return add('(.+)', false);
  }

  /**
    
   */
  public function somethingBut(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('([^{$value}]+)', false);
  }

  /**
    Shorthand function for the `StringTools.replace` function to give more logical flow if,
    for example, we're doing multiple replacements on one regular expression.
   */
  public inline function replace(input:String, value:String):String {
   return toRegex().replace(input, value);
  }

  /**
    Add universal line break expression.
   */
  public function lineBreak():VerbalExpression {
    return add('(\n|(\r\n))', false);
  }

  /**
    Shorthand for `lineBreak()`.
   */
  public function br():VerbalExpression {
    return lineBreak();
  }

  /**
    Add expression to match a tab character.
   */
  public function tab():VerbalExpression {
    return add('\\t');
  }

  /**
    Adds an expression to match a word.
   */
  public function word():VerbalExpression {
    return add('\\w+', false);
  }
  
  /**
    Add expression to match any of given value.
   */
  public function anyOf(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('[$value]', false);
  }

  /**
    Shorthand for `anyOf(value, true)`.
   */
  public function any(value:String):VerbalExpression {
    return anyOf(value, true);
  }
  
  /**
    Repeats the previous item exactly `from` times or between `from` and `to` times. for example:
     ```
     .find("w").count(3) // produce (w){3}
     ```
   */
  public function count(from:Int, ?to:Int):VerbalExpression {
    return to == null ? add('{$from}', false) : add('{$from-$to}', false);
  }

  /**
    Add expression to match a range (or multiply ranges).
    Usage: 
    ```
    .range(from, to [, from, to ... ])
    ```
    Example: 
    The following matches a hexadecimal number:
    ````
    regex().range( "0", "9", "a", "f") // produce [0-9a-f]
    ```
   */
  public function range(from1:String, to1:String, ?from2:String, ?to2:String, ?from3:String, ?to3:String, ?from4:String, ?to4:String):VerbalExpression {
    var v = '$from1-$to1';
    if (from2 != null && to2 != null) v += '$from2-$to2';
    if (from3 != null && to2 != null) v += '$from3-$to3';
    if (from4 != null && to2 != null) v += '$from4-$to4';
    this.add('[$v]', false);
    return this;
  }

  /**
    Add a alternative expression to be matched.
   */
  public function or(value:String, doSanitize:Bool = true):VerbalExpression {
    _prefixes += "(";
    _suffixes = ")" + _suffixes;
    _source += ")|(";
    return add(value, doSanitize);
  }

  /**
    Open brace to current position and closed to suffixes.
   */
  public function beginCapture(groupName:String = null):VerbalExpression {
    if (groupName == null) {
      return add("(", false);
    }  else {
      return add("(?<", false).add(groupName, true).add(">", false);
    }
  }

  /**
    Close brace for previous capture and remove last closed brace from suffixes.
    Can be used to continue build regex after `beginCapture` or to add multiply captures.
   */
  public function endCapture():VerbalExpression {
    return add(")", false);
  }

  /**
    Same as `count()`.
   */
  public function repeatPrevious(from:Int, to:Int = null):VerbalExpression {
    return count(from, to);
  }
  
  /**
    Adds given search modifier.
   */
  public function addModifier(modifier:String):VerbalExpression {
    if (_modifiers.indexOf( modifier ) == -1) {
      _modifiers += modifier;
    }
    return this;
  }

  /**
    Removes given search modifier.
   */
  public function removeModifier(modifier:String):VerbalExpression {
    _modifiers = StringTools.replace(_modifiers, modifier, "");
    return this;
  }

  /**
    Shorthand to enable "i" as search modifier.
   */
  public function withAnyCase(enable:Bool = true):VerbalExpression {
    if (enable) {
      addModifier('i');
    } else {
      removeModifier('i');
    }
    return this;
  }

  /**
    Shorthand to enable "m" as search modifier.
   */
  public function useOneLineSearchOption(enable:Bool):VerbalExpression {
    if (enable) {
      removeModifier('m');
    } else {
      addModifier('m');
    }
    return this;
  }

  /**
    Sets the search modifiers to given options.
   */
  public function withOptions(options:String):VerbalExpression {
    this._modifiers = options;
    return this;
  }
}
