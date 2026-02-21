package com.example

import scala.concurrent.Future
import scala.util.{Success, Failure}

// Scala 3 enum with Optional Braces
enum Color:
  case Red, Green, Blue

enum Planet(mass: Double, radius: Double):
  case Mercury extends Planet(3.303e+23, 2.4397e6)
  case Venus   extends Planet(4.869e+24, 6.0518e6)
  case Earth   extends Planet(5.976e+24, 6.37814e6)

  def surfaceGravity: Double = 6.67300E-11 * mass / (radius * radius)
end Planet

// Opaque type
opaque type Name = String
object Name:
  def apply(value: String): Name = value

// Given instance
given Ordering[Name] with
  def compare(x: Name, y: Name): Int = x.compareTo(y)

// Extension method
extension (s: String)
  def greet: String = s"Hello, $s!"
  def shout: String = s"${s.toUpperCase}!!!"

// Trait with Optional Braces
trait Printable:
  def prettyPrint: String

// Class with traditional braces (Scala 2 style)
class Person(val name: String, val age: Int) extends Printable {
  override def prettyPrint: String = s"Person($name, $age)"

  def isAdult: Boolean = age >= 18

  def greeting(using prefix: String): String =
    s"$prefix $name"
}

// Case class
case class Point(x: Double, y: Double):
  def distanceTo(other: Point): Double =
    val dx = x - other.x
    val dy = y - other.y
    Math.sqrt(dx * dx + dy * dy)
  end distanceTo
end Point

// Object with various features
object Main:
  // Inline method
  inline def debug(msg: String): Unit =
    println(s"[DEBUG] $msg")

  // Pattern matching with Scala 3 syntax
  def describe(x: Any): String = x match
    case i: Int if i > 0 => s"positive int: $i"
    case s: String       => s"string: $s"
    case _: Boolean      => "a boolean"
    case null             => "null value"
    case _               => "something else"

  // Higher-order function
  def transform[A, B](list: List[A])(f: A => B): List[B] =
    list.map(f)

  // For comprehension
  def combinations: List[(Int, Int)] =
    for
      x <- List(1, 2, 3)
      y <- List(4, 5, 6)
      if x + y > 6
    yield (x, y)

  // Try-catch with Optional Braces
  def safeDivide(a: Int, b: Int): Option[Int] =
    try
      Some(a / b)
    catch
      case _: ArithmeticException => None
    finally
      debug("division attempted")

  // Using clause
  def process(data: List[Int])(using ord: Ordering[Int]): List[Int] =
    data.sorted

  // Method chaining
  def pipeline(input: List[Int]): String =
    input
      .filter(_ > 0)
      .map(_ * 2)
      .sorted
      .mkString(", ")

  @main
  def run(): Unit =
    val p = Point(3.0, 4.0)
    val origin = Point(0.0, 0.0)
    println(s"Distance: ${p.distanceTo(origin)}")

    val colors = List(Color.Red, Color.Green, Color.Blue)
    colors.foreach(c => println(describe(c)))

    /* Block comment
     * with multiple lines
     * /* nested comment */
     */

    /**
     * Scaladoc style comment
     * @param x the input value
     * @return the result
     */
    val result: Int = 42 // TODO: compute actual result
    println(result)
  end run
end Main

// Type alias and union types
type StringOrInt = String | Int

// Numeric literals
val decimal = 1_000_000
val hex = 0xFF_FF
val binary = 0b1010_0101
val longVal = 42L
val floatVal = 3.14f
val doubleVal = 2.718e10
val charVal = 'A'
val escapeChar = '\n'
val unicodeChar = '\u0041'

// Multi-line string
val multiline = """
  This is a
  multi-line string
  with no escapes needed
"""

// Interpolated f-string
val formatted = f"Value: $decimal%,d and ${hex}%04X"

// Raw string
val path = raw"C:\Users\test\file.txt"
