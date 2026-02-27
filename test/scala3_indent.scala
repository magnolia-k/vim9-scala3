package test.scala3

// ===========================================================================
// Scala 3 indent test - covers Optional Braces (significant indentation)
// All patterns tested by indent/scala3.vim:
//   COLON_BLOCK_PATTERN, MATCH_PATTERN, CONTINUATION_PATTERN,
//   end/else/catch/finally/case/then/yield keywords
// ===========================================================================

// ---------------------------------------------------------------------------
// 1. class / abstract class / case class
// ---------------------------------------------------------------------------

class Animal(name: String, sound: String):
  def makeSound(): Unit =
    println(s"$name says $sound")

  def describe(): String =
    s"I am $name"

  def isLoud: Boolean =
    sound.length > 3
end Animal

abstract class Shape:
  def area: Double
  def perimeter: Double

  def describe: String =
    s"Shape: area=${area}"
end Shape

case class Point(x: Double, y: Double):
  def distanceTo(other: Point): Double =
    val dx = x - other.x
    val dy = y - other.y
    Math.sqrt(dx * dx + dy * dy)

  def midpoint(other: Point): Point =
    Point((x + other.x) / 2, (y + other.y) / 2)
end Point

// ---------------------------------------------------------------------------
// 2. trait / sealed trait
// ---------------------------------------------------------------------------

trait Flyable:
  def fly(): Unit =
    println("Flying!")

  def canFly: Boolean
end Flyable

sealed trait Color:
  def rgb: (Int, Int, Int)
end Color

object Color:
  case object Red extends Color:
    def rgb: (Int, Int, Int) = (255, 0, 0)

  case object Green extends Color:
    def rgb: (Int, Int, Int) = (0, 255, 0)

  case object Blue extends Color:
    def rgb: (Int, Int, Int) = (0, 0, 255)
end Color

// ---------------------------------------------------------------------------
// 3. object / companion object
// ---------------------------------------------------------------------------

object Main:
  def main(args: Array[String]): Unit =
    val a = Animal("Dog", "Woof")
    a.makeSound()
    println(a.describe())

  def helper(x: Int, y: Int): Int =
    val sum = x + y
    sum * 2
end Main

// ---------------------------------------------------------------------------
// 4. enum (simple and ADT-style)
// ---------------------------------------------------------------------------

enum Direction:
  case North, South, East, West

  def opposite: Direction = this match
    case North => South
    case South => North
    case East  => West
    case West  => East
end Direction

enum Planet(mass: Double, radius: Double):
  case Mercury extends Planet(3.303e+23, 2.4397e6)
  case Venus extends Planet(4.869e+24, 6.0518e6)
  case Earth extends Planet(5.976e+24, 6.37814e6)

  def surfaceGravity: Double =
    val G = 6.67300e-11
    G * mass / (radius * radius)

  def surfaceWeight(otherMass: Double): Double =
    otherMass * surfaceGravity
end Planet

// ---------------------------------------------------------------------------
// 5. given instances
// ---------------------------------------------------------------------------

trait Show[A]:
  def show(value: A): String

object Show:
  given Show[Int] with
    def show(value: Int): String = value.toString

  given Show[String] with
    def show(value: String): String = s"\"$value\""

  given [A](using sa: Show[A]): Show[List[A]] with
    def show(value: List[A]): String =
      value.map(sa.show).mkString("[", ", ", "]")
end Show

given Ordering[String] with
  def compare(x: String, y: String): Int = x.compareTo(y)

// ---------------------------------------------------------------------------
// 6. extension methods
// ---------------------------------------------------------------------------

extension (s: String)
  def shout: String = s.toUpperCase + "!"
  def whisper: String = s.toLowerCase

extension [A](list: List[A])
  def second: Option[A] = list.drop(1).headOption
  def third: Option[A] = list.drop(2).headOption

extension (n: Int)
  def times(f: => Unit): Unit =
    var i = 0
    while i < n do
      f
      i += 1

// ---------------------------------------------------------------------------
// 7. if / then / else (Scala 3 syntax)
// ---------------------------------------------------------------------------

def abs(n: Int): Int =
  if n >= 0 then n
  else -n

def classify(n: Int): String =
  if n < 0 then "negative"
  else if n == 0 then "zero"
  else "positive"

def grade(score: Int): String =
  if score >= 90 then
    if score >= 95 then "A+"
    else "A"
  else if score >= 80 then
    if score >= 85 then "B+"
    else "B"
  else if score >= 70 then "C"
  else "F"

// ---------------------------------------------------------------------------
// 8. match / case
// ---------------------------------------------------------------------------

def describe(x: Any): String = x match
  case i: Int     => s"int: $i"
  case s: String  => s"string: $s"
  case b: Boolean =>
    val label = if b then "true" else "false"
    s"bool: $label"
  case _ => "other"

def typeDispatch(value: Any): String = value match
  case _: Int       => "int"
  case _: String    => "string"
  case _: List[?]   => "list"
  case _: Option[?] => "option"
  case _            => "unknown"

def nestedMatch(input: Any): String =
  input match
    case i: Int =>
      i match
        case n if n < 0 => "negative int"
        case 0          => "zero"
        case _          => "positive int"
    case s: String =>
      if s.isEmpty then "empty string"
      else "non-empty string"
    case _ => "other"

// ---------------------------------------------------------------------------
// 9. for / yield
// ---------------------------------------------------------------------------

def combinations: List[(Int, Int)] =
  for
    x <- List(1, 2, 3)
    y <- List(4, 5, 6)
    if x + y > 6
  yield (x, y)

def process(list: List[Int]): List[Int] =
  for
    x <- list
    if x > 0
  yield x * 2

def tripleCombo(
  xs: List[Int],
  ys: List[Int],
  zs: List[Int]
): List[(Int, Int, Int)] =
  for
    x <- xs
    y <- ys
    z <- zs
    if x + y + z > 10
    if x != y
  yield (x, y, z)

// ---------------------------------------------------------------------------
// 10. try / catch / finally
// ---------------------------------------------------------------------------

def safe(f: => Int): Option[Int] =
  try Some(f)
  catch
    case _: ArithmeticException => None
    case _: Exception           => None
  finally println("done")

def parseAndDivide(s: String, divisor: Int): Option[Int] =
  try
    val n = s.toInt
    if divisor == 0 then throw new ArithmeticException("division by zero")
    Some(n / divisor)
  catch
    case _: NumberFormatException => None
    case _: ArithmeticException   => None
    case e: Exception             =>
      println(s"Unexpected: ${e.getMessage}")
      None
  finally println("parseAndDivide complete")

// ---------------------------------------------------------------------------
// 11. while / do
// ---------------------------------------------------------------------------

def countdown(n: Int): Unit =
  var i = n
  while i > 0 do
    println(i)
    i -= 1

def sumUntil(limit: Int): Int =
  var sum = 0
  var i = 1
  while i <= limit do
    sum += i
    i += 1
  sum

// ---------------------------------------------------------------------------
// 12. method chaining (continuation lines)
// ---------------------------------------------------------------------------

def pipeline(input: List[Int]): String =
  input
    .filter(_ > 0)
    .map(_ * 2)
    .sorted
    .mkString(", ")

def pipelineMap(data: List[Int]): Map[String, Int] =
  data
    .filter(_ > 0)
    .map(_ * 2)
    .sorted
    .zipWithIndex
    .map { case (v, i) => s"item$i" -> v }
    .toMap

// ---------------------------------------------------------------------------
// 13. nested class / object
// ---------------------------------------------------------------------------

class Outer:
  class Inner:
    def method(): String =
      "inner method"

  val inner = Inner()

  def run(): String =
    inner.method()
end Outer

class Registry:
  private var entries: Map[String, Any] = Map.empty

  def register(key: String, value: Any): Unit =
    entries = entries + (key -> value)

  def lookup(key: String): Option[Any] =
    entries.get(key)

  def allKeys: List[String] =
    entries.keys.toList.sorted
end Registry

// ---------------------------------------------------------------------------
// 14. multi-line expressions (bracket balance)
// ---------------------------------------------------------------------------

def multiParam(
  a: Int,
  b: String,
  c: Double
): String =
  s"$a $b $c"

val longList: List[Int] = List(
  1, 2, 3, 4, 5
)

val nestedMap: Map[String, List[Int]] = Map(
  "a" -> List(1, 2, 3),
  "b" -> List(4, 5, 6),
  "c" -> List(7, 8, 9)
)

// ---------------------------------------------------------------------------
// 15. val / var blocks
// ---------------------------------------------------------------------------

def computation(): Int =
  val x = 10
  val y = 20
  val z =
    x + y
  z * 2

def mutable(): Unit =
  var count = 0
  var message = "start"
  count += 1
  message = "done"
  println(s"$message: $count")

// ---------------------------------------------------------------------------
// 16. new expression
// ---------------------------------------------------------------------------

def makeComparator: Ordering[Int] =
  new Ordering[Int]:
    def compare(x: Int, y: Int): Int = x - y

// ---------------------------------------------------------------------------
// 17. end markers
// ---------------------------------------------------------------------------

object Utilities:
  def formatList(items: List[String]): String =
    items.mkString(", ")

  def parseInts(tokens: List[String]): List[Int] =
    for
      t <- tokens
      n <- t.toIntOption.toList
    yield n

  object Inner:
    def helper: String = "inner helper"
  end Inner
end Utilities

// ---------------------------------------------------------------------------
// 18. context parameters (using)
// ---------------------------------------------------------------------------

def showAll[A](items: List[A])(using show: Show[A]): String =
  items.map(show.show).mkString("[", ", ", "]")

def sorted[A](items: List[A])(using ord: Ordering[A]): List[A] =
  items.sorted

// ---------------------------------------------------------------------------
// 19. type aliases and opaque types
// ---------------------------------------------------------------------------

type Predicate[A] = A => Boolean

object Newtype:
  opaque type Id = Int

  object Id:
    def apply(n: Int): Id = n
    def unapply(id: Id): Option[Int] = Some(id)

  extension (id: Id) def value: Int = id
end Newtype

// ---------------------------------------------------------------------------
// 20. complex real-world example
// ---------------------------------------------------------------------------

sealed trait Result[+A]:
  def map[B](f: A => B): Result[B] = this match
    case Ok(value)  => Ok(f(value))
    case Err(error) => Err(error)

  def flatMap[B](f: A => Result[B]): Result[B] = this match
    case Ok(value)  => f(value)
    case Err(error) => Err(error)

  def getOrElse[B >: A](default: => B): B = this match
    case Ok(value) => value
    case Err(_)    => default
end Result

case class Ok[+A](value: A) extends Result[A]
case class Err(error: String) extends Result[Nothing]

object Result:
  def fromOption[A](opt: Option[A], error: => String): Result[A] =
    opt match
      case Some(v) => Ok(v)
      case None    => Err(error)

  def sequence[A](results: List[Result[A]]): Result[List[A]] =
    results.foldRight(Ok(List.empty[A]): Result[List[A]]) { (r, acc) =>
      for
        a <- r
        as <- acc
      yield a :: as
    }
end Result

// ---------------------------------------------------------------------------
// 21. // コメント行のインデント継続
// ---------------------------------------------------------------------------

// コメントアウトした行の後でリターンを押すと、コメントと同じインデントが維持される

class CommentContinuation:
  // comment at class body level
  val x = 1
  // first consecutive comment
  // second consecutive comment
  val y = 2
end CommentContinuation

def commentInMethod(): Unit =
  // comment at top of method body
  val a = 1
  // first comment before assignment
  // second comment before assignment
  val b = 2
  val c = 3
