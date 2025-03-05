import std/strformat

type
  Color* = tuple[r, g, b: uint8]

  Orientation* = enum
    Vertical
    Horizontal

  Element* = ref object of RootObj
    x*: float = 0.0
    y*: float = 0.0
    w*: float = 1.0
    h*: float = 1.0
    rotation*: float = 0.0

  ColoredElement* = ref object of Element
    color*: Color

  RectangleElement* = ref object of ColoredElement

  StripesElement* = ref object of Element
    colors*: seq[Color]
    orientation*: Orientation = Vertical

  CircleElement* = ref object of ColoredElement
    r*: float = 0.5

  EllipseElement* = ref object of ColoredElement
    rx*: float = 0.5
    ry*: float = 0.5

  Flag* = object
    name*: string
    proportions*: tuple[numerator, denominator: uint]
    elements*: seq[Element]

proc `$`*(color: Color): string =
  result = fmt"Color(r: {color.r}, g: {color.g}, b: {color.b})"

proc `$`*(e: Element): string =
  result = fmt"Element(x: {e.x}, y: {e.y}, w: {e.w}, h: {e.h}, rotation: {e.rotation})"

proc `$`*(e: RectangleElement): string =
  result =
    fmt"RectangleElement(x: {e.x}, y: {e.y}, w: {e.w}, h: {e.h}, color: {e.color})"

proc `$`*(e: StripesElement): string =
  result =
    fmt"StripesElement(x: {e.x}, y: {e.y}, w: {e.w}, h: {e.h}, colors: {e.colors}, orientation: {e.orientation})"

proc `$`*(e: CircleElement): string =
  result = fmt"CircleElement(x: {e.x}, y: {e.y}, r: {e.r}, color: {e.color})"

proc `$`*(e: EllipseElement): string =
  result =
    fmt"EllipseElement(x: {e.x}, y: {e.y}, rx: {e.rx}, ry: {e.ry}, color: {e.color})"
