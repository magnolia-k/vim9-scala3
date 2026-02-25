package test.scala2

// ===========================================================================
// Scala 2 indent test - covers brace-based (traditional) indentation
// Both Scala 2 brace style and mixed Scala 2/3 constructs
// ===========================================================================

// ---------------------------------------------------------------------------
// 1. class / abstract class / case class
// ---------------------------------------------------------------------------

class Animal(name: String, sound: String) {
  def makeSound(): Unit = {
    println(s"$name says $sound")
  }

  def describe(): String = {
    s"I am $name"
  }

  def isLoud: Boolean = {
    sound.length > 3
  }
}

abstract class Shape {
  def area: Double
  def perimeter: Double

  def describe: String = {
    s"Shape: area=${area}"
  }
}

case class Point(x: Double, y: Double) {
  def distanceTo(other: Point): Double = {
    val dx = x - other.x
    val dy = y - other.y
    Math.sqrt(dx * dx + dy * dy)
  }

  def midpoint(other: Point): Point = {
    Point((x + other.x) / 2, (y + other.y) / 2)
  }
}

// ---------------------------------------------------------------------------
// 2. trait
// ---------------------------------------------------------------------------

trait Flyable {
  def fly(): Unit = {
    println("Flying!")
  }

  def canFly: Boolean
}

trait Show[A] {
  def show(value: A): String
}

// ---------------------------------------------------------------------------
// 3. object / companion object
// ---------------------------------------------------------------------------

object Main {
  def main(args: Array[String]): Unit = {
    val a = new Animal("Dog", "Woof")
    a.makeSound()
    println(a.describe())
  }

  def helper(x: Int, y: Int): Int = {
    val sum = x + y
    sum * 2
  }
}

object ShowInstances {
  implicit val intShow: Show[Int] = new Show[Int] {
    def show(value: Int): String = value.toString
  }

  implicit val stringShow: Show[String] = new Show[String] {
    def show(value: String): String = s"\"$value\""
  }
}

// ---------------------------------------------------------------------------
// 4. nested class / object
// ---------------------------------------------------------------------------

class Outer {
  class Inner {
    def method(): String = {
      "inner method"
    }
  }

  val inner = new Inner()

  def run(): String = {
    inner.method()
  }
}

class Registry {
  private var entries: Map[String, Any] = Map.empty

  def register(key: String, value: Any): Unit = {
    entries = entries + (key -> value)
  }

  def lookup(key: String): Option[Any] = {
    entries.get(key)
  }

  def allKeys: List[String] = {
    entries.keys.toList.sorted
  }
}

// ---------------------------------------------------------------------------
// 5. if / else with braces
// ---------------------------------------------------------------------------

def abs(n: Int): Int = {
  if (n >= 0) {
    n
  } else {
    -n
  }
}

def classify(n: Int): String = {
  if (n < 0) {
    "negative"
  } else if (n == 0) {
    "zero"
  } else {
    "positive"
  }
}

def grade(score: Int): String = {
  if (score >= 90) {
    if (score >= 95) {
      "A+"
    } else {
      "A"
    }
  } else if (score >= 80) {
    if (score >= 85) {
      "B+"
    } else {
      "B"
    }
  } else if (score >= 70) {
    "C"
  } else {
    "F"
  }
}

// ---------------------------------------------------------------------------
// 6. match / case with braces
// ---------------------------------------------------------------------------

def describe(x: Any): String = x match {
  case i: Int     => s"int: $i"
  case s: String  => s"string: $s"
  case b: Boolean =>
    val label = if (b) "true" else "false"
    s"bool: $label"
  case _ => "other"
}

def typeDispatch(value: Any): String = value match {
  case _: Int       => "int"
  case _: String    => "string"
  case _: List[?]   => "list"
  case _: Option[?] => "option"
  case _            => "unknown"
}

// ---------------------------------------------------------------------------
// 7. for comprehension with braces
// ---------------------------------------------------------------------------

def process(list: List[Int]): List[Int] = {
  for {
    x <- list
    if x > 0
  } yield x * 2
}

def cartesian(xs: List[Int], ys: List[Int]): List[(Int, Int)] = {
  for {
    x <- xs
    y <- ys
    if x != y
  } yield (x, y)
}

// ---------------------------------------------------------------------------
// 8. try / catch / finally with braces
// ---------------------------------------------------------------------------

def safe(f: => Int): Option[Int] = {
  try {
    Some(f)
  } catch {
    case _: ArithmeticException => None
    case _: Exception           => None
  } finally {
    println("done")
  }
}

def parseAndDivide(s: String, divisor: Int): Option[Int] = {
  try {
    val n = s.toInt
    if (divisor == 0) {
      throw new ArithmeticException("division by zero")
    }
    Some(n / divisor)
  } catch {
    case _: NumberFormatException => None
    case _: ArithmeticException   => None
    case e: Exception             => {
      println(s"Unexpected: ${e.getMessage}")
      None
    }
  } finally {
    println("parseAndDivide complete")
  }
}

// ---------------------------------------------------------------------------
// 9. while with braces
// ---------------------------------------------------------------------------

def countdown(n: Int): Unit = {
  var i = n
  while (i > 0) {
    println(i)
    i -= 1
  }
}

def sumUntil(limit: Int): Int = {
  var sum = 0
  var i = 1
  while (i <= limit) {
    sum += i
    i += 1
  }
  sum
}

// ---------------------------------------------------------------------------
// 10. method chaining
// ---------------------------------------------------------------------------

def pipeline(input: List[Int]): String = {
  input
    .filter(_ > 0)
    .map(_ * 2)
    .sorted
    .mkString(", ")
}

def pipelineMap(data: List[Int]): Map[String, Int] = {
  data
    .filter(_ > 0)
    .map(_ * 2)
    .sorted
    .zipWithIndex
    .map { case (v, i) => s"item$i" -> v }
    .toMap
}

// ---------------------------------------------------------------------------
// 11. multi-line expressions (bracket balance)
// ---------------------------------------------------------------------------

def multiParam(
  a: Int,
  b: String,
  c: Double
): String = {
  s"$a $b $c"
}

val longList: List[Int] = List(
  1, 2, 3, 4, 5
)

val nestedMap: Map[String, List[Int]] = Map(
  "a" -> List(1, 2, 3),
  "b" -> List(4, 5, 6),
  "c" -> List(7, 8, 9)
)

// ---------------------------------------------------------------------------
// 12. generic types and type parameters
// ---------------------------------------------------------------------------

def fold[A, B](list: List[A], init: B)(f: (B, A) => B): B = {
  list.foldLeft(init)(f)
}

def zipWith[A, B, C](xs: List[A], ys: List[B])(f: (A, B) => C): List[C] = {
  xs.zip(ys).map { case (a, b) => f(a, b) }
}

// ---------------------------------------------------------------------------
// 13. anonymous class / new expression
// ---------------------------------------------------------------------------

def makeComparator: Ordering[Int] = {
  new Ordering[Int] {
    def compare(x: Int, y: Int): Int = x - y
  }
}

val reverseOrdering: Ordering[Int] = new Ordering[Int] {
  def compare(x: Int, y: Int): Int = y - x
}

// ---------------------------------------------------------------------------
// 14. complex real-world example
// ---------------------------------------------------------------------------

sealed trait Result[+A] {
  def map[B](f: A => B): Result[B] = this match {
    case Ok(value)  => Ok(f(value))
    case Err(error) => Err(error)
  }

  def flatMap[B](f: A => Result[B]): Result[B] = this match {
    case Ok(value)  => f(value)
    case Err(error) => Err(error)
  }

  def getOrElse[B >: A](default: => B): B = this match {
    case Ok(value) => value
    case Err(_)    => default
  }
}

case class Ok[+A](value: A) extends Result[A]
case class Err(error: String) extends Result[Nothing]

object Result {
  def fromOption[A](opt: Option[A], error: => String): Result[A] = {
    opt match {
      case Some(v) => Ok(v)
      case None    => Err(error)
    }
  }

  def sequence[A](results: List[Result[A]]): Result[List[A]] = {
    results.foldRight(Ok(List.empty[A]): Result[List[A]]) { (r, acc) =>
      for {
        a <- r
        as <- acc
      } yield a :: as
    }
  }
}
