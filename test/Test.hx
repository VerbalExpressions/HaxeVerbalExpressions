package;

import expressions.VerbalExpression;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

/**
 * @author Mark Knol
 */
class Test extends TestCase {
	
	static function main() {
		var testRunner = new TestRunner();
    testRunner.add(new Test());
    testRunner.run();
	}
  
  public function testUrl() {
    var expression = new VerbalExpression()
            .startOfLine()
            .then("http")
            .maybe("s")
            .then("://")
            .maybe("www.")
            .anythingBut(" ")
            .endOfLine();

    assertFalse(expression == null);
    assertTrue(expression.isMatch("https://www.haxe.org/"));
    assertFalse(expression.isMatch("haxe.org"));
    //assertEquals("^(http)(s)?(://)(www.)?([^{ }]*)$", expression.toString());
  }
	
  public function testReplace() {
    var result = new VerbalExpression()
            .find("bird")
            .replace("Replace bird with a duck", "duck");

    assertFalse(result == null || result == "");
    assertEquals("Replace duck with a duck", result);
    assertFalse("Replace bird with a bird" == result);
  }
	
  public function testAnything() {
    var expression = new VerbalExpression()
            .startOfLine()
            .anything()
            .endOfLine();

    assertFalse(expression == null);
    assertTrue(expression.isMatch("what"));
    assertTrue(expression.isMatch(" "));
    assertTrue(expression.isMatch(""));
  }
	
  public function testAnythingBut() {
    var expression = new VerbalExpression()
            .startOfLine()
            .anythingBut("w")
            .endOfLine();

    assertFalse(expression == null);
    assertTrue(expression.isMatch("hat"));
    assertFalse(expression.isMatch("what"));
  }
	
  public function testAnyOf() {
    var expression = new VerbalExpression()
            .startOfLine()
            .then("a")
            .anyOf("xyz")
            .endOfLine();
            
    assertFalse(expression == null);
    assertFalse(expression.isMatch("abc"));
    assertTrue(expression.isMatch("ay"));
  }
  
  public function testRange() {
    var expression = new VerbalExpression()
            .startOfLine()
            .anything()
            .range("a","z","A","Z")
            .endOfLine();
    assertFalse(expression == null);
    assertTrue(expression.isMatch("aaa"));
    assertFalse(expression.isMatch("123"));
  }
  
  public function testCount() {
    var expression = new VerbalExpression()
            .startOfLine()
            .anything()
            .find("a")
            .count(4)
            .anything()
            .endOfLine();
    assertFalse(expression == null);
    assertTrue(expression.isMatch("oh aaaahhh"));
    
    var expression = new VerbalExpression()
            .startOfLine()
            .find("a")
            .count(3)
            .beginCapture().find("b").anything().endCapture()
            .endOfLine();
            
    assertFalse(expression == null);
    assertTrue(expression.isMatch("aaabcd"));
    assertFalse(expression.isMatch("baaa"));
  }
}
