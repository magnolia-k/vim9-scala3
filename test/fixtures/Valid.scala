package fixtures

enum Result[+A]:
  case Success(value: A)
  case Failure(message: String)

trait Render[-A]:
  extension (value: A) def render: String

given Render[Int] with
  extension (value: Int) def render: String = s"value=$value"

object Valid:
  opaque type Id = Long

  def classify(value: Int): Result[String] =
    if value > 0 then
      Result.Success("positive")
    else
      Result.Failure("not positive")

  def collect(values: List[Int]): List[Int] =
    for
      value <- values
      if value > 0
    yield value
  end collect
end Valid
