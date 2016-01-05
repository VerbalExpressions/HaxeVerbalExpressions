# hx-verbal-expression

[![Build Status](https://travis-ci.org/markknol/hx-verbal-expressions.svg?branch=master)](https://travis-ci.org/markknol/hx-verbal-expressions)

### Haxe Regular Expressions made easy

> VerbalExpressions is a Haxe library that helps to construct difficult regular expressions. Ported from the awesome JavaScript [VerbalExpressions](https://github.com/jehna/VerbalExpressions).
> This project wraps around the Haxe [EReg](http://haxe.org/manual/std-regex.html) class.

### Getting started

Clone the project or download the sources.

### Examples

##### Testing valid URLs

```haxe
var expression = new expressions.VerbalExpression()
  .startOfLine()
  .then("http")
  .maybe("s")
  .then("://")
  .maybe("www.")
  .anythingBut(" ")
  .endOfLine();

var url = "https://www.haxe.org/";
// test if the url matches
if (expression.isMatch(url)) {
  trace('$url is a valid URL');
} else {
  trace('$url is an invalid URL');
}

trace(expression.toString()); 
// logs the regular expression source: ^(http)(s)?(://)(www.)?([^{ }]*)$

expression.toRegex(); 
// the Haxe EReg instance
```

##### Replacing strings

```haxe
var result:String = new expressions.VerbalExpression()
    .find("bird")
    .replace("Replace bird with a duck", "duck");
    
trace(result); 
// logs "Replace duck with a duck"
```

### Dependencies

_This project has no external dependencies._

### Status

| Haxe target | status |
|-------------|--------|
| Haxe interpreter | works |
| C++ | works |
| C# | works  |
| Java | works |
| JavaScript | works |
| Neko | works |
| PHP | works |
| Python | works |
| Flash | works |

> **Note:** Haxe is awesome! One codebase, many targets, no platform specific code.

### API documentation

You can find the documentation for the original JavaScript repo on their [wiki](https://github.com/jehna/VerbalExpressions/wiki). There can be some differences in the methods, but in general this documentation will cover most functions.

### Contributions

Clone the repo and fork! Pull requests are welcome.

### Credits

Thank you to [@jehna](https://github.com/jehna) for coming up with the awesome original idea!
