package expressions;

/**
 * @author Mark Knol
 */
class VerbalExpression 
{
  private var _prefixes = "";
  private var _source = "";
  private var _suffixes = "";
  private var _modifiers = "gm"; // default to global multiline matching

  public inline function new() {
    
  }
  
  /**
   * Sanitation function for adding anything safely to the expression.
   */
  public inline function sanitize(value:String):String {
    return ~/[-\\.,_*+?^$[\](){}!=|]/ig.replace(value,"\\$&");
  }

  public inline function test(toTest:String):Bool {
    return isMatch(toTest);
  }

  public inline function isMatch(toTest:String):Bool {
    return toRegex().match(toTest);
  }

  public inline function toRegex():EReg {
    return new EReg(toString(), _modifiers);
  }

  public inline function toString():String {
    return _prefixes + _source + _suffixes;
  }
  
  /**
   * Function to add stuff to the expression. 
   * Also compiles the new expression so it's ready to be used.
   */
  public inline function add(value:String, doSanitize:Bool = true):VerbalExpression {
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

  public inline function startOfLine(enable:Bool = true):VerbalExpression {
    _prefixes = enable ? "^" : "";
    return this;
  }

  public inline function endOfLine(enable:Bool = true):VerbalExpression {
    _suffixes = enable ? "$" : "";
    return this;
  }

  public inline function then(value:String, doSanitize:Bool = true):VerbalExpression {
    var sanitizedValue = doSanitize ? sanitize(value) : value;
    return add('($sanitizedValue)', false);
  }

  public inline function find(value:String) {
    return then(value);
  }

  public inline function maybe(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('($value)?', false);
  }

  public inline function anything():VerbalExpression {
    return add("(.*)", false);
  }

  public inline function anythingBut(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('([^{$value}]*)', false);
  }

  public inline function something():VerbalExpression {
    return add('(.+)', false);
  }

  public inline function somethingBut(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('([^{$value}]+)', false);
  }

  public inline function replace(input:String, value:String):String {
   return toRegex().replace(input, value);
  }

  public inline function lineBreak():VerbalExpression {
    return add('(\n|(\r\n))', false);
  }

  public inline function br():VerbalExpression {
    return lineBreak();
  }

  public inline function tab():VerbalExpression {
    return add('\\t');
  }

  public inline function word():VerbalExpression {
    return add('\\w+', false);
  }

  public inline function anyOf(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? sanitize(value) : value;
    return add('[$value]', false);
  }

  public inline function any(value:String):VerbalExpression {
    return anyOf(value);
  }
  
  public inline function count(from:Int, ?to:Int):VerbalExpression {
    return to == null ? add('{$from}', false) : add('{$from-$to}', false);
  }

  public inline function range(from1:String, to1:String, ?from2:String, ?to2:String, ?from3:String, ?to3:String, ?from4:String, ?to4:String):VerbalExpression {
    var v = '$from1-$to1';
    if (from2 != null && to2 != null) v += '$from2-$to2';
    if (from3 != null && to2 != null) v += '$from3-$to3';
    if (from4 != null && to2 != null) v += '$from4-$to4';
    this.add('[$v]', false);
    return this;
  }

  public inline function multiple(value:String, doSanitize:Bool = true):VerbalExpression {
    value = doSanitize ? this.sanitize(value) : value;
    return add('($value)+', false);
  }

  public inline function or(value:String, doSanitize:Bool = true):VerbalExpression {
    _prefixes += "(";
    _suffixes = ")" + _suffixes;
    _source += ")|(";
    return add(value, doSanitize);
  }

  public inline function beginCapture(groupName:String = null):VerbalExpression {
    if (groupName == null) {
      return add("(", false);
    }  else {
      return add("(?<", false).add(groupName, true).add(">", false);
    }
  }

  public inline function endCapture():VerbalExpression {
    return add(")", false);
  }

  public inline function repeatPrevious(from:Int, to:Int = null):VerbalExpression {
    return count(from, to);
  }
  
  public inline function addModifier(modifier:String):VerbalExpression {
    if (_modifiers.indexOf( modifier ) == -1) {
      _modifiers += modifier;
    }
    return this;
  }

  public inline function removeModifier(modifier:String):VerbalExpression {
    _modifiers = StringTools.replace(_modifiers, modifier, "");
    return this;
  }

  public inline function withAnyCase(enable:Bool = true):VerbalExpression {
    if (enable) {
      addModifier('i');
    } else {
      removeModifier('i');
    }
    return this;
  }

  public inline function useOneLineSearchOption(enable:Bool):VerbalExpression {
    if (enable) {
      removeModifier('m');
    } else {
      addModifier('m');
    }
    return this;
  }

  public inline function withOptions(options:String):VerbalExpression {
    this._modifiers = options;
    return this;
  }
}
